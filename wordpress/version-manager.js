#!/usr/bin/env node

/**
 * Manages versions of WordPress container images
 *   Uses an algorithm to decide which versions should be available
 *   Runs processes to make the actual images correct according to the list
 *
 * Usage: node version-manager.js --github_oath_token=ghb_xxxxxxxxx [optional args]
 * 	working_dir			Directory where git staging operations will take place.
 * 	version_list_size		Size of the list of dynamically selected versions
 * 	branch				Name of the branch to submit staged operations
 */

/**
 * System dependencies
 */
const exec = require( 'child_process' ).exec;
const existsSync = require( 'fs' ).existsSync;
const fs = require( 'fs' ).promises;
const https = require( 'https' );
const mkdirSync = require( 'fs' ).mkdirSync;
const username = require( 'os' ).userInfo().username;

// Create config from args or defaults.
// Only GITHUB_OAUTH_TOKEN is required.
const args = process.argv.slice( 2 );
if ( args.length < 1 ) {
	console.log(`\n* Unable to run script without required arg: github_oath_token\n`);
	console.log('Usage: node version-manager.js --github_oath_token=ghb_xxxxxxxxx [optional args]');
	console.log('	working_dir			Directory where git staging operations will take place.');
	console.log('	version_list_size		Size of the list of dynamically selected versions');
	console.log('	branch				Name of the branch to submit staged operations');
	console.log('exiting...\n');
	process.exit( 1 );
}

const cfg = getConfig( args );

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
	let change, tag, ref;
	const changeLog = ['Changes generated to update WordPress images in vip dev-env.'];
	const { imageList, lockedList } = await getImagelist();
	const tagList = await getTagList();
	const releases = indexTags( tagList.reverse() );
	const versionList = Object.keys( releases ).slice( 0, cfg.VERSION_LIST_SIZE );
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
	await checkoutNewBranch( cfg.BRANCH );

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
	await push( cfg.BRANCH );

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

/**
 * Overloads defaults values with command line args
 * Assigns sane defaults where possible.
 */
function getConfig( args ) {
	let spl, key;
	const ts = new Date().toISOString();
	const cfg = {
		VERSION_LIST_SIZE: 5,
		WORKING_DIR: getDefaultWorkingDir(),
		GITHUB_OAUTH_TOKEN: '',
		BRANCH: `update/WordPress-image-${ ts.split( 'T' )[0] }`,
	};

	// Populate cfg with command line args
	for ( const arg of args ) {
		spl = arg.split('=');
		key = spl[0].replace( /\-/g , '').toUpperCase();
		cfg[key] = spl[1];
	}

	// REPOSITORY_DIR within WORKING_DIR
	cfg.REPOSITORY_DIR = `${ cfg.WORKING_DIR }/vip-container-images`;

	// Assign default REPOSITORY_URL
	if ( ! cfg.hasOwnProperty( 'REPOSITORY_URL' ) ) {
		cfg.REPOSITORY_URL = `https://wpcomvip-bot:${ cfg.GITHUB_OAUTH_TOKEN }@github.com/Automattic/vip-container-images.git`;
	}

	return cfg;
}

/**
 * Support for MacOS or Linux file system.
 */
function getDefaultWorkingDir() {
	switch( process.platform ) {
		case 'darwin': {
			return `/Users/${username}/.local/share/vip/vip-container-images/version-manager`;
		}
		case 'linux': {
			return `/home/${username}/.local/share/vip/vip-container-images/version-manager`;
		}
		default: {
			console.log( 'Unsupported Operating System. Currently this script only supports MacOS and Linux' );
			process.exit( 1 );
		}
	}
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

/**
 * Get list of queued updates
 */
async function getUpdatesQueue( releases ) {
	return new Promise( resolve => {
		const updates = [];
		let mostRecentRelease
		// regex refType will match with N.N(.N)?
		const refType = new RegExp( /\d+\.\d+(?:\.\d+)?/ );

		fs.readFile( `${__dirname}/versions.json` )
		.then( data => {
			const images = JSON.parse( data );
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
	const releases = {};
	let majorVersion, version, release;

	for ( const tag of tags ) {
		if ( ! tag.includes( '.' ) ) {
			continue;
		}

		[ majorVersion, version, release ] = tag.split( '.' );

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

	return releases;
}

/**
 * Uses the Github REST API to POST to /pulls
 */
async function requestMerge( changeLog ) {
	const postData = JSON.stringify( {
		title: 'WordPress Image Refresh',
		body: changeLog,
		head: cfg.BRANCH,
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
