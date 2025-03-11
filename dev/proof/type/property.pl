
# type property mechanic on example of string of lengths of 3
#
# str(length[min(3), max(3)])
# str{3}

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = '101';
say "is $value a pattern of length 3 ?";

say "looks good named" unless check_named( $value, 'pattern', {length => { min => 3, max => 3 }});
say "looks good pos" unless check_pos( $value, 'pattern', [[3,3]] );

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
            my $param = $param->{'min'};
            return "$value_name is not greater or equal $param" unless $value >= $param;
        }
        {
            my $param = $param->{'max'};
            return "$value_name is not less or equal $param" unless $value <= $param;
        }

        #return "$name is not an string with length of $param" unless $value == $param;
    }

    return '';
}

sub check_pos {
    my ($value, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;  # basic type defined
    return "$value_name is not not a reference" unless not ref $value;  # basic type not_ref = str

    {
        my $property = 'length';
        my $param = shift @$param;
        my $value_name = "$property of $value_name";
        my $value = length $value;

        {
            my $param = shift @$param;
            return "$value_name is not greater or equal $param" unless $value >= $param;
        }
        {
            my $param = shift @$param;
            return "$value_name is not less or equal $param" unless $value <= $param;
        }
        #return "$name is not an string with length of $param" unless $value == $param;
    }

    return '';
}
