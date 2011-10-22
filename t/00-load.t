#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Async::Hooks' );
}

diag( "Testing Async::Hooks $Async::Hooks::VERSION, Perl $], $^X" );
