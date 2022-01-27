#!/usr/bin/env node

/**
 * Manages versions of WordPress container images
 *   Uses an algorithm to decide which versions should be available
 *   Runs processes to make the actual images correct according to the list
 */

/**
 * System dependencies
 */
const exec = require( 'child_process' ).exec;
const fs = require( 'fs' );

/**
 * Internal dependencies
 */
const ts = new Date().toISOString();
const cfg = require(  `${__dirname}/version-manager-cfg.json` );
const branch = `update/WordPress-image-${ts.split( 'T' )[0]}`;
cfg.REPOSITORY_DIR = `${cfg.WORKING_DIR}/vip-container-images`;

//TODO: args override configs
//const args = process.argv.slice( 2 );

// try to create the WORKING_DIR recursively if it does not exist
try {
	if ( ! fs.existsSync( cfg.WORKING_DIR ) ) {
		fs.mkdirSync( cfg.WORKING_DIR, { recursive: true } );
		console.log( `Created Working Directory: ${cfg.WORKING_DIR}` );
	}
} catch ( err ) {
	console.log( 'Create Working Directory failed: ' + err );
	process.exit( 1 );
}

// main IIFE
(async function () {
	let change;
	const changeLog = ['Changes generated to update WordPress images in vip dev-env.'];
	const imageList = await getImagelist();
	const tagList = await getTagList();
	const versionList = collateTagList( tagList, cfg.VERSION_LIST_SIZE );
	const adds = getAddsQueue( imageList, versionList );
	const removes = getRemovesQueue( imageList, versionList );

	// Init repo and check out new branch
	await initRepo();
	await checkoutNewBranch( branch );

	// walks through the list of recommended changes and performs the operations
	for ( change of adds ) {
		await addVersion( change.tag, changeLog );
	}

	for ( change of removes ) {
		await removeVersion( change.version, changeLog );
	}

	// Stage and commit the result of the operations
	await stage();

	// Commit changes
	const cl = changeLog.join( `\n  * ` );
	await commit( cl );

	// Push commit
	await push( branch );

	// Create Pull Request
	const pr = await requestMerge( cl );

	// Update the PR with Labels
	await issueUpdate( pr );

	console.log( 'Ideal Image List:' );
	console.log( versionList );

	console.log( 'Currently Offered List:' );
	console.log( imageList );

	console.log( `A Pull Request has been submitted on behalf of wpcomvip-bot.` );
	console.log( 'Corrections Prescribed:' );
	console.log( `${cl}` );
	console.log( `\n${pr.url}\n\n` );
})();

// =========================== Functions ========================================

/**
 * Attempts to organize the list of tags in an intelligent way.
 * Show all editions of the current and previous major version
 * Show only the the most recent point releases of previous major versions
 */
function collateTagList( tags, size ) {
	const newTagList = [];
	let sizeOffset;

	// sort tags
	tags = tags.reverse();

	// index tags
	const { majorVersions, versions, releases } = indexTags( tags );

	// build new tag list from indexes
	OUT:
	for ( const i in majorVersions ) {
		sizeOffset = 0;
		for ( const [ j, v ] of versions[ majorVersions[ i ] ].entries() ) {
			// If it is the most recent 2 versions, append all of the releases
			if ( i == 0 && j <= 0 ) {
				sizeOffset += releases[ v ].length;
				newTagList.push( ...releases[ v ] );
			} else {
				// append only the newest release for previous versions
				newTagList.push( releases[ v ][ 0 ] );
			}

			if ( newTagList.length >= ( size - sizeOffset) ) {
				break OUT;
			}
		}
	}

	return newTagList;
}

/**
 * Get list of queued adds
 */
function getAddsQueue( imageList, versionList ) {
	const adds = [];

	for ( version of versionList) {
		if ( imageList.indexOf( version ) === -1 ) {
			adds.push( {tag: version} );
		}
	}

	return adds;
}

/**
 * Get list of queued removes
 */
function getRemovesQueue( imageList, versionList ) {
	const removes = [];
	for ( image of imageList ) {
		if ( versionList.indexOf( image ) === -1 ) {
			removes.push( {version: image} );
		}
	}

	return removes;
}

/**
 * Creates indexes with the tags
 */
