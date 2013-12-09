use strict;
use warnings;
use Test::More tests => 48;
use Archive::Libarchive::XS qw( :all );

my $r;

my $e = archive_entry_new();
ok $e, 'archive_entry_new';

is archive_entry_pathname($e), undef, 'archive_entry_pathname = undef';

$r = archive_entry_set_pathname($e, 'hi.txt');
is $r, ARCHIVE_OK, 'archive_entry_set_pathname';

is archive_entry_pathname($e), 'hi.txt', 'archive_entry_pathname = hi.txt';

is eval { archive_entry_mode($e) }, 0, 'archive_entry_mode (0)';
diag $@ if $@;

$r = eval { archive_entry_set_mode($e, 0644) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_mode';

is eval { archive_entry_mode($e) }, 0644, 'archive_entry_mode (0644)';
diag $@ if $@;

$r = eval { archive_entry_set_filetype($e, AE_IFREG) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_filetype';

is eval { archive_entry_filetype($e) }, AE_IFREG, 'archive_entry_filetype';
diag $@ if $@;

is eval { archive_entry_strmode($e) }, '-rw-r--r-- ', 'archive_entry_strmode';

is archive_entry_uid($e), 0, 'archive_entry_uid = 0';
$r = archive_entry_set_uid($e, 101);
is $r, ARCHIVE_OK, 'archive_entry_set_uid';
is archive_entry_uid($e), 101, 'archive_entry_uid = 101';

is eval { archive_entry_gid($e) }, 0, 'archive_entry_gid = 0';
diag $@ if $@;
$r = eval { archive_entry_set_gid($e, 201) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_gid';
is eval { archive_entry_gid($e) }, 201, 'archive_entry_gid = 201';
diag $@ if $@;

$r = archive_entry_set_nlink($e, 5);
is $r, ARCHIVE_OK, 'archive_entry_set_nlink';

is eval { archive_entry_nlink($e) }, 5, 'archive_entry_nlink';
diag $@ if $@;

ok !archive_entry_dev_is_set($e), 'archive_entry_dev_is_set';
$r = archive_entry_set_devmajor($e, 0x24);
is $r, ARCHIVE_OK, 'archive_entry_devmajor';
is archive_entry_devmajor($e), 0x24, 'archive_entry_devmajor';
$r = archive_entry_set_devminor($e, 0x67);
is $r, ARCHIVE_OK, 'archive_entry_set_devminor';
is archive_entry_devminor($e), 0x67, 'archive_entry_devminor';
is archive_entry_dev($e), 0x2467, 'archive_entry_dev';
ok archive_entry_dev_is_set($e), 'archive_entry_dev_is_set';

$r = archive_entry_set_dev($e, 0x1234);
is $r, ARCHIVE_OK, 'archive_entry_set_dev';
is archive_entry_dev($e), 0x1234, 'archive_entry_dev';

ok !eval { archive_entry_ino_is_set($e) }, 'archive_entry_ino_is_set';
diag $@ if $@;
$r = archive_entry_set_ino($e, 0x12);
is $r, ARCHIVE_OK, 'archive_entry_set_ino';
is archive_entry_ino($e), 0x12, 'archive_entry_ino';
ok eval { archive_entry_ino_is_set($e) }, 'archive_entry_ino_is_set';
diag $@ if $@;

$r = archive_entry_set_rdevmajor($e, 0x24);
is $r, ARCHIVE_OK, 'archive_entry_rdevmajor';
is archive_entry_rdevmajor($e), 0x24, 'archive_entry_rdevmajor';
$r = archive_entry_set_rdevminor($e, 0x67);
is $r, ARCHIVE_OK, 'archive_entry_set_rdevminor';
is archive_entry_rdevminor($e), 0x67, 'archive_entry_rdevminor';
is archive_entry_rdev($e), 0x2467, 'archive_entry_rdev';

$r = archive_entry_set_rdev($e, 0x1234);
is $r, ARCHIVE_OK, 'archive_entry_set_rdev';
is archive_entry_rdev($e), 0x1234, 'archive_entry_rdev';

$r = eval { archive_entry_set_atime($e, 123456789, 123456789) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_atime';
is eval { archive_entry_atime($e) }, 123456789, 'archive_entry_atime';
diag $@ if $@;
is eval { archive_entry_atime_nsec($e) }, 123456789, 'archive_entry_atime_nsec';
diag $@ if $@;

$r = eval { archive_entry_set_mtime($e, 123456798, 123456798) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_mtime';
is eval { archive_entry_mtime($e) }, 123456798, 'archive_entry_mtime';
diag $@ if $@;
is eval { archive_entry_mtime_nsec($e) }, 123456798, 'archive_entry_mtime_nsec';
diag $@ if $@;

$r = eval { archive_entry_set_ctime($e, 123456766, 123456766) };
diag $@ if $@;
is $r, ARCHIVE_OK, 'archive_entry_set_ctime';
is eval { archive_entry_ctime($e) }, 123456766, 'archive_entry_ctime';
diag $@ if $@;
is eval { archive_entry_ctime_nsec($e) }, 123456766, 'archive_entry_ctime_nsec';
diag $@ if $@;

$r = archive_entry_free($e);
is $r, ARCHIVE_OK, 'archive_entry_free';
