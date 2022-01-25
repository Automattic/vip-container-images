#!/usr/bin/env node

/**
 * Manages versions of WordPress container images
 *   Uses an algorithm to decide which versions should be available
 *   Runs processes to make the actual images correct according to the list
 */

/**
 * @flow
 * @format
 */

/**
 * System dependencies
 */
const exec = require( 'child_process' ).exec;
const fs = require( 'fs' );

/**
 * Internal dependencies
 */
const cfg = require( `${__dirname}/version-manager-cfg.json` );

/**
 * TODO: args override configs
 */
//const args 	= process.argv.slice( 2 );


// Run the scripted git operations in the context of the "WORKING_DIR".
try {
	// try to create the WORKING_DIR recursively if it does not exist
	if ( !fs.existsSync( cfg.WORKING_DIR ) ) {
		fs.mkdirSync( cfg.WORKING_DIR, { recursive: true } );
	}

	process.chdir( cfg.WORKING_DIR );
	console.log(`Working directory: ${cfg.WORKING_DIR}`);
} catch (err) {
	console.log('chdir: ' + err);
	process.exit(1);
}

// main execution IIFE
(async function () {
	const imageList = await getImagelist( cfg.GITHUB_OAUTH_TOKEN );
	const tagList = await getTagList();
	const versionList = collateTagList( tagList, cfg.VERSION_LIST_SIZE );

	console.log("Image list: ");
	console.log( imageList );

	console.log("Version list: ");
	console.log( versionList );
})();

// =========================== Functions ========================================

/**
 *	Attempts to organize the list of tags in an intelligent way.
 *	Show all editions of the current and previous major version
 *	Show only the the most recent point releases of previous major versions
 */
function collateTagList( tags, size ) {
	const newTagList = [];
	let sizeOffset = 0;

	// sort tags
	tags = tags.reverse();

	// index tags
	const { majorVersions, versions, releases } = indexTags( tags );

	// build new tag list from indexes
	OUT:
	for ( const i in majorVersions ) {
		for ( const [ j, v ] of versions[ majorVersions[ i ] ].entries() ) {
			// If it is the most recent 2 versions, append all of the releases
			if ( i == 0 && j <= 2) {
				sizeOffset = releases[ v ].length;
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
 * Creates indexes with the tags
 */
function indexTags( tags ) {
	const majorVersions = [];
	const versions = {};
	const releases = {};
	let majorVersion, version, release;

	for ( const tag of tags ) {
		if ( !tag.includes( '.' ) ) {
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
 * Gets a list of all the currently available images
 */
async function getImagelist( token ){
	const imageList = [];

	return new Promise( resolve => {
		const https = require( 'https' );
		const req = https.request( getImageApiOptions( token ), res => {
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
					console.warn( 'Could not load remote list of WordPress images.' );
					imageList.push( '5.9', '5.8', '5.7', '5.6' );
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
function getImageApiOptions( token ) {
	return {
		hostname: 'api.github.com',
		port: 443,
		path: '/orgs/Automattic/packages/container/vip-container-images%2Fwordpress/versions?per_page=100&repo=vip-container-images&package_type=container',
		method: 'GET',
		headers: {
			Authorization: `Bearer ${token}`,
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
 * Uses git to stash the current change manifest.
 * Clears any unstaged changes.
 */
async function stash() {
	return await execute( 'git stash' );
}

async function checkoutMasterBranch() {
	const output = await execute( 'git checkout master' );
	const formatted = output.split( "\n" ).map( tag => {
		return tag.replace( /[^0-9.]/, '' );
	} );

	return formatted;
}

async function addVersion( tag ) {
	console.log( `\n == Running "Add Version" Operation on ref: ${tag}  ==` );

	try {
		console.log( `${tag} Version Add operation succeeded.` );
	} catch ( error ) {
		console.log( `"Add Version" failed with error: ${error}` );
	}

	console.log( ` == Finished "Add Version" Operation ( ${tag} )  ==\n` );
}

async function updateVersion( version, tag ) {
	console.log( `\n == Running "Update Version" Operation on version: ${version} to ref: ${tag}  ==` );

	try {
		console.log( `Version: ${version} update to: ${tag} succeeded.` );
	} catch ( error ) {
		console.log( `"Update Version ( ${tag} ) failed with error: ${error}` );
	}

	console.log( ` == Finished "Update Version" Operation ( ${version} )  ==\n` );
}

async function removeVersion( tag ) {
	console.log( `\n == Running "Remove Version" Operation on ref: ${tag}  ==` );

	try {
		console.log( `Version ${tag} remove operation succeeded.` );
	} catch ( error ) {
		console.log( `"Remove Version ( ${tag} )" failed with error: ${error}` );
	}

	console.log( ` == Finished "Remove Version" Operation ( ${version} )  ==\n` );
}
