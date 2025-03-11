
# parametric type mechanics on example of min and max

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value strictly positive ?";

say "looks good named" unless check_named( $value, 'natural number', {inf => 0});
say "looks good pos" unless check_pos( $value, 'natural number', [0] );

sub check_named {
    my ($value, $value_name, $params) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;
    return "$value_name is not any type of number" unless looks_like_number($value);
    return "$value_name is not number without decimals" unless int($value) == $value;

    {
        my $param = $params->{'inf'};
        return "$value_name is not greater then $param" unless $value > $param;
    }

    return '';
}

sub check_pos {
    my ($value, $value_name, $params) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;
    return "$value_name is not any type of number" unless looks_like_number($value);
    return "$value_name is not number without decimals" unless int($value) == $value;

    {
        my $param = shift @$params;
        return "$value_name is not greater then $param" unless $value > $param;
    }

    return '';
}
