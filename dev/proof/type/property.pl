
# parametric variable mechanics on example of min and max

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = '101';
say "is $value a pattern ?";

say "looks good named" unless check_named( $value, 'pattern', [{len => 3}]);
say "looks good pos" unless check_pos( $value, 'pattern', [3] );

sub check_named {
    my ($value, $name, $params ) = @_;
    $name //= "";

    return "$name is not a defined value" unless defined $value;  # basic type str

    my $param = shift @$params;
    {
        my $value = length $value;
        my $param = $param->{'len'};
        return "$name is not an string with length of $param" unless $value == $param;
    }

    return '';
}

sub check_pos {
    my ($value, $name, $params ) = @_;
    $name //= "";

    return "$name is not a defined value" unless defined $value;

    {
        my $value = length $value;
        my $param = shift @$params;
        return "$name is not an string with length of $param" unless $value == $param;
    }

    return '';
}
