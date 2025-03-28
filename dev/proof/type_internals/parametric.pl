
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
    $value_name //= "value";

    return "$value_name should be a defined value" unless defined $value;                          # basic type: defined
    return "$value_name of $value should be not a reference" unless not ref $value;                # basic type: not_ref
    return "$value_name of $value should be any type of number" unless looks_like_number($value);  # basic type: num
    return "$value_name of $value should be number without decimals" unless int($value) == $value; # basic type: int

    {
        my $param = $param->{'min'};
        {
            my $value = $param;
            return "$value_name should be a defined value" unless defined $value;                         # basic type: defined
            return "$value_name of $value should be any type of number" unless looks_like_number($value); # basic type: num
        }
        return "$value_name of $value should be greater or equal $param" unless $value >= $param;
    }
    {
        my $param = $param->{'max'};
        {
            my $value = $param;
            return "$value_name should be a defined value" unless defined $value;                         # basic type: defined
            return "$value_name of $value should be any type of number" unless looks_like_number($value); # basic type: num
        }
        return "$value_name of $value should be less or equal $param" unless $value <= $param;
    }

    return '';
}

sub not_equal {
    my ($value, $parameter, $value_name) = @_;
    $value_name //= "value";
    return "$value_name has value of '$value', but expected was $parameter" unless $value == $parameter;
    return '';
}
