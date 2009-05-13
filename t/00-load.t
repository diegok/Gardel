#!perl -T

use Test::More tests => 1;

$ENV{GARDEL_TEST}++;

BEGIN {
	use_ok( 'Gardel' );
}

diag( "Testing Gardel $Gardel::VERSION, Perl $], $^X" );
