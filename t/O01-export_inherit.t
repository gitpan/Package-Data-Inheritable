#!/usr/local/bin/perl
use warnings;
use strict;

use Test::More tests => 3;
#use Test::Deep;

#use MODULE ;
#DESCRIPTION
#It is exactly equivalent to
#    BEGIN { require Module; import Module LIST; }
#
#use base qw(Foo Bar);
#DESCRIPTION
#Allows you to both load one or more modules, while setting up inheritance from
#those modules at the same time.  Roughly similar in effect to:
#   package Baz;
#   BEGIN {
#       require Foo;
#       require Bar;
#       push @ISA, qw(Foo Bar);
#   }
#
# NOTE:
# This means that use base, being performed via 'require' does NOT call
# the import() method.
# Hence, it does not work properly with Exporter

use lib qw( t t/lib ./lib );
#use OPerson;    # do not use if you want to check proper call of import() via use base
#use OWorker;    # do not use if you want to check proper call of import() via use base
use OEmployee;
BEGIN { inherit OEmployee };
use Data::Dumper;

is( check_person_export_inherit(),   'OK', 'OPerson::EXPORT_INHERIT');
is( check_worker_export_inherit(),   'OK', 'OWorker::EXPORT_INHERIT');
is( check_employee_export_inherit(), 'OK', 'OEmployee::EXPORT_INHERIT');

exit;


######################################################################

# Functional/implementation test
sub check_person_export_inherit {
    my $check;
    eval {
        #_check_export_list('import', \@OPerson::EXPORT_INHERIT, '@OPerson::EXPORT_INHERIT');
        _check_list_members({
              symbols  => [qw( $USERNAME_mk_st @USERNAME_mk_st $COMMON_NAME @COMMON_NAME )],
              list     => \@OPerson::EXPORT_INHERIT,
              listname => '@OPerson::EXPORT_INHERIT',
            });
    };
    if ($@) { chomp $@; return $@ }
    return 'OK';
}
# Functional/implementation test
sub check_worker_export_inherit {
    eval {
        #_check_export_list('import', \@OWorker::EXPORT_INHERIT, '@OWorker::EXPORT_INHERIT');
        _check_list_members({
              symbols  => [qw( $USERNAME_mk_st $COMMON_NAME $DUMMY )],
              list     => \@OWorker::EXPORT_INHERIT,
              listname => '@OWorker::EXPORT_INHERIT',
            });
    };
    if ($@) { chomp $@; return $@ }
    return 'OK';
}
# Functional/implementation test
sub check_employee_export_inherit {
    eval {
        #_check_export_list('import', \@OEmployee::EXPORT_INHERIT, '@OEmployee::EXPORT_INHERIT');
        _check_list_members({
              symbols  => [qw( $USERNAME_mk_st $DUMMY $SALARY $COMMON_NAME @COMMON_NAME )],
              list     => \@OEmployee::EXPORT_INHERIT,
              listname => '@OEmployee::EXPORT_INHERIT',
            });
    };
    if ($@) { chomp $@; return $@ }
    return 'OK';
}


sub _check_export_list {
    my ($symbol, $export_list, $listname) = @_;

    return 'OK' if grep {$_ eq $symbol} @$export_list;
    die "Cannot find '$symbol' in $listname\n";
}

sub _check_list_members {
    my $params = shift || die "_check_list_members: no parameters";

    my $symbols  = $params->{symbols} or die "_check_list_members: missing 'symbols' param";
    my $list     = $params->{list} or die "_check_list_members: missing 'list' param";
    my $listname = $params->{listname} or die "_check_list_members: missing 'listname' param";

    foreach my $sym (@$symbols) {
        die "Cannot find '$sym' in $listname\n" if not grep {$_ eq $sym} @$list;
    }
    return 'OK';
}



