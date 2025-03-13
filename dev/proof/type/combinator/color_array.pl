
# create var in sub scope while using outer var that just gets overwritten
#
# ARRAY[length(min(3), max(3))]< int: min(0), max(255) >
# @{3}<int{0,255}>

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = [12,13,14];
say "is value: [12,13,14] a color ?";

say "looks good named" unless check_named( $value, 'color array',
    {ref => 'ARRAY', length => { is => 3 }, ARRAY => {element => { min => 0, max => 255 }}},
);
say "got equal check !" unless not_equal( $value, [12,13,14], 'color array' );


sub check_named {
    my ($value, $value_name, $param) = @_;

    {
        my $param = $param->{'ref'};
        {
            my $value = $param;
            return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
            return "$value_name is a reference" unless not ref $value;                         # basic type: not_ref
        }
        return "$value_name is not a $param reference" unless ref $value eq $param;
    }
    {
        my $property = 'length';
        my $param = $param->{$property};
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value = @$value;

        {
            my $value_a = $value;
            my $value_b = $param->{'is'};
            return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
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
                        {
                            my $value = $param;
                            return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                            return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                        }
                        return "$value_name is not greater or equal $param" unless $value >= $param;
                    }
                    {
                        my $param = $param->{'max'};
                        {
                            my $value = $param;
                            return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                            return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                        }
                        return "$value_name is not less or equal $param" unless $value <= $param;
                    }
                }
            }
        }
    }
    return '';
}

sub not_equal {
    my ($value_a, $value_b, $value_name) = @_;
    $value_name //= "";
    {
        my $property = 'length';
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value_a = @$value_a;
        my $value_b = @$value_b;

        return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
    }
    {
        for my $index (0 .. $#$value) {
            my $value_a = $value_a->[$index];
            my $value_b = $value_b->[$index];
            my $value_name = "$value_name element $index";

            return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
        }
    }
    return '';
}




