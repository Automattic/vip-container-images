<?php

define( 'OPTIPNG', '/usr/bin/optipng' );
define( 'PNGQUANT', '/usr/bin/pngquant' );
define( 'PNGCRUSH', '/usr/bin/pngcrush' );
define( 'CWEBP', '/usr/bin/cwebp' );
define( 'JPEGOPTIM', '/usr/bin/jpegoptim' );
define( 'JPEGTRAN', '/usr/bin/jpegtran' );

if ( function_exists( 'add_filter' ) ) {
	add_filter( 'override_raw_data_fetch', function ( $_overridden_data, $url ) {
		global $remote_image_max_size;

		if ( empty( $_SERVER['DOCUMENT_ROOT'] ) ) {
			return $_overridden_data;
		}

		/*
		 * Photon builds a synthetic URL from REQUEST_URI (path is used as the "host"):
		 * Example: https://wp-content/uploads/sites/2/2026/05/image.jpg (subdomain)
		 * Example: https://test/wp-content/uploads/sites/2/2026/05/image.jpg (subdirectory blog at /test/)
		 * Map to DOCUMENT_ROOT/uploads/... (wp-content/uploads is mounted at photon/uploads).
		 */
		if ( ! preg_match( '!/wp-content/uploads/([^?]+)!', $url, $matches ) ) {
			return $_overridden_data;
		}

		$document_root = realpath( $_SERVER['DOCUMENT_ROOT'] );

		if ( false === $document_root ) {
			return $_overridden_data;
		}

		$path = realpath( $document_root . '/uploads/' . $matches[1] );
		
		if ( false === $path || ! str_starts_with( $path, $document_root ) ) {
			return $_overridden_data;
		}

		if ( isset( $remote_image_max_size ) && $remote_image_max_size > 0 ) {
			$size = filesize( $path );
			if ( $size > $remote_image_max_size ) {
				return false;
			}
		}

		return file_get_contents( $path );
	}, 10, 2 );
}
