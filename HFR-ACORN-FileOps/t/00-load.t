#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'HFR::ACORN::FileOps' ) || print "Bail out!\n";
}

diag( "Testing HFR::ACORN::FileOps $HFR::ACORN::FileOps::VERSION, Perl $], $^X" );
