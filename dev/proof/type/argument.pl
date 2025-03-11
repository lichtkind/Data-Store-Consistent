
# argument type mechanics on example of spos = inf 0
#
# spos
# inf 0

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value strictly positive ?";

say "looks good named" unless check_named( $value, 'natural number', {inf => 0});
say "looks good pos" unless check_pos( $value, 'natural number', [0] );

sub check_named {
    my ($value, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int

    {
        my $param = $param->{'inf'};
        return "$value_name is not greater then $param" unless $value > $param;
    }

    return '';
}

sub check_pos {
    my ($value, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int

    {
        my $param = shift @$param;
        return "$value_name is not greater then $param" unless $value > $param;
    }

    return '';
}
