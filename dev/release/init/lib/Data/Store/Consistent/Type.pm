use v5.20;
use warnings;

# bundle all type related functionality

package Data::Store::Consistent::Type;

use Data::Store::Consistent::Type::Basic;
use Data::Store::Consistent::Type::Parametric;
use Data::Store::Consistent::Type::Array;
use Data::Store::Consistent::Type::Hash;

################################################################################


sub add {
    my ($name, $def) = @_;
}

sub compile {
    my ($name, $def) = @_;
}

sub get_type_checker {
    my ($name) = @_;
}


1;

