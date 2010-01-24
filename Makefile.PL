#!/usr/bin/perl

package main;

use 5.006001;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use ExtUtils::Liblist;

my @vars = ExtUtils::Liblist->ext( '-L/sw/lib -ltidy', 0, 1 );
my $libs = $vars[2];

if ( !$libs ) {
    $libs = '-ltidy';
    print <<'EOF';

It seems that you don't have libtidy installed.  HTML::Tidy does no
real work on its own.  See the section "INSTALLING LIBTIDY" in Tidy.pm
for a step-by-step walkthrough of building the lib.  You can also refer
to http://tidy.sourceforge.net/.

If you do have libtidy installed, and I just haven't detected it,
go ahead and try building.  If HTML::Tidy builds and tests correctly,
then please let Andy Lester know at andy@petdance.com so that he can
fix the library detection code.

EOF
}

eval { require LWP::Simple; };

if ( $@ ) {
    print <<'EOF';

NOTE: It seems that you don't have LWP::Simple installed.
      The webtidy program will not be able to retrieve web pages.

EOF
}

WriteMakefile1(
    LICENSE => 'perl',
    MIN_PERL_VERSION => '5.006001',
    META_MERGE => {
        resources => {
            repository => 'http://github.com/petdance/html-tidy',
        },
    },
    #BUILD_REQUIRES => {
    #},

    NAME                => 'HTML::Tidy',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM        => 'lib/HTML/Tidy.pm',
    ABSTRACT_FROM       => 'lib/HTML/Tidy.pm',
    PREREQ_PM           => {
        'Exporter'      => 0,
        'Test::More'    => 0,
        'Test::Builder' => 0,
        'Carp'          => 0,
        'overload'      => 0,
        'constant'      => 0,
    },

    LIBS                => [$libs],
    NEEDS_LINKING       => 1,
    INC                 => '-I. -I/usr/include/tidy -I/usr/local/include/tidy -I/sw/include/tidy',

    EXE_FILES           => [qw(bin/webtidy)],
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HTML-Tidy-*' },
);


sub MY::postamble {
return <<'MAKE_FRAG';
.PHONY: tags critic

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib --exclude=t/lib \
		--exclude=.svn --exclude='*~' \
		--languages=C,Perl --langmap=Perl:+.t \
		.

critic:
	perlcritic -1 \
		-profile perlcriticrc \
		.

MAKE_FRAG
}

sub WriteMakefile1 {  #Written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;
    delete $params{AUTHOR} if $] < 5.005;
    delete $params{ABSTRACT_FROM} if $] < 5.005;
    delete $params{BINARY_LOCATION} if $] < 5.005;

    WriteMakefile(%params);
}

