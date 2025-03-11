
# parametric type mechanics on example of min and max

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value a color value?";

say "looks good named" unless check_named( $value, 'color value', {min => 0, max => 255});
say "looks good pos" unless check_pos( $value, 'color value', [0, 255] );

sub check_named {
    my ($value, $value_name, $params) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int
    {
        {
            my $param = $params->{'min'};
            return "$value_name is not greater or equal $param" unless $value >= $param;
        }
        {
            my $param = $params->{'max'};
            return "$value_name is not less or equal $param" unless $value <= $param;
        }
    }

    return '';
}

sub check_pos {
    my ($value, $value_name, $params) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int

    {
        my $param = shift @$params;
        return "$value_name is not greater or equal $param" unless $value >= $param;
    }
    {
        my $param = shift @$params;
        return "$value_name is not less or equal $param" unless $value <= $param;
    }

    return '';
}
