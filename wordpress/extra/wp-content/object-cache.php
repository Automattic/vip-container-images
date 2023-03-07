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

 if ( ! defined( 'WPMU_PLUGIN_DIR' ) ) {
	define( 'WPMU_PLUGIN_DIR', WP_CONTENT_DIR . '/mu-plugins' );
}

$mu_plugins_file = ABSPATH . '/wp-content/mu-plugins/drop-ins/object-cache.php';
if ( file_exists( $mu_plugins_file ) ) {
	require_once $mu_plugins_file;
} else {
	// Fallback if the drop-in file is not present.
	$fallback_file = __DIR__ . '/object-cache-stable.php';
	if ( file_exists( $fallback_file ) ) {
		require_once $fallback_file;
	}
	$apc_file = ABSPATH . '/wp-content/mu-plugins/lib/class-apc-cache-interceptor.php';
	if ( file_exists( $apc_file ) ) {
		require_once $apc_file;
	}
}
