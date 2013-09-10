#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HFR::ACORN' ) || print "Bail out!\n";
}

diag( "Testing HFR::ACORN $HFR::ACORN::VERSION, Perl $], $^X" );
