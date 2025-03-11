
# create var in sub scope while using outer var that just gets overwritten

use v5.12;
use warnings;

# ARRAY( len(3), elem(min(0), max(255)) )
# @[3]<{0,255}>
my $value = [12,13,14];
say "$value: 0 .. ", $#$value;

say "looks good" unless check( $value, 'color value',
         [{ref => 'ARRAY'}, {len => 3, element => {min => 0, max => 255}}], ['ref type ']);

sub check {
    my ($value, $name, $params, $param_names ) = @_;

    {
        my $param      = shift @$params;
        my $param_name = shift @$param_names;
        {
            my $param = $param->{'ref'};
            return "$name is not an Array ref!" unless ref $value eq $param;
        }
    }

    {
        my $param = shift @$params;
        {
            my $value = @$value;
            my $param = $param->{'len'};
            return "$name is not an Array of length $param" unless $value == $param;
        }
        for my $index (0 .. $#$value) {
            {
                my $value = $index;
            }

            {
                my $value = $value->[$index];
                my $param = $param->{'element'};
                my $name = "$name element $index";
                {
                    my $param = $param->{'min'};
                    return "$name is not greater equal than $param" unless $value >= $param;
                }
                {
                    my $param = $param->{'max'};
                    return "$name is not smaller equal than $param" unless $value <= $param;
                }
            }
        }
    }
    return '';
}

__END__
