<?php

add_filter( 'set_url_scheme', function( $url ) {
    $proto = $_SERVER[ 'HTTP_X_FORWARDED_PROTO' ] ?? '';

    if ( 'https' == $proto ) {
        return str_replace( 'http://', 'https://', $url );
    }
    return $url;
});

// Disable Two_Factor_FIDO_U2F Profider for the dev-env
add_filter('two_factor_providers', function( $providers ) {
    unset( $providers['Two_Factor_FIDO_U2F'] );
    return $providers;
});
