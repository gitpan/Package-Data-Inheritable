#!perl -T
use warnings;
use strict;

use Test::More tests => 1;
use Data::Dumper;

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
#use MPerson;    # do not use if you want to check proper call of import() via use base
#use MWorker;    # do not use if you want to check proper call of import() via use base
use MEmployee;
BEGIN { inherit MEmployee };

print <<ZZZ;
---------
    MPerson::EXPORT_OK:        (@MPerson::EXPORT_OK)
    MWorker::EXPORT_OK:        (@MWorker::EXPORT_OK)
    MEmployee::EXPORT_OK:      (@MEmployee::EXPORT_OK)
    MPerson::EXPORT:           (@MPerson::EXPORT)
    MWorker::EXPORT:           (@MWorker::EXPORT)
    MEmployee::EXPORT:         (@MEmployee::EXPORT)
    MPerson::EXPORT_INHERIT:   (@MPerson::EXPORT_INHERIT)
    MWorker::EXPORT_INHERIT:   (@MWorker::EXPORT_INHERIT)
    MEmployee::EXPORT_INHERIT: (@MEmployee::EXPORT_INHERIT)
---------
ZZZ

print "MPerson::USERNAME_mk_st:   $MPerson::USERNAME_mk_st\n";
print "MEmployee::USERNAME_mk_st: $MEmployee::USERNAME_mk_st\n";
print "\@MPerson::ISA: ", Dumper(\@MPerson::ISA), "\n";

#use DUMPVAR;
#DUMPVAR::dumpvar('MWorker');
#print "#########", Dumper(*MWorker::import{CODE}), "\n";

ok( 1, 'Test placeholder' );    # Test::More wants at least one test

