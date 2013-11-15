use strict;
use warnings;
use v5.10;
use Alien::Libarchive;
use Path::Class qw( file dir );

my $alien = Alien::Libarchive->new;

my @macros = do { # constants

  # keep any new macros, even if we are doing a dzil build
  # against an old libarchive
  # TODO: warn if we find a missing constant.
  my %macros = (map { chomp; $_ => 1 } file(__FILE__)->parent->file('constants.txt')->slurp, grep { $_ ne 'ARCHIVE_VERSION_STRING' } grep { $_ !~ /H_INCLUDED$/ } $alien->_macro_list);
  sort keys %macros;  
};
file(__FILE__)->parent->file('constants.txt')->spew(join "\n", @macros);

do { # xs
  my $file = file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.xs ))->absolute;
  my @xs = $file->slurp;

  my $buffer;
  
  $buffer .= shift @xs while @xs > 0 && $xs[0] !~ /CONSTANT AUTOGEN BEGIN/;
  $buffer .= "        /* CONSTANT AUTOGEN BEGIN */\n";
  shift @xs while @xs > 0 && $xs[0] !~ /CONSTANT AUTOGEN END/;
  
  foreach my $macro (@macros)
  {
    next if $macro eq 'ARCHIVE_OK';
    $buffer .= "#ifdef $macro\n";
    $buffer .= "        else if(!strcmp(name, \"$macro\"))\n";
    $buffer .= "          RETVAL = $macro;\n";
    $buffer .= "#endif\n";
                      
  }

  $buffer .= shift @xs while @xs > 0 && $xs[0] !~ /PURE AUTOGEN BEGIN/;
  
  $buffer .= "/* PURE AUTOGEN BEGIN */\n";
  $buffer .= "/* Do not edit anything below this line as it is autogenerated\n";
  $buffer .= "and will be lost the next time you run dzil build */\n\n";
  
  foreach my $filter (sort qw( bzip2 compress gzip grzip lrzip lzip lzma lzop none ))
  {
    $buffer .= "=head2 archive_read_support_filter_$filter(\$archive)\n\n";
    $buffer .= "Enable $filter decompression filter.\n\n";
    $buffer .= "=cut\n\n";
    #$buffer .= "#ifdef ARCHIVE_FILTER_" . uc($filter) . "\n\n";
    $buffer .= "int\n";
    $buffer .= "archive_read_support_filter_$filter(archive)\n";
    $buffer .= "    struct archive *archive\n\n";
    #$buffer .= "#endif\n\n";
  }
  
  foreach my $format (sort qw( 7zip ar cab cpio empty gnutar iso9660 lha mtree rar raw tar xar zip ))
  {
    $buffer .= "=head2 archive_read_support_format_$format(\$archive)\n\n";
    $buffer .= "Enable $format archive format.\n\n";
    $buffer .= "=cut\n\n";
    #$buffer .= "#ifdef ARCHIVE_FORMAT_" . uc($format) ."\n\n";
    $buffer .= "int\n";
    $buffer .= "archive_read_support_format_$format(archive)\n";
    $buffer .= "    struct archive *archive\n\n";
    #$buffer .= "#endif\n\n";
  }

  foreach my $filter (sort qw( b64encode bzip2 compress grzip gzip lrzip lzip lzma lzop none uuencode xz ))
  {
    $buffer .= "=head2 archive_write_add_filter_$filter(\$archive)\n\n";
    $buffer .= "Add $filter filter\n\n";
    $buffer .= "=cut\n\n";
    #$buffer .= "#ifdef ARCHIVE_FILTER_" . uc($filter) . "\n\n";
    $buffer .= "int\n";
    $buffer .= "archive_write_add_filter_$filter(archive)\n";
    $buffer .= "    struct archive *archive\n\n";
    #$buffer .= "#endif\n\n";
  }
  
  foreach my $format (sort qw( 7zip ar_bsd ar_svr4 cpio cpio_newc gnutar iso9660 mtree mtree_classic pax pax_restricted shar shar_dump ustar v7tar xar zip ))
  {
    $buffer .= "=head2 archive_write_set_format_$format(\$archive)\n\n";
    $buffer .= "Set the archive format to $format\n\n";
    $buffer .= "=cut\n\n";
    #$buffer .= "#ifdef ARCHIVE_FORMAT_" . uc($format) ."\n\n";
    $buffer .= "int\n";
    $buffer .= "archive_write_set_format_$format(archive)\n";
    $buffer .= "    struct archive *archive\n\n";
    #$buffer .= "#endif\n\n";
    
  }
  
  $file->spew($buffer);
};

do {
  use Pod::Abstract;
  use Mojo::Template;
  use JSON qw( to_json );
  my $mt = Mojo::Template->new;
  
  my $pa = Pod::Abstract->load_file(
    file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.xs ))->stringify
  );
  
  $_->detach for $pa->select('//#cut');
  
  my %functions;
  
  foreach my $pod ($pa->children)
  {
    if($pod->pod =~ /^=head2 ([A-Za-z_0-9]+)/)
    {
      my $name = $1;
      $functions{$name} = $pod->pod;
      $functions{$name} =~ s/\s+$//;
    }
    else
    {
      die "error parsing " .  $pod->text;
    }
  }
  
  $mt->prepend(qq{
    use JSON qw( from_json );
    my \$functions = from_json(q[} . to_json(\%functions) . qq{]);
    my \$constants = from_json(q[} . to_json(\@macros) . qq{] );
  });
  
  my $perl = $mt->render( scalar file(__FILE__)->parent->file(qw( XS.pm.template ))->slurp );

  my $file = file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.pm ))->absolute;
  $file->spew($perl);
};

