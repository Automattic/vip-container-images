<?php
/**
 * These are baseline configs that are identical across all Go environments.
 */

/**
 * Override WP_HOME and WP_SITEURL with the values from $_SERVER['HTTP_HOST'] if it's set.
 *
 * This is needed for the cases where something is already bound to default 80 or 443 ports and Lando's proxy falls back onto a different available port.
 * Defining these constants allows us to force WordPress to use the proper port instead of the default.
 *
 * phpcs:disable WordPress.Security.ValidatedSanitizedInput.MissingUnslash,WordPress.Security.ValidatedSanitizedInput.InputNotSanitized
 */
if ( isset( $_SERVER['HTTP_HOST'] ) && count( explode( ':', $_SERVER['HTTP_HOST'] ) ) === 2 ) {
	$proto = $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? 'http';
	define( 'WP_HOME', $proto . '://' . $_SERVER['HTTP_HOST'] );
	define( 'WP_SITEURL', $proto . '://' . $_SERVER['HTTP_HOST'] );
}

 /**
 * Read-only filesystem
 */
if ( ! defined( 'DISALLOW_FILE_EDIT' ) ) {
	define( 'DISALLOW_FILE_EDIT', true );
}

if ( ! defined( 'DISALLOW_FILE_MODS' ) ) {
	define( 'DISALLOW_FILE_MODS', true );
}

if ( ! defined( 'AUTOMATIC_UPDATER_DISABLED' ) ) {
	define( 'AUTOMATIC_UPDATER_DISABLED', true );
}

// Server limits
if ( ! defined( 'WP_MAX_MEMORY_LIMIT' ) ) {
	define( 'WP_MAX_MEMORY_LIMIT', '512M' );
}

/**
 * Error Handler
 *
 * Load custom error logging functions, if available.
 */
if ( file_exists( ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php';
}

/**
 * Cron Control
 */
if ( ! defined( 'WPCOM_VIP_LOAD_CRON_CONTROL_LOCALLY' ) ) {
	define( 'WPCOM_VIP_LOAD_CRON_CONTROL_LOCALLY', true );
}

if ( ! defined( 'WP_CRON_CONTROL_SECRET' ) ) {
	define( 'WP_CRON_CONTROL_SECRET', 'this-is-a-secret' );
}

/**
 * VIP Env variables
 */
if ( ! defined( 'WPCOM_IS_VIP_ENV' ) ) {
	define( 'WPCOM_IS_VIP_ENV', false );
}

if ( ! defined( 'FILES_CLIENT_SITE_ID' ) ) {
	define( 'FILES_CLIENT_SITE_ID', 200508 );
}

if ( ! defined( 'VIP_GO_APP_ENVIRONMENT' ) ) {
	define( 'VIP_GO_APP_ENVIRONMENT', 'local' );
}

/**
 * VIP Config
 */
if ( file_exists( ABSPATH . '/wp-content/vip-config/vip-config.php' ) ) {
	require_once( ABSPATH . '/wp-content/vip-config/vip-config.php' );
}

/**
 * Enterprise Search
 */
/*
// Uncomment following code in order to enable Enterprise Search
if ( ! defined( 'VIP_ENABLE_VIP_SEARCH' ) ) {
	define( 'VIP_ENABLE_VIP_SEARCH', true );
}

if ( ! defined( 'VIP_ENABLE_ELASTICSEARCH_QUERY_INTEGRATION' ) ) {
	define( 'VIP_ENABLE_ELASTICSEARCH_QUERY_INTEGRATION', true );
}
*/

if ( ! defined( 'VIP_ELASTICSEARCH_ENDPOINTS' ) ) {
	define( 'VIP_ELASTICSEARCH_ENDPOINTS', [
		'http://vip-search:9200',
	] );
}

if ( ! defined( 'VIP_ELASTICSEARCH_USERNAME' ) ) {
	define( 'VIP_ELASTICSEARCH_USERNAME', 'test_user' );
}

if ( ! defined( 'VIP_ELASTICSEARCH_PASSWORD' ) ) {
	define( 'VIP_ELASTICSEARCH_PASSWORD', 'test_password' );
}

/**
 * StatsD
 */

if ( ! defined( 'VIP_DISABLE_STATSD' ) ) {
	define( 'VIP_DISABLE_STATSD', getenv( 'STATSD' ) === 'disable' );
}

if ( ! defined( 'VIP_STATSD_HOST' ) ) {
	define( 'VIP_STATSD_HOST', 'statsd' );
}

if ( ! defined( 'VIP_STATSD_PORT' ) ) {
	define( 'VIP_STATSD_PORT', 8126 );
}

/**
 * Needed for local SSL setup
 */
if ( ! defined( 'FORCE_SSL_ADMIN' ) ) {
	define( 'FORCE_SSL_ADMIN', false );
}
