<?php
$env_file = '/app/.env';

$strong = "\x1B[1m";
$red    = "\x1B[31m";
$green  = "\x1B[32m";
$yellow = "\x1B[33m";
$reset  = "\x1B(B\x1B[m";

if ( is_file( $env_file ) && is_readable( $env_file ) && is_writable( $env_file ) && is_writable( dirname( $env_file ) ) && is_readable( '/wp/wp-load.php' ) ) {
    require_once '/wp/wp-load.php';

    $lines    = file( $env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES );
    $env_vars = [];
    foreach ( $lines as $line ) {
        if ( strpos( $line, '=' ) !== false ) {
            list( $key, $value ) = explode( '=', $line, 2 );
            $key   = trim( $key );
            $value = trim( $value );
            // Double quotes: special characters are ", $, and \. They are escaped with a slash
            // Single quotes: special character is '. It is escaped with a slash
            if ( str_starts_with( $value, '"' ) && str_ends_with( $value, '"' ) ) {
                $value = substr( $value, 1, -1 );
                $value = str_replace( [ '\\"', '\\$', '\\\\', '\\r', '\\n', '\\t' ], [ '"', '$', '\\', "\r", "\n", "\t" ], $value );
            } elseif ( str_starts_with( $value, "'" ) && str_ends_with( $value, "'" ) ) {
                $value = substr( $value, 1, -1 );
                $value = str_replace( "\\'", "'", $value );
            }

            $env_vars[ $key ] = $value;
        }
    }

    $existing_vars = array_filter( get_defined_constants(), fn ( $key ) => str_starts_with( $key, 'VIP_ENV_VAR_' ), ARRAY_FILTER_USE_KEY );
    foreach ( $existing_vars as $key => $value ) {
        if ( ! empty( $env_vars[ $key ] ) && $env_vars[ $key ] !== $value ) {
            fprintf( STDERR, "{$yellow}{$strong}WARNING:{$reset} Environment variable \"%s\" already exists with a different value (\"%s\" vs \"%s\"). Ignoring.\n", $key, $env_vars[ $key ], $value );
        } else {
            $env_vars[ $key ] = $value;
        }
    }

    $env = '';
    foreach ( $env_vars as $key => $value ) {
        if ( ! empty( $value ) ) {
            $value = str_replace( [ '$', '"', '\\', "\r", "\n", "\t" ], [ '\\$', '\\"', '\\\\', '\\r', '\\n', '\\t' ], (string) $value );
            $env  .= sprintf( "%s=\"%s\"\n", $key, $value );
        } else {
            $env .= sprintf( "%s=\n", $key );
        }
    }

    if ( file_put_contents( $env_file . '.tmp', $env ) === false ) {
        fprintf( STDERR, "{$red}{$strong}ERROR:{$reset} Failed to write to %s\n", $env_file );
    } else {
        if ( ! rename( $env_file . '.tmp', $env_file ) ) {
            fprintf( STDERR, "{$red}{$strong}ERROR:{$reset} Failed to rename temporary file to %s\n", $env_file );
        } else {
            printf( "{$green}Environment variables have been successfully updated.{$reset}\n" );
        }
    }
}
