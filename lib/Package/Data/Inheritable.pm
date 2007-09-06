use warnings;
use strict;
use 5.006_000;   # Perl >=5.6.0  we need 'our' and other stuff

package Package::Data::Inheritable;
use base qw( Exporter );

use Carp;

our $VERSION = '0.01';


# This method carries out the actual package variable inheritance via export
# <$class>   Is the package/class which is exporting
# <$caller>  Is the package/class into which we're exporting
# <@symbols> Is the list of symbols requested for import.
#            This does not make sense for this module since we do not export
#            syms, we rather propagate to our children classes and they
#            should not be able to control what to inherit
sub inherit {
    my ($class, @symbols) = @_;
    croak __PACKAGE__ . "::inherit: Extra params specified. (@symbols)" if @symbols;

    my ($caller, $file, $line) = caller;
    no strict "refs";

    # propagate inherited fields up to our caller
    my @inherited;
    {
        # collect inherited fields from all superclasses
        my @inherited = $class->_get_inherited_from_parent();
        # ... and add them to those that this class wants to make inheritable
        push @{$class ."::EXPORT_INHERIT"}, @inherited;

        # and now push onto EXPORT_OK everything we want to be inheritable
        push @{$class ."::EXPORT_OK"}, @{$class ."::EXPORT_INHERIT"};
    }
    # make Exporter export our INHERITANCE fields together with the usual @EXPORT
    push @symbols, (@inherited, @{$class ."::EXPORT_INHERIT"});
    push @symbols, @{$class ."::EXPORT"};

    # handle derived class (our caller) overriden fields
    foreach my $overriden (@{$caller .'::EXPORT_INHERIT'}) {
        @symbols = grep { $_ ne $overriden } @symbols;
    }

    $class->export_to_level(1, $class, @symbols);
}


# static method
# Make a static field inheritable by adding it to @EXPORT_INHERIT
sub pkg_inheritable {
    my ($callpkg, $symbol, $value) = @_;
    ref $callpkg and croak "pkg_inheritable: called on a reference: $callpkg\n";

    no strict "refs";
    my $export_ok = \@{"${callpkg}::EXPORT_INHERIT"};
    croak "pkg_inheritable: trying to redefine symbol 'symbol'\n"
        if grep { $_ eq $symbol } @$export_ok;

    $symbol =~ s/^(\W)// or croak "pkg_inheritable: no sigil in symbol '$symbol'";
    my $sigil = $1;
    my $qualified_symbol = "${callpkg}::$symbol";

    no strict 'vars';
    *pkg_stash = *{"${callpkg}::"};

    # install in the caller symbol table a new symbol
    # this will override any already existing one
    *$qualified_symbol =
        $sigil eq '&' ? \&$value :
        $sigil eq '$' ? \$value  :
        $sigil eq '@' ? \@$value :
        $sigil eq '%' ? \%$value :
        $sigil eq '*' ? \*$value :
        do { Carp::croak("Can't install symbol: $sigil$symbol") };

    push @$export_ok, "$sigil$symbol";
}


# collect inherited fields from all superclasses
sub _get_inherited_from_parent {
    my ($class) = @_;

    no strict "refs";
    my @inherited;
    foreach my $super (@{$class . "::ISA"}) {
        push @inherited, @{$super . "::EXPORT_INHERIT"};
    }
    return @inherited;
}


# Utility method to dump the symbol table hash of a package
#sub _dump_symbols {
#    my $class = shift or croak "_dump_symbols: missing 'class' param";
#
#    no strict 'refs';
#    print "${class}:: [\n";
#    while ( my ($name, $glob) = each %{"${class}::"}) {
#        print "\t$name, $glob\n"; 
#    }
#    print "]\n";
#}

