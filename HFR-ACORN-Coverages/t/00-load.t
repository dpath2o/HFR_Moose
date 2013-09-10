#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HFR::ACORN::Coverages' ) || print "Bail out!\n";
}

diag( "Testing HFR::ACORN::Coverages $HFR::ACORN::Coverages::VERSION, Perl $], $^X" );
