<?php
// Integration tests: run only against the disposable database/cache in the test Compose project.
mysqli_report( MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT );
$db = new mysqli( 'database', 'wordpress', 'wordpress', 'wordpress' );
$cache = new Memcached();
$cache->addServer( 'memcached', 11211 );
$options = [ 'jetpack_options', 'jetpack_private_options', 'jetpack_secrets', 'vaultpress', 'wordpress_api_key', 'vip_jetpack_connection_pilot_heartbeat' ];
$cache_unavailable = in_array( '--cache-unavailable', $argv, true );
$tables = [ 'wp_options', 'custom_2_options', 'orphan_options', 'odd`options' ];

function check( $condition, $message ) {
	if ( ! $condition ) {
		throw new RuntimeException( $message );
	}
}

function seed() {
	global $db, $cache, $tables, $options, $cache_unavailable;
	foreach ( $tables as $table ) {
		$table = '`' . str_replace( '`', '``', $table ) . '`';
		$db->query( "DROP TABLE IF EXISTS $table" );
		$db->query( "CREATE TABLE $table (option_id bigint PRIMARY KEY AUTO_INCREMENT, option_name varchar(191), option_value longtext, autoload varchar(20)) ENGINE=InnoDB" );
		foreach ( array_merge( $options, [ 'blogname', 'jetpack_local_settings', 'jetpack_options_backup' ] ) as $option ) {
			$name = $db->real_escape_string( $option );
			$db->query( "INSERT INTO $table (option_name, option_value, autoload) VALUES ('$name', 'fixture', 'yes')" );
		}
	}
	$db->query( 'CREATE TABLE IF NOT EXISTS unrelated_options (id int)' );
	if ( ! $cache_unavailable ) {
		check( $cache->set( 'main-options', 'imported-credentials' ), 'Cache fixture unavailable' );
		check( $cache->set( 'subsite-options', 'imported-credentials' ), 'Cache fixture unavailable' );
	}
}

function run_cleanup() {
	exec( escapeshellarg( PHP_BINARY ) . ' /dev-tools/import-cleanup.php 2>&1', $output, $status );
	return [ $status, implode( "\n", $output ) ];
}

function check_rows( $expected ) {
	global $db, $tables;
	foreach ( $tables as $table ) {
		$table = '`' . str_replace( '`', '``', $table ) . '`';
		$names = array_column( $db->query( "SELECT option_name FROM $table ORDER BY option_name" )->fetch_all( MYSQLI_ASSOC ), 'option_name' );
		sort( $expected );
		check( $names === $expected, "Unexpected rows in $table: " . json_encode( $names ) );
	}
}

seed();
[ $status, $output ] = run_cleanup();
if ( $cache_unavailable ) {
	check( 0 !== $status && str_contains( $output, 'cache flush failed' ), "Expected cache failure: $output" );
	check_rows( [ 'blogname', 'jetpack_local_settings', 'jetpack_options_backup' ] );
	echo "PASS: cache failure reports failure after database deletion\n";
	exit( 0 );
}
check( 0 === $status, "Cleanup failed: $output" );
check_rows( [ 'blogname', 'jetpack_local_settings', 'jetpack_options_backup' ] );
check( false === $cache->get( 'main-options' ) && false === $cache->get( 'subsite-options' ), 'Cache retained imported options' );
check( 0 === run_cleanup()[0], 'Cleanup is not idempotent' );
echo "PASS: all options tables sanitized, other options preserved, cache flushed, idempotent\n";

seed();
$db->query( "CREATE TRIGGER refuse_cleanup BEFORE DELETE ON wp_options FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fixture refuses deletion'" );
[ $status, $output ] = run_cleanup();
check( 0 !== $status && str_contains( $output, 'fixture refuses deletion' ), "Expected SQL failure: $output" );
check_rows( array_merge( $options, [ 'blogname', 'jetpack_local_settings', 'jetpack_options_backup' ] ) );
check( 'imported-credentials' === $cache->get( 'main-options' ), 'Cache flushed after SQL failure' );
echo "PASS: SQL failure rolls back deletions and reports failure\n";
