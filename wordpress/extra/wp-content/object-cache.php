<?php

/**
 * Plugin Name: Memcached
 * Description: Memcached backend for the WP Object Cache.
 * Version: 4.0.0
 * Author: Automattic
 * Plugin URI: https://wordpress.org/plugins/memcached/
 * License: GPLv2 or later
 *
 * This file is require'd from wp-content/object-cache.php
 */

define( 'VIP_OBJECT_CACHE_DROPIN_STABLE', __DIR__ .'/object-cache-stable.php' );
define( 'VIP_OBJECT_CACHE_DROPIN_NEXT', __DIR__ .'/object-cache-next.php' );

// Will use the "next" version on these specified environment types by default.
if ( ! defined( 'VIP_USE_NEXT_OBJECT_CACHE_DROPIN' ) ) {
	if ( in_array( VIP_GO_APP_ENVIRONMENT, [ 'develop', 'preprod', 'staging' ], true ) ) {
		define( 'VIP_USE_NEXT_OBJECT_CACHE_DROPIN', true );
	}
}

if ( defined( 'VIP_USE_ALPHA_OBJECT_CACHE_DROPIN' ) && true === VIP_USE_ALPHA_OBJECT_CACHE_DROPIN ) {
	$mu_plugins_file = ABSPATH . '/wp-content/mu-plugins/drop-ins/wp-memcached/object-cache.php';
	// Fallback to the stable object-cache version since the mu-plugins file doesn't exist
	$fallback_file = VIP_OBJECT_CACHE_DROPIN_STABLE;
} elseif ( defined( 'VIP_USE_NEXT_OBJECT_CACHE_DROPIN' ) && true === VIP_USE_NEXT_OBJECT_CACHE_DROPIN ) {
	$mu_plugins_file = ABSPATH . '/wp-content/mu-plugins/drop-ins/object-cache/object-cache-next.php';
	$fallback_file = VIP_OBJECT_CACHE_DROPIN_NEXT;
} else {
	$mu_plugins_file = ABSPATH . '/wp-content/mu-plugins/drop-ins/object-cache/object-cache-stable.php';
	$fallback_file = VIP_OBJECT_CACHE_DROPIN_STABLE;
}

if ( file_exists( $mu_plugins_file ) ) {
	require_once $mu_plugins_file;
} else {
	require_once $fallback_file;
}

// Load in the apc user cache.
if ( file_exists( ABSPATH . '/wp-content/mu-plugins/lib/class-apc-cache-interceptor.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/lib/class-apc-cache-interceptor.php';
}
