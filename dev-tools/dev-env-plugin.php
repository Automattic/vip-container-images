<?php

/******************
 * Handle HTTPS
 ******************/

add_filter( 'set_url_scheme', function( $url ) {
	$proto = $_SERVER[ 'HTTP_X_FORWARDED_PROTO' ] ?? '';

	if ( 'https' == $proto ) {
		return str_replace( 'http://', 'https://', $url );
	}
	return $url;
});

/**
 * In some scenarios https is not correctly detected. That leads to infinite redirect to https.
 * Infinite because you already are on https
 */
add_filter( 'redirect_canonical', function( $redirect_url, $requested_url ) {
	$https_request_version    = str_replace( 'http://', 'https://', $requested_url );
	$is_redirecting_for_https = $https_request_version === $redirect_url;
	if ( $is_redirecting_for_https ) {
		return;
	}

	return $redirect_url;
}, 10, 2);

/******************
 * 2FA
 ******************/

// Disable Two_Factor_FIDO_U2F Profider for the dev-env
add_filter('two_factor_providers', function( $providers ) {
	unset( $providers['Two_Factor_FIDO_U2F'] );
	return $providers;
});

add_filter( 'wpcom_vip_is_two_factor_forced', '__return_false' );

/******************
 * ADMIN USER CREATION
 ******************/

if ( defined( 'WP_CLI' ) && WP_CLI ) {
	WP_CLI::add_command( 'dev-env-add-admin', 'dev_env_add_admin' );
}

/**
 * Creates an admin user
 *
 * ## OPTIONS
 *
 * [--username]
 * : New user username
 *
 * [--password]
 * : New user password
 *
 * [--email]
 * : [optional] New user email
 *
 * ## EXAMPLE
 * wp dev-env-add-admin --username=vipgo --password=test
 */
function dev_env_add_admin( $args, $assoc_args ) {
	$username = $assoc_args['username'] ?? '';
	$password = $assoc_args['password'] ?? '';
	$email = $assoc_args['email'] ?? $username . '@go-vip.net';

	if ( ! $username || ! $password ) {
		WP_CLI::error( 'Both username and password need to be provided!' );
	}

	if ( username_exists( $username ) ) {
		WP_CLI::line( 'User "' . $username . '" already exits. Skipping creating it.' );
		return;
	}

	WP_CLI::runcommand( 'user create ' . $username . ' ' . $email . ' --user_pass=' . $password . ' --role=administrator' );
	WP_CLI::success( 'User "' . $username . '" created.' );

	if ( is_multisite() ) {
		// on multisite we do more setup
		WP_CLI::runcommand( 'super-admin add ' . $username );
		WP_CLI::success( 'User "' . $username . '" added to super-admin list.' );

		$sites = get_sites();
		foreach ( $sites as $site ) {
			switch_to_blog( $site->blog_id );
			$subsite_url = home_url();

			WP_CLI::runcommand( 'user set-role ' . $username . ' administrator --url=' . $subsite_url );

			restore_current_blog();
		}
	}
}
