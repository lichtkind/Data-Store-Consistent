
# basic type mechanics on example of int
#
# int is parent of num is parent of defined
# defined --> num --> int

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value an integer?";

say "looks good" unless check( $value, 'number of states');
say "also equal to 45 !" unless not_equal( $value, 45, 'number of states');

sub check {
    my ($value, $value_name) = @_;
    $value_name //= "";

    return "$value_name is not a defined value" unless defined $value;                # basic type: defined
    return "$value_name is not any type of number" unless looks_like_number($value);  # basic type: num
    return "$value_name is not number without decimals" unless int($value) == $value; # basic type: int

    return '';
}

sub not_equal {
    my ($value_a, $value_b, $value_name) = @_;
    $value_name //= "";

    return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
    return '';
}
