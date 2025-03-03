
# basic type mechanics on example of int

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = 45;
say "is $value an integer?";

say "looks good" unless check( $value, 'number of states');

sub check {
    my ($value, $name, $params ) = @_;
    $name //= "";

    return "$name is not a defined value" unless defined $value;                # basic type: defined
    return "$name is not any type of number" unless looks_like_number($value);  # basic type: num
    return "$name is not number without decimals" unless int($value) == $value; # basic type: int

    return '';
}
