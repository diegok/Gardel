#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Gardel' );
}

diag( "Testing Gardel $Gardel::VERSION, Perl $], $^X" );
