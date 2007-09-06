#!perl -T
use warnings;
use strict;

use Test::More tests => 6;

use lib qw( t t/lib ./lib );
#use MPerson;    # do not use if you want to check proper call of import() via use base
#use MWorker;    # do not use if you want to check proper call of import() via use base

use MEmployee;
BEGIN { inherit MEmployee };
use Data::Dumper;

can_ok('MPerson',  'inherit');
can_ok('MWorker',  'inherit');
can_ok('MEmployee', 'inherit');

is( check_person_isa(),   'OK', 'MPerson::ISA        functional test');
is( check_worker_isa(),   'OK', 'MWorker::ISA        functional test');
is( check_employee_isa(), 'OK', 'MEmployee::ISA      functional test');

exit;


######################################################################

# Functional test
sub check_person_isa {
    return _check_class_isa('MPerson', ['Package::Data::Inheritable', 'Exporter', 'UNIVERSAL']);
}

# Functional test
sub check_worker_isa {
    return _check_class_isa('MWorker', ['MWorker', 'Package::Data::Inheritable', 'Exporter', 'UNIVERSAL']);
}

# Functional test
sub check_employee_isa {
    return _check_class_isa('MEmployee', ['MEmployee', 'MWorker', 'Package::Data::Inheritable', 'Exporter', 'UNIVERSAL']);
}


######################################################################
# TEST UTILITIES

sub _check_class_isa {
    my ($class, $isa_list) = @_;
    foreach my $upper (@$isa_list) {
        next if UNIVERSAL::isa($class, $upper);
        return "$class is not a $upper";
    }
    return 'OK';
}

