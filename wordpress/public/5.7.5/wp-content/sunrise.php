<?php

namespace Automattic\VIP\Sunrise;

/**
 * Nothing to see here for single sites
 */
if ( ! is_multisite() ) {
	return;
}

/**
 * Load sunrise from platform plugins
 */
$sunrise = ABSPATH . 'wp-content/mu-plugins/lib/sunrise/sunrise.php';
if ( file_exists( $sunrise ) ) {
	require_once $sunrise;
}
