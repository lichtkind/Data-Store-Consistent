
# create var in sub scope while using outer var that just gets overwritten
#
# HASH<set:red,green,blue>< int: min(0), max(255) >
# %<red|green|blue><int{0,255}>

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = [12,13,14];
$" = ',';
say "is value: [@$value] a color ?";

say "looks good named" unless check_named( $value, 'color value',
    {ref => 'ARRAY', length => { min => 3, max => 3 }, ARRAY => {element => { min => 0, max => 255 }}},
);

sub check_named {
    my ($value, $value_name, $param) = @_;

    {
        my $param = $param->{'ref'};
        return "$value_name is not a $param reference" unless ref $value eq $param;
    }
    {
        my $property = 'length';
        my $param = $param->{$property};
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value = @$value;
        {
            my $param = $param->{'min'};
            return "$value_name is not greater or equal $param" unless $value >= $param;
        }
        {
            my $param = $param->{'max'};
            return "$value_name is not less or equal $param" unless $value <= $param;
        }
    }
    {
        my $param = $param->{'ARRAY'};
        {
            for my $index (0 .. $#$value) {
                my $value = $value->[$index];
                my $value_name = "$value_name element $index";

                return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int

                {
                    my $param = $param->{'element'};
                    {
                        my $param = $param->{'min'};
                        return "$value_name is not greater or equal $param" unless $value >= $param;
                    }
                    {
                        my $param = $param->{'max'};
                        return "$value_name is not less or equal $param" unless $value <= $param;
                    }
                }
            }
        }
    }
    return '';
}
