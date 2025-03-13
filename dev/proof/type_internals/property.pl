
# type property mechanic on example of string of lengths of 3
#
# str(length[min(3), max(3)])
# str{3}

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = '101';
say "is $value a pattern of length 3 ?";

say "looks good !" unless check_named( $value, 'pattern', {length => { id => 3 }});
say "also equal to '101' !" unless not_equal( $value, '101', 'color value' );
say "not equal to '010' !" if not_equal( $value, '010', 'color value' );


sub check_named {
    my ($value, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;  # basic type defined
    return "$value_name is not not a reference" unless not ref $value;  # basic type not_ref = str

    {
        my $property = 'length';
        my $param = $param->{$property};
        my $value_name = "$property of $value_name";
        my $value = length $value;

        {
            my $value_a = $value;
            my $value_b = $param->{'id'};
            return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
        }
    }

    return '';
}

sub not_equal {
    my ($value_a, $value_b, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name of $value_a is not equal to $value_b" unless $value_a eq $value_b;
    return '';
}
