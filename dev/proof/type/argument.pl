
# argument type mechanics on example of spos = inf 0
# unless parameter types, argument dont have to be checked only compile time
#
# spos
# inf 0

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value strictly positive ?";

say "looks good" unless check_named( $value, 'natural number', {inf => 0});
say "also equal to 45 !" unless not_equal( $value, 45, 'natural number' );
say "not equal to 32.1 !"    if not_equal( $value, 32.1, 'natural number' );


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

sub not_equal {
    my ($value_a, $value_b, $value_name, $param) = @_;
    $value_name //= "";

    return "$value_name of $value_a is not equal to " unless $value_a == $value_b;
    return '';
}
