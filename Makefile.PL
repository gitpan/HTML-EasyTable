use 5.006;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'HTML::EasyTable',
    VERSION_FROM      => 'lib/HTML/EasyTable.pm', 
    PREREQ_PM         => {}, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/HTML/EasyTable.pm',
       AUTHOR         => 'A. N. Kolev <meneldor@gmail.com>') : ())
);