function indexTags( tags ) {
	const majorVersions = [];
	const versions = {};
	const releases = {};
	let majorVersion, version, release;

	for ( const tag of tags ) {
		if ( ! tag.includes( '.' ) ) {
			continue;
		}

		[ majorVersion, version, release ] = tag.split( '.' );

		// index majorVersion
		if ( majorVersions.indexOf( majorVersion ) === -1 ) {
			majorVersions.push( majorVersion );
		}

		// index version
		if ( ! versions.hasOwnProperty( majorVersion ) ) {
			versions[ majorVersion ] = [];
		}

		if ( versions[ majorVersion ].indexOf( `${ majorVersion }.${ version }` ) === -1 ) {
			versions[ majorVersion ].push( `${ majorVersion }.${ version }` );
		}

		// index release
		if ( ! releases.hasOwnProperty( `${ majorVersion }.${ version }` ) ) {
			releases[ `${ majorVersion }.${ version }` ] = [];
		}

		if ( releases[ `${ majorVersion }.${ version }` ].indexOf( tag ) === -1 ) {
			releases[ `${ majorVersion }.${ version }` ].push( tag );
		}

		if ( release != undefined ) {
			if ( releases[ `${ majorVersion }.${ version }` ].indexOf( tag ) === -1 ) {
				releases[ `${ majorVersion }.${ version }` ].push( tag );
			}
		}
	}

	return { majorVersions, versions, releases };
}

/**
 * Uses the Github REST API to POST to /pulls
 */
async function requestMerge( changeLog ) {
	const postData = JSON.stringify( {
		title: 'WordPress Image Refresh',
		body: changeLog,
		head: branch,
		base: 'master',
	} );

	return new Promise( resolve => {
		let response = {};
		const https = require( 'https' );
		const req = https.request( getPullRequestApiOptions( postData ), res => {
			let data = '';

			res.on( 'data', chunk => {
				data += chunk;
			} );

			res.on( 'end', () => {
				// Handle bad response statuses from the API
				if ( res.statusCode != 201 ) {
					console.error( `Error: Pull Request API ended in status: ${res.statusCode}` );
					console.log( res.headers );
					process.exit( 1 );
				} else {
					response = JSON.parse( data );
				}

				resolve( response );
			} );
		} );

		req.on( 'error', error => {
			console.error( error );
		} );

		req.write( postData );

		req.end();
	} );
}

/**
 * Configurations for the Image API request
 */
function getPullRequestApiOptions( data ) {
	return {
		hostname: 'api.github.com',
		port: 443,
		path: '/repos/Automattic/vip-container-images/pulls',
		method: 'POST',
		headers: {
			Authorization: `Bearer ${cfg.GITHUB_OAUTH_TOKEN}`,
			'User-Agent': 'VIP',
			Accept: 'application/vnd.github.v3+json',
			'Content-Type': 'application/json',
			'Content-Length': data.length
		},
	};
}

/**
 * Uses the Github REST API to POST to /pulls
 */
async function issueUpdate( issue ) {
	const postData = JSON.stringify( {
		labels: ['[Status] Needs Review', 'WordPress'],
		requested_teams: ['@Automattic/vip-platform-cantina'],
	} );

	return new Promise( resolve => {
		let response = {};
		const https = require( 'https' );
		const req = https.request( getIssueUpdateApiOptions( issue, postData ), res => {
			let data = '';

			res.on( 'data', chunk => {
				data += chunk;
			} );

			res.on( 'end', () => {
				// Handle bad response statuses from the API
				if ( res.statusCode != 200 ) {
					console.error( `Error: Issue Update API ended in status: ${res.statusCode}` );
					console.log( res.headers );
					process.exit( 1 );
				} else {
					response = JSON.parse( data );
				}

				resolve( response );
			} );
		} );

		req.on( 'error', error => {
			console.error( error );
		} );

		req.write( postData );

		req.end();
	} );
}

/**
 * Configurations for the Image API request
 */
function getIssueUpdateApiOptions( issue, data ) {
	return {
		hostname: 'api.github.com',
		port: 443,
		path: `/repos/Automattic/vip-container-images/issues/${issue.number}`,
		method: 'PATCH',
		headers: {
			Authorization: `Bearer ${cfg.GITHUB_OAUTH_TOKEN}`,
			'User-Agent': 'VIP',
			Accept: 'application/vnd.github.v3+json',
			'Content-Type': 'application/json',
			'Content-Length': data.length
		},
	};
}

/**
 * Gets a list of all the currently available images
 */
async function getImagelist(){
	const imageList = [];

	return new Promise( resolve => {
		const https = require( 'https' );
		const req = https.request( getImageApiOptions(), res => {
			let data = '';

			res.on( 'data', chunk => {
				data += chunk;
			} );

			res.on( 'end', () => {
				try {
					const list = JSON.parse( data );
					list.forEach( item => {
						if ( item.metadata.container.tags.length > 0 ) {
							item.metadata.container.tags.forEach( tag => {
								imageList.push( tag );
							} );
						}
					} );
				} catch {
					console.error( 'ERROR: Could not load remote list of WordPress images.' );
					process.exit( 1 );
				}

				imageList.sort().reverse();
				resolve( imageList );
			} );
		} );

		req.on( 'error', error => {
			console.error( error );
		} );

		req.end();
	} );
}

