use 5.012003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'HFR::SeaSonde::FileOps',
    VERSION_FROM      => 'lib/HFR/SeaSonde/FileOps.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/HFR/SeaSonde/FileOps.pm', # retrieve abstract from module
       AUTHOR         => 'Daniel Atwater <dpath2o@macosforge.org>') : ()),
);