# Utility method to dump the symbol table hash of a package
sub _dumpstash {
    my ($package_name) = @_;

    local (*alias);
    no strict 'refs','vars';
    # access the stash corresponding to the package name
    *stash = *{"${package_name}::"};  # Now %stash is the symbol table
    $, = " ";
    # Iterate through the symbol table, which contains glob values
    # indexed by symbol names.
    print "${package_name}:: [\n";
    while (my ($var_name, $glob_value) = each %stash) {
        print "  $var_name =============================\n";
        *alias = $glob_value;
        if (defined $alias) {
            print "\t \$$var_name $alias\n";
        }
        if (defined @alias) {
            print "\t \@$var_name @alias\n";
        }
        if (defined %alias) {
            print "\t \%$var_name ", %alias, "\n";
        }
     }
    print "] ---\n";
}


=head1 NAME

Package::Data::Inheritable - Inheritable and overridable package data/variables

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Method interface:

  package Base;
  use base qw( Package::Data::Inheritable );

  BEGIN {
      inherit Package::Data::Inheritable;

      Base->pkg_inheritable('$class_scalar' => 'a not so ordinary package variable');
  };

  print $class_scalar;

Exporter like interface:

  package Derived;
  use base qw( Base );

  BEGIN {
      # declare our variables and overrides *before* inheriting
      our @EXPORT_INHERIT = qw( $scalar @array );

      inherit Base;
  }
  our @array = (1,2,3);
  our $scalar;

=head1 DESCRIPTION

This module tries to deliver inheritable package data (variables) with a reasonably
convenient interface.
After declaring variables they can be used like ordinary package variables. Most
importantly, these variables can be inherited by derived classes (packages) by
calling the inherit() method.
If a derived class doesn't call inherit() it will still get the ordinary method
inheritance and will also be able to define its vars and make them inheritable
by its subclasses.

Within your class (hierarchy) code you will benefit from compiler checks on those
variables. The overall result is close to real class *data* as opposed to
class methods.
Of course you can wrap your variables is accessor/mutators methods as you need.

The semantic provided mimics the static data members in languages like C++ and Java.
When you assign to an inherited variable within a derived class, every class
in the inheritance hierarchy will see the new value. If you want to override a
variable you must redeclare it explicitly.

Two interfaces are provided, one is Exporter like and the other one is based
on the method pkg_inheritable().
The variable visibility (scope) depends on the interface you used. If you use
the Exporter like interface, variables will be declared via our, while if you
use the method interface it will be like you had imported those variables.

=head1 EXPORT

Package::Data::Inheritable is an Exporter, inheriting from it (via use base or @ISA)
will make your class an Exporter as well.
The package variable @EXPORT_INHERIT contains the symbols that will be inherited
and @EXPORT_OK will always contain at least those symbols.

The Exporter like interface allows your class to set @EXPORT_INHERIT in pretty
much the same way you would set @EXPORT and @EXPORT_OK with Exporter.


=head1 DEFINING VARIABLES


=head2 Exporter like interface

  BEGIN {
      our @EXPORT_INHERIT = qw( $scalar @array );
  }
  our $scalar;
  our @array = (1,2,3);

If you're defining variables, none of which is overriding a parent package's one
(see overriding below), it's not required to define @EXPORT_INHERIT inside
a BEGIN block.
You will declare the variables via 'our' in the usual way.
The actual our declaration of each variable must be outside the BEGIN block in
any case because of 'our' scoping rules.


=head2 Method interface

  BEGIN {
      Class->pkg_inheritable('$scalar');
      Class->pkg_inheritable('@array' => [1,2,3]);
  }

Every variable declaration must be inside a BEGIN block because there's no 'our'
declaration of that variable and we need compile time installation of that
symbol in the package symbol table.



=head1 OVERRIDING VARIABLES

When you use the Exporter like interface and you want to override a parent
package variable you must define @EXPORT_INHERIT before calling inherit(),
otherwise inherit() will not find any of your overrides.
  On the contrary, if you use the pkg_inheritable() method interface, ordering
doesn't matter. If you define your overrides before calling inherit,
@EXPORT_INHERIT will already be defined (being set by the method calls).
If you call inherit and after that you call pkg_inheritable(), this will take
care of performing the overriding.


=head1 METHODS

=head2 inherit

Make the caller package inherit variables from the package on which the method is invoked.
i.e.

    package Derived;
      BEGIN {
        inherit Base;
        # or
        Base->inherit;
      }