/**
 * Configurations for the Image API request
 */
function getImageApiOptions() {
	return {
		hostname: 'api.github.com',
		port: 443,
		path: '/orgs/Automattic/packages/container/vip-container-images%2Fwordpress/versions?per_page=100&repo=vip-container-images&package_type=container',
		method: 'GET',
		headers: {
			Authorization: `Bearer ${cfg.GITHUB_OAUTH_TOKEN}`,
			'User-Agent': 'VIP',
			Accept: 'application/vnd.github.v3+json',
		},
	};
}

/**
 * executes a system command
 */
async function execute( command ){
	return new Promise( ( resolve, reject ) => {
			exec( command, ( error, stdout, stderr ) => {
			if ( error ) {
				console.error( error );
			}
			resolve( stdout? stdout : stderr );
		});
	});
}

/**
 * Gets a list of the WordPress tags from the official SVN
 */
async function getTagList() {
	const output = await execute( 'svn ls https://core.svn.wordpress.org/tags' );
	const formatted = output.split( "\n" ).map( tag => {
		return tag.replace( /[^0-9.]/, '' );
	} );

	return formatted;
}

/**
 * Makes sure the Working Directory is prepared for new changes
 */
async function initRepo() {
	// Clone the repo if it does not exist, else stash and refresh the repo
	if ( ! fs.existsSync( cfg.REPOSITORY_DIR ) ) {
		await cloneRepository();
	} else {
		await refreshRepository();
	}

	return await prune();
}

/**
 * Uses git to clone a remote repository.
 */
async function cloneRepository() {
	console.log( `Cloning images project repository at: ${cfg.REPOSITORY_DIR}`);
	const output = await execute( `git clone ${cfg.REPOSITORY_URL} ${cfg.REPOSITORY_DIR}` );
	process.chdir( cfg.REPOSITORY_DIR );
	return output;
}

/**
 * Uses git to refresh the repository.
 */
async function refreshRepository() {
	process.chdir( cfg.REPOSITORY_DIR );
	await stash();
	await checkoutMasterBranch();
	return await execute( 'git pull origin master' );
}

/**
 * Uses git to commit the current changes.
 * Clears any unstaged changes.
 */
async function commit( cl ) {
	return await execute( `git commit -m '${cl}'` );
}

/**
 * Uses git to prune the current changes.
 */
async function prune() {
	return await execute( 'git fetch -p' );
}

/**
 * Uses git to stage the current change manifest.
 * Clears any unstaged changes.
 */
async function stage() {
	return await execute( 'git add wordpress/versions.json' );
}

/**
 * Uses git to stash the current change manifest.
 * Clears any unstaged changes.
 */
async function stash() {
	return await execute( 'git stash' );
}

/**
 * Uses git to stash the current change manifest.
 * Clears any unstaged changes.
 */
async function push( changeBranch ) {
	return await execute( `git push ${cfg.REPOSITORY_URL} ${changeBranch}:${changeBranch}` );
}

/**
 * Uses git to find if the named branch exists.
 */
async function branchExists( name ) {
	return await execute( `git branch --list ${name}` );
}

/**
 * Uses git to find if the named remote branch exists.
 */
async function remoteExists( name ) {
	return await execute( `git ls-remote --heads ${cfg.REPOSITORY_URL} ${name}` );
}

/**
 * Checks out the master branch.
 */
async function checkoutMasterBranch() {
	return await execute( 'git checkout master' );
}

/**
 * Checks out a new branch.
 */
async function checkoutNewBranch( name ) {
	await checkoutMasterBranch();

	if ( await branchExists( name ) ) {
		await execute( `git branch -D ${name}` );
	}

	if ( await remoteExists( name ) ) {
		await execute( `git push origin --delete ${name}` );
	}

	return await execute( `git checkout -b ${name}` );
}

/**
 * Executes the add-verison.sh script with params
 */
async function addVersion( tag, changeLog ) {
	try {
		changeLog.push( `Added version: ${tag} to list of available WordPress images.` );
		return await execute( `${cfg.REPOSITORY_DIR}/wordpress/add-version.sh ${tag} ${tag}` );
	} catch ( error ) {
		console.log( `"Add Version" failed with error: ${error}` );
	}
}

/**
 * Executes the del-version.sh script with params
 */
async function removeVersion( tag, changeLog ) {
	try {
		changeLog.push( `Removed version: ${tag} from list of available WordPress images.` );
		return await execute( `${cfg.REPOSITORY_DIR}/wordpress/del-version.sh ${version}` );
	} catch ( error ) {
		console.log( `"Remove Version ( ${tag} )" failed with error: ${error}` );
	}
}
