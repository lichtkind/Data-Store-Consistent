
# parametric type mechanics on example of min and max
# unless argument types, parameter types have to be checked at run time every time
#
# int[min(0); max(255);]
# int{0,255}

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value a color value?";

say "looks good" unless check_named( $value, 'color value', {min => 0, max => 255});
say "also equal to 45 !" unless not_equal( $value, 45, 'color value', {min => 0, max => 255});


sub check_named {
    my ($value, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int

    {
        my $param = $param->{'min'};
        {
            my $value = $param;
            return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
            return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
        }
        return "$value_name is not greater or equal $param" unless $value >= $param;
    }
    {
        my $param = $param->{'max'};
        {
            my $value = $param;
            return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
            return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
        }
        return "$value_name is not less or equal $param" unless $value <= $param;
    }

    return '';
}

sub not_equal {
    my ($value_a, $value_b, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
    return '';
}
