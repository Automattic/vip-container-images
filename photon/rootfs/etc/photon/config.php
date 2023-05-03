<?php

define( 'OPTIPNG', '/usr/bin/optipng' );
define( 'PNGQUANT', '/usr/bin/pngquant' );
define( 'CWEBP', '/usr/bin/cwebp' );
define( 'JPEGOPTIM', '/usr/bin/jpegoptim' );

if ( function_exists( 'add_filter' ) ) {
	add_filter( 'override_raw_data_fetch', function ( $_overridden_data, $url ) {
		global $remote_image_max_size;
		if ( preg_match( '!^https?://wp-content/uploads/!', $url ) && ! empty( $_SERVER['DOCUMENT_ROOT'] ) ) {
			$path = realpath( preg_replace( '!^https?://wp-content!', $_SERVER['DOCUMENT_ROOT'], $url ) );
			if ( str_starts_with( $path, $_SERVER['DOCUMENT_ROOT'] ) ) {
				if ( isset( $remote_image_max_size ) && $remote_image_max_size > 0 ) {
					$size = filesize( $path );
					if ( $size > $remote_image_max_size ) {
						return false;
					}
				}

				return file_get_contents( $path );
			}
		}

		return false;
	}, 10, 2 );
}
