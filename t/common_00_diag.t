use strict;
use warnings;
use Test::More tests => 1;
use File::Basename qw( dirname );
use File::Spec;

use_ok 'Archive::Libarchive::XS';

my $fn;
my $not_first;

$fn = File::Spec->catfile(
  dirname( __FILE__ ),
  File::Spec->updir,
  'inc',
  'constants.txt'
);

$not_first = 0;

diag '';
diag '';

foreach my $const (do { open my $fh, '<', $fn; <$fh> })
{
  chomp $const;
  unless(Archive::Libarchive::XS->can($const))
  {
    diag "missing constants:" unless $not_first++;
    diag " - $const";
  }
}

diag '';
diag '';

$fn = File::Spec->catfile(
  dirname( __FILE__ ),
  File::Spec->updir,
  'inc',
  'functions.txt'
);

$not_first = 0;

foreach my $func (do { open my $fh, '<', $fn; <$fh> })
{
  chomp $func;
  unless(Archive::Libarchive::XS->can($func))
  {
    diag "missing functions:" unless $not_first++;
    diag " - $func";
  }
}

eval q{ use Archive::Libarchive::XS };
diag $@ if $@;

diag '';
diag '';

diag 'archive_perl_codeset:   ' . eval q{ Archive::Libarchive::XS::archive_perl_codeset() };
diag $@ if $@;
diag 'archive_perl_utf8_mode: ' . eval q{ Archive::Libarchive::XS::archive_perl_utf8_mode() };
diag $@ if $@;

diag '';
diag '';
