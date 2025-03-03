
# create var in sub scope while using outer var that just gets overwritten

use v5.12;
use warnings;

my $value = [12,13,14];

say "$value ", $#$value;

check( $value, 'color of this', ['ARRAY', 3, [[0,255],[0,255],[0,255]]]);

sub check {
    my ($value, $name, $params ) = @_;
    {
        my $param = shift @$params;
        return "$name is not an Array ref!" unless ref $value eq $param;
    }
    {
        my $value = @$value;
        my $param = shift @$params;
        return "$name is not an Array of length $param->[1]" unless $value == $param;
    }
    my $param = shift @$params;
    for my $index (0 .. $#$value) {
        {
            my $value = $index;
        }

        {
            my $value = $value->[$index];
            my $params = $param->[$index];
            #say $value;
            {
                my $param = shift @$params;
                return "$name element $index is not greater equal than $param" unless $value >= $param;
            }
            {
                my $param = shift @$params;
                return "$name element $index is not smaller equal than $param" unless $value <= $param;
            }
        }
    }
    return '';
}

__END__
