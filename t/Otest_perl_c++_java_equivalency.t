#!perl
use strict;
use warnings;

use Test::More tests => 1;
use Cwd;

is( check_output_diff(), '', 'Perl output should be the same as C++/Java output');


sub check_output_diff {
    chdir '../t' or chdir 't' or die "Cannot cd to 't' directory.";

    my $dir = '.';
    my $perl_out = "$dir/Operl_output";
    system("perl $dir/Obase_derived_main.pl > $perl_out") == 0
        or die "$?\n";
    my $diff = qx( diff -b $perl_out $dir/c++_java_output );
    #unlink $perl_out;

    return $diff;
}

