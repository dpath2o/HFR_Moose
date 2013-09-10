use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HFR::ACORN::FileOps',
    AUTHOR              => q{Atwater, Daniel Patrick Lewis <danielpath2o@gmail.com>},
    VERSION_FROM        => 'lib/HFR/ACORN/FileOps.pm',
    ABSTRACT_FROM       => 'lib/HFR/ACORN/FileOps.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HFR-ACORN-FileOps-*' },
);
