
# parametric type mechanics on example of min and max

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value a color value?";

say "looks good named" unless check_named( $value, 'color value', [{min => 0, max => 255}]);
say "looks good pos" unless check_pos( $value, 'color value', [0, 255] );

sub check_named {
    my ($value, $name, $params ) = @_;
    $name //= "";

    return "$name is not a defined value" unless defined $value;
    return "$name is not any type of number" unless looks_like_number($value);
    return "$name is not number without decimals" unless int($value) == $value;
    {
        my $param = shift @$params;
        {
            my $param = $param->{'min'};
            return "$name is not greater or equal $param" unless $param <= $value;
        }
        {
            my $param = $param->{'max'};
            return "$name is not less or equal $param" unless $param >= $value;
        }
    }

    return '';
}

sub check_pos {
    my ($value, $name, $params ) = @_;
    $name //= "";

    return "$name is not a defined value" unless defined $value;
    return "$name is not any type of number" unless looks_like_number($value);
    return "$name is not number without decimals" unless int($value) == $value;

    {
        my $param = shift @$params;
        return "$name is not greater or equal $param" unless $param <= $value;
    }
    {
        my $param = shift @$params;
        return "$name is not less or equal $param" unless $param >= $value;
    }

    return '';
}