will make Derived inherit variables from Base.

This method must be invoked from within a BEGIN block in order to
install the inherited variables at compile time.
Otherwise any attempt to refer to those package variables in your code will
trigger a 'Global symbol "$yourvar" requires explicit package name' error.

=cut


=head2 pkg_inheritable

    Class->pkg_inheritable('$variable_name');
    Class->pkg_inheritable('$variable_name' => $value);
    Class->pkg_inheritable('@variable_name' => ['value1','value2']);

This method implements the non-exporter like interface.
$variable_name will be installed in the package symbol table like it had
been declared with use 'vars'.
Furthermore the variable will be inherited by packages invoking inherit()
on class 'Class'.

=cut

=head1 EXAMPLES

=head2 Inheriting and overriding

   use Package::Data::Inheritable;
   
   # set up Base class with the method interface:
    package Base;
    use base qw( Package::Data::Inheritable );
   
    BEGIN {
        inherit Package::Data::Inheritable;
   
        Base->pkg_inheritable('$scalar1' => 'Base scalar');
        Base->pkg_inheritable('$scalar2' => 'Base scalar');
        Base->pkg_inheritable('@array'   => [1,2,3]);
    };
   
    print $scalar1;
    print @array;
   
   # set up Derived class with the Exporter like interface:
    package Derived;
    use base qw( Base );
   
    BEGIN {
        # declare our variables and overrides *before* inheriting
        our @EXPORT_INHERIT = qw( $scalar2 @array );
   
        inherit Base;
    }
    our @array = (2,4,6);
    our $scalar2 = "Derived scalar";
   
    # prints "Derived scalar"
    print $scalar2;
    # prints "Base scalar"
    print $Base::scalar2;
    # prints 246
    print @array;
    # prints "Base scalar"
    print $scalar1;
    $scalar1 = "Base and Derived scalar";
    # prints "Base and Derived scalar" twice
    print $Base::scalar1, $Derived::scalar1;


=head2 Accessing and wrapping data members

You are encouraged to properly wrap in accessor/mutator methods your private data.
Furthermore, be aware that when you qualify your variables with the package
prefix you're giving up compiler checks on those variables.

    use strict;
    package SomeClass;
    use base qw( Package::Data::Inheritable );

    BEGIN {
        inherit Package::Data::Inheritable;

        __PACKAGE__->pkg_inheritable('$_private_scalar' => 'private scalar');
        __PACKAGE__->pkg_inheritable('$public_scalar' => 'public scalar');
    };

    sub new { bless {}, __PACKAGE__ }

    # accessor/mutator example
    sub private_scalar {
        my ($class, $val) = @_;
        if (defined $val) {
           # check $val or croak...
           $_private_scalar = $val;
        }
        return $_private_scalar;
    }

    sub do_something {
        my ($self) = @_;
        # ok
        print $public_scalar;
        # ok, but dangerous
        print $SomeClass::public_scalar;

        # compile error
        print $publicscalar;

        # variable undefined but no compile error because of package prefix
        print $SomeClass::publicscalar;
    }


  And then in some user code:

    use strict;
    use SomeClass;
    
    # prints "public scalar". Discouraged.
    print $SomeClass::public_scalar;
    # prints "private scalar"
    print SomeClass->private_scalar;
    
    SomeClass->private_scalar("reset!");
    my $obj = SomeClass->new;
    # prints "reset!"
    print SomeClass->private_scalar;
    print $obj->private_scalar;

=head1 CAVEATS

The interface of this module is not stable yet.
I'm still looking for ways to reduce the amount of boilerplate code needed.
Suggestions and comments are warmly welcome.

=head1 AUTHOR

Giacomo Cerrai, C<< <gcerrai at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-package-data-inheritable at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Package-Data-Inheritable>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Package::Data::Inheritable

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Package-Data-Inheritable>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Package-Data-Inheritable>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Package-Data-Inheritable>

=item * Search CPAN

L<http://search.cpan.org/dist/Package-Data-Inheritable>

=back

=head1 SEE ALSO

Class::Data::Inheritable,

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Giacomo Cerrai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Package::Data::Inheritable
