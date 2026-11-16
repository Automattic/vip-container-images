<?php
/** Remove imported connection credentials before any WordPress command runs. */
if ( 'cli' !== PHP_SAPI ) {
	exit( 1 );
}

mysqli_report( MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT );
$db = null;
$in_transaction = false;
try {
	// These are the local dev-env service credentials, independent of wp-config or Jetpack.
	$db = new mysqli( 'database', 'wordpress', 'wordpress', 'wordpress' );
	$tables = $db->query( "SELECT TABLE_NAME FROM information_schema.COLUMNS
		WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME LIKE '%options'
		AND COLUMN_NAME IN ('option_id', 'option_name', 'option_value', 'autoload')
		GROUP BY TABLE_NAME HAVING COUNT(DISTINCT COLUMN_NAME) = 4 ORDER BY TABLE_NAME" );
	$options = "'jetpack_options', 'jetpack_private_options', 'jetpack_secrets',
		'vaultpress', 'wordpress_api_key', 'vip_jetpack_connection_pilot_heartbeat'";

	$db->begin_transaction();
	$in_transaction = true;
	foreach ( $tables as $row ) {
		$table = '`' . str_replace( '`', '``', $row['TABLE_NAME'] ) . '`';
		$db->query( "DELETE FROM $table WHERE option_name IN ($options)" );
	}
	$db->commit();
	$in_transaction = false;

	// Raw SQL cannot invalidate cached options. Flush before WordPress can read them.
	$cache = new Memcached();
	$cache->addServer( 'memcached', 11211 );
	if ( ! $cache->flush() ) {
		throw new RuntimeException( 'Local object cache flush failed: ' . $cache->getResultMessage() );
	}
} catch ( Throwable $error ) {
	if ( $in_transaction ) {
		try {
			$db->rollback();
		} catch ( Throwable $rollback_error ) {
			// Preserve the original failure if the database connection was lost.
		}
	}
	fwrite( STDERR, 'Local import credential cleanup failed: ' . $error->getMessage() . "\n" );
	exit( 1 );
}
