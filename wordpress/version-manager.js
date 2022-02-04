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
const existsSync = require( 'fs' ).existsSync;
const fs = require( 'fs' ).promises;
const https = require( 'https' );
const mkdirSync = require( 'fs' ).mkdirSync;

let cfg = {
	REPOSITORY_URL: null,
	VERSION_LIST_SIZE: null,
	WORKING_DIR: null,
	GITHUB_OAUTH_TOKEN: null,
};

/**
 * Configuration file
 */
try {
		cfg = require(  `${__dirname}/version-manager-cfg.json` );
	} catch ( e ) {
		console.warn( 'Warn: Configuration file not found. Configuration falling back to args.' );
}
merge_args( cfg, process.argv.slice( 2 ) );

const ts = new Date().toISOString();
const branch = `update/WordPress-image-${ts.split( 'T' )[0]}`;
cfg.REPOSITORY_DIR = `${cfg.WORKING_DIR}/vip-container-images`;

// try to create the WORKING_DIR recursively if it does not exist
try {
	if ( ! existsSync( cfg.WORKING_DIR ) ) {
		mkdirSync( cfg.WORKING_DIR, { recursive: true } );
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
	const { imageList, lockedList } = await getImagelist();
	const tagList = await getTagList();
	const { versionList, releases } = collateTagList( tagList, cfg.VERSION_LIST_SIZE );
	const adds = getAddsQueue( imageList, versionList, releases );
	const removes = getRemovesQueue( imageList, versionList, lockedList );

	console.log( 'Locked status -- will not be removed:' );
	console.log( lockedList );

	console.log( 'Ideal Image List:' );
	console.log( versionList );

	console.log( 'Currently Offered List:' );
	console.log( imageList );

	// Init repo and check out new branch
	await initRepo();
	await checkoutNewBranch( branch );

	// walks through the list of recommended changes and performs the operations
	for ( { tag, ref } of adds ) {
		await addVersion( { tag, ref, changeLog } );
	}

	for ( { tag } of removes ) {
		await removeVersion( { tag, changeLog } );
	}

	const updates = await getUpdatesQueue( releases );

	if ( ( adds.length + removes.length + updates.length ) < 1 ) {
		// No changes staged. bail.
		console.log( 'List of images is optimal. Exiting.' );
		process.exit( 0 );
	}

	for ( { tag, ref } of updates ) {
		await updateVersion( { tag, ref, changeLog } );
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

	console.log( `A Pull Request has been submitted on behalf of wpcomvip-bot.` );
	console.log( 'Corrections Prescribed:' );
	console.log( `${cl}` );
	console.log( `\n${pr.url}\n\n` );
})();

// =========================== Functions ========================================

function merge_args( cfg, args ) {
	let spl, key;
	for ( let i = 0; i < args.length; i++ ) {
		spl = args[i].split('=');
		key = spl[0].replace( /\-/g , '').toUpperCase();
		cfg[key] = spl[1];
	}
}

/**
 * Attempts to organize the list of tags in an intelligent way.
 * Show all editions of the current and previous major version
 * Show only the the most recent point releases of previous major versions
 */
function collateTagList( tags, size ) {
	const versionList = [];
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
				versionList.push( ...releases[ v ] );
			} else {
				// Append only the newest release for previous versions
				// Signify it only with a x.x version
				// Later it will be stapled to the latest release for that version
				versionList.push( v );
			}

			if ( versionList.length >= ( size - sizeOffset) ) {
				break OUT;
			}
		}
	}

	return { versionList, majorVersions, versions, releases };
}

/**
 * Get list of queued adds
 */
function getAddsQueue( imageList, versionList, releaseIndex ) {
	const adds = [];
	let ref;

	for ( version of versionList ) {
		if ( imageList.indexOf( version ) === -1 ) {
			ref = ( releaseIndex.hasOwnProperty( version ) ) ? releaseIndex[version][0] : version;
			adds.push( { tag: version, ref: ref } );
		}
	}

	return adds;
}

/**
 * Get list of queued removes
 */
function getRemovesQueue( imageList, versionList, lockedList ) {
	const removes = [];
	for ( image of imageList ) {
		if ( lockedList.indexOf( image ) === -1 ) {
			if ( versionList.indexOf( image ) === -1 ) {
				removes.push( { tag: image } );
			}
		}
	}

	return removes;
}

async function getUpdatesQueue( releases ) {
	return new Promise( resolve => {
		const updates = [];
		let match, mostRecentRelease
		// regex refType will match with N.N(.N)?
		const refType = new RegExp( /[0-9]\.[0-9](?:\.)?(?:[0-9])?/ );

		fs.readFile( `${__dirname}/versions.json` )
		.then( data => {
			const images = JSON.parse(data);
			for ( image of images ) {
				if ( releases.hasOwnProperty( image.tag ) ) {
					mostRecentRelease = `${ releases[image.tag][0] }`;
					if ( mostRecentRelease !== image.ref ) {
						// If the ref is of the "tag" type e.g. N.N(.N)?;
						if ( refType.test( image.ref ) ) {
							updates.push( { tag: image.tag, ref: mostRecentRelease } );
						} else {
							// TODO: Find an updated branch hash based on a commit reference
							console.log(`No functionality available for updating tag:${ image.tag }: ref:${ image.ref }`);
						}
					}
				}
			}
			resolve( updates );
		} );
	} );
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
	const lockedList = [];

	return new Promise( resolve => {
		const req = https.request( getImageApiOptions(), res => {
			let data = '';
			let spl;

			res.on( 'data', chunk => {
				data += chunk;
			} );

			res.on( 'end', () => {
				try {
					const list = JSON.parse( data );
					list.forEach( item => {
						if ( item.metadata.container.tags.length > 0 ) {
							item.metadata.container.tags.forEach( tag => {
								spl = tag.split('-');
								if ( imageList.indexOf( spl[0] ) === -1 ) {
									imageList.push( spl[0] );
								}

								if ( spl.length > 1 ) {
									if ( 'locked' === spl[1] ) {
										lockedList.push( spl[0] );
									}
								}
							} );
						}
					} );
				} catch {
					console.error( 'ERROR: Could not load remote list of WordPress images.' );
					process.exit( 1 );
				}

				imageList.sort().reverse();
				resolve( { imageList, lockedList} );
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
	if ( ! existsSync( cfg.REPOSITORY_DIR ) ) {
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
async function addVersion( { tag, ref, changeLog } ) {
	try {
		if ( changeLog ) {
			changeLog.push( `Added version: ${tag} to list of available WordPress images.` );
		}
		return await execute( `${cfg.REPOSITORY_DIR}/wordpress/add-version.sh ${tag} ${ref}` );
	} catch ( error ) {
		console.log( `"Add Version" failed with error: ${error}` );
	}
}

/**
 * Executes the del-version.sh script with params
 */
async function removeVersion( { tag, changeLog } ) {
	try {
		if ( changeLog ) {
			changeLog.push( `Removed version: ${tag} from list of available WordPress images.` );
		}
		return await execute( `${cfg.REPOSITORY_DIR}/wordpress/del-version.sh ${tag}` );
	} catch ( error ) {
		console.log( `"Remove Version ( ${tag} )" failed with error: ${error}` );
	}
}

/**
 * Executes the del-version.sh and add-verison.sh scripts to update
 */
async function updateVersion( { tag, ref, changeLog } ) {
	if ( changeLog ) {
			changeLog.push( `Updated Wordpress Image version: ${tag} to ref ${ref}.` );
	}
	await removeVersion( { tag, changeLog: false } );
	return await addVersion( { tag, ref, changeLog: false } );
}
