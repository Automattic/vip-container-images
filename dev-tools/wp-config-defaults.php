<?php
/**
 * These are baseline configs that are identical across all Go environments.
 */

/**
 * Adjust HTTP_HOST for GitHub Codespaces.
 */
if ( isset( $_SERVER['CODESPACES'] ) && 'true' === $_SERVER['CODESPACES'] && ! empty( $_SERVER['HTTP_X_FORWARDED_HOST'] ) ) {
	$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}

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
 * Parity with Go's wp-config.php
 */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

if ( file_exists( ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/lib/wpcom-error-handler/wpcom-error-handler.php';
}

// Load VIP_Request_Block utility class, if available
if ( file_exists( ABSPATH . '/wp-content/mu-plugins/lib/class-vip-request-block.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/lib/class-vip-request-block.php';
}

$_SERVER['REMOTE_ADDR_ORIG'] = $_SERVER['REMOTE_ADDR'];


if ( isset( $_SERVER['HTTP_X_FORWARDED_PROTO'] ) && strstr( $_SERVER['HTTP_X_FORWARDED_PROTO'], 'https' ) ) {
	$_SERVER['HTTPS'] = 'on';
}

if ( isset( $_SERVER['HTTP_X_FORWARDED_PORT'] ) && is_numeric( $_SERVER['HTTP_X_FORWARDED_PORT'] ) ) {
	$_SERVER['SERVER_PORT'] = intval( $_SERVER['HTTP_X_FORWARDED_PORT'] );
}

if ( isset( $_SERVER['HTTP_X_FORWARDED_FOR'] ) &&
	( filter_var( $_SERVER['HTTP_X_FORWARDED_FOR'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV4 ) ||
		filter_var( $_SERVER['HTTP_X_FORWARDED_FOR'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV6 ) ) ) {
	$_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_FORWARDED_FOR'];
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
 * Pre VIP Config
 *
 * Load required files before the VIP config is loaded.
 */
if ( file_exists( ABSPATH . '/wp-content/mu-plugins/000-pre-vip-config/requires.php' ) ) {
	require_once ABSPATH . '/wp-content/mu-plugins/000-pre-vip-config/requires.php';
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
define( 'WPCOM_IS_VIP_ENV', false );
define( 'FILES_CLIENT_SITE_ID', 200508 );

define( 'VIP_GO_APP_ENVIRONMENT', 'local' );
define( 'VIP_GO_ENV', 'local' );

/**
 * VIP Config
 */
if ( file_exists( ABSPATH . '/wp-content/vip-config/vip-config.php' ) ) {
	require_once( ABSPATH . '/wp-content/vip-config/vip-config.php' );
}

/**
 * Enterprise Search
 */
if ( ! defined( 'VIP_ELASTICSEARCH_ENDPOINTS' ) ) {
	define( 'VIP_ELASTICSEARCH_ENDPOINTS', [
		'http://elasticsearch:9200',
	] );
}

if ( ! defined( 'VIP_ELASTICSEARCH_USERNAME' ) ) {
	define( 'VIP_ELASTICSEARCH_USERNAME', 'test_user' );
}

if ( ! defined( 'VIP_ELASTICSEARCH_PASSWORD' ) ) {
	define( 'VIP_ELASTICSEARCH_PASSWORD', 'test_password' );
}

/**
 * Needed for local SSL setup
 */
if ( ! defined( 'FORCE_SSL_ADMIN' ) ) {
	define( 'FORCE_SSL_ADMIN', false );
}

// Avoid potential IDC
if ( ! defined( 'JETPACK_STAGING_MODE' ) ) {
	define( 'JETPACK_STAGING_MODE', true );
}
