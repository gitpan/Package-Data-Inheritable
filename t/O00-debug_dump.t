#!/usr/local/bin/perl
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
#use OPerson;    # do not use if you want to check proper call of import() via use base
#use OWorker;    # do not use if you want to check proper call of import() via use base
use OEmployee;
BEGIN { inherit OEmployee };

print <<ZZZ;
---------
    OPerson::EXPORT_OK:        (@OPerson::EXPORT_OK)
    OWorker::EXPORT_OK:        (@OWorker::EXPORT_OK)
    OEmployee::EXPORT_OK:      (@OEmployee::EXPORT_OK)
    OPerson::EXPORT:           (@OPerson::EXPORT)
    OWorker::EXPORT:           (@OWorker::EXPORT)
    OEmployee::EXPORT:         (@OEmployee::EXPORT)
    OPerson::EXPORT_INHERIT:   (@OPerson::EXPORT_INHERIT)
    OWorker::EXPORT_INHERIT:   (@OWorker::EXPORT_INHERIT)
    OEmployee::EXPORT_INHERIT: (@OEmployee::EXPORT_INHERIT)
---------
ZZZ

print "OPerson::USERNAME_mk_st:   $OPerson::USERNAME_mk_st\n";
print "OEmployee::USERNAME_mk_st: $OEmployee::USERNAME_mk_st\n";
print "\@OPerson::ISA: ", Dumper(\@OPerson::ISA), "\n";

#use DUMPVAR;
#DUMPVAR::dumpvar('OWorker');
#print "#########", Dumper(*OWorker::import{CODE}), "\n";

ok( 1, 'Test placeholder' );    # Test::More wants at least one test

