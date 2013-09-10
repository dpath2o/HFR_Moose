#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HFR::GMT' ) || print "Bail out!\n";
}

diag( "Testing HFR::GMT $HFR::GMT::VERSION, Perl $], $^X" );
