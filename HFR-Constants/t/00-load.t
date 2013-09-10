#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HFR::Constants' ) || print "Bail out!\n";
}

diag( "Testing HFR::Constants $HFR::Constants::VERSION, Perl $], $^X" );
