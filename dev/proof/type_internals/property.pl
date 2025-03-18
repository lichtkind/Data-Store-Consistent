
# type property mechanic on example of string of lengths of 3
#
# str(length[min(3), max(3)])
# str{3}

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = '101';
say "is $value a pattern of length 3 ?";

say "looks good !" unless check_named( $value, {length => { eq => 3 }}, 'pattern');
say "also equal to '101' !" unless not_equal( $value, '101', 'color value' );
say "not equal to '010' !" if not_equal( $value, '010', 'color value' );


sub check_named {
    my ($value, $parameter, $value_name) = @_;
    $value_name //= "value";

    return "$value_name is not a defined value" unless defined $value;  # basic type defined
    return "$value_name is not not a reference" unless not ref $value;  # basic type not_ref = str

    my %property = (id => $value);
    $property{'length'} = length $value;
    {
        my $property_name = 'length';
        my $value = $property{'length'};
        my $parameter = $parameter->{$property_name};
        my $value_name = "$property_name of $value_name";

        {
            my $parameter = $parameter->{'eq'};
            return "$value_name has value of '$value', but expected was $parameter" unless $value eq $parameter;
        }
    }

    return '';
}

sub not_equal {
    my ($value, $parameter, $value_name) = @_;
    $value_name //= "value";

    return "$value_name has value of '$value', but expected was $parameter" unless $value eq $parameter;
    return '';
}
