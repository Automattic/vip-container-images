<?php

add_filter( 'set_url_scheme', function( $url ) {
    $proto = $_SERVER[ 'HTTP_X_FORWARDED_PROTO' ] ?? '';

    if ( 'https' == $proto ) {
        return str_replace( 'http://', 'https://', $url );
    }
    return $url;
});

// Limited Two-Factor Profiders for the dev-env
add_filter('two_factor_providers', function() {
    return array(
        'Two_Factor_Email'        => TWO_FACTOR_DIR . 'providers/class-two-factor-email.php',
        'Two_Factor_Totp'         => TWO_FACTOR_DIR . 'providers/class-two-factor-totp.php',
        'Two_Factor_Backup_Codes' => TWO_FACTOR_DIR . 'providers/class-two-factor-backup-codes.php',
        'Two_Factor_Dummy'        => TWO_FACTOR_DIR . 'providers/class-two-factor-dummy.php',
    );
});
