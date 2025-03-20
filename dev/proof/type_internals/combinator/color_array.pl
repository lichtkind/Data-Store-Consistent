
# create var in sub scope while using outer var that just gets overwritten
#
# ARRAY[length(min(3), max(3))]< int: min(0), max(255) >
# @{3}<int{0,255}>

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my $value = [12,13,14];

say "value: [12,13,14] is a color !" unless check( $value,
    {ref => 'ARRAY', length => { is => 3 }, ARRAY => {element => { min => 0, max => 255 }}}, 'color array',
);
say "got equal check !" unless not_equal( $value, $value, 'color array' );
say "not equal :",             not_equal( $value, [12,13,15], 'color array' );


sub check {
    my ($value, $parameter, $value_name) = @_;

    {
        my $parameter = $parameter->{'ref'};
        {
            my $value = $parameter;
            return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
            return "$value_name is a reference" unless not ref $value;                         # basic type: not_ref
        }
        return "$value_name is not a $parameter reference" unless ref $value eq $parameter;
    }
    {
        my $property = 'length';
        my $parameter = $parameter->{$property};
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value = @$value;
        {
            my $parameter = $parameter->{'is'};
            return "$value_name value of '$value' is not equal to '$parameter'" unless $value == $parameter;
        }
    }
    {
        my $parameter = $parameter->{'ARRAY'};
            for my $index (0 .. $#$value) {
                my $value = $value->[$index];
                my $parameter = $parameter->{'element'};
                my $value_name = "$value_name element nr. $index";

                return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int

                {
                    my $parameter = $parameter->{'min'};
                    {
                        my $value = $parameter;
                        return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                        return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                    }
                    return "$value_name is not greater or equal $parameter" unless $value >= $parameter;
                }
                {
                    my $parameter = $parameter->{'max'};
                    {
                        my $value = $parameter;
                        return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                        return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                    }
                    return "$value_name is not less or equal $parameter" unless $value <= $parameter;
                }
            }

    }
    return '';
}

sub not_equal {
    my ($value, $parameter, $value_name) = @_;
    $value_name //= "";
    {
        my $property = 'length';
        my $value = @$value;
        my $parameter = @$parameter;
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?

        return "$value_name value of '$value' is not equal to '$parameter'" unless $value == $parameter;
    }
    {
        for my $index (0 .. $#$value) {
            my $value = $value->[$index];
            my $parameter = $parameter->[$index];
            my $value_name = "$value_name element nr. $index";

            return "$value_name value of '$value' is not equal to '$parameter'" unless $value == $parameter;
        }
    }
    return '';
}




