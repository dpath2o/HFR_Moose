#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HFR::ACORN::Gridding' ) || print "Bail out!\n";
}

diag( "Testing HFR::ACORN::Gridding $HFR::ACORN::Gridding::VERSION, Perl $], $^X" );
