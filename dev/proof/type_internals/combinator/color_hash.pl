
# create var in sub scope while using outer var that just gets overwritten
#
# HASH<set:red,green,blue>< int: min(0), max(255) >
# %<red|green|blue><int{0,255}>

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;
use List::Util qw/reduce/;

my $value = {red => 12, green => 13, blue => 14};
say "is value: {red => 12,green => 13, blue => 14,} a HASH color ?";

say "looks good !" unless check_named( $value,
    {ref => 'HASH', length => { is => 3 }, HASH => {key => {in_set => ['red','green','blue',]},
                                                  value => { min => 0, max => 255 }}},  'color hash',
);
say "got equal check !" unless not_equal( $value, {red => 12, green => 13, blue => 14}, 'color hash' );
say "bad key: ",               not_equal( $value, {redd => 12,green => 13, blue => 14}, 'color hash' );
say "bas value: ",             not_equal( $value, {red => 11, green => 13, blue => 14}, 'color hash' );

sub check_named {
    my ($value, $parameter, $value_name) = @_;

    {
        my $parameter = $parameter->{'ref'};
        return "$value_name is not a '$parameter' reference" unless ref $value eq $parameter;
    }
    {
        my $property = 'length';
        my $parameter = $parameter->{$property};
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value = keys(%$value);
        {
            my $parameter = $parameter->{'is'};
            return "$value_name value of '$value' is not equal to '$parameter'" unless $value == $parameter;
        }
    }
    {
        my $parameter = $parameter->{'HASH'};
        {
            for my $key (sort keys %$value) {
                my $value = $value->{$key};

                {
                    my $parameter = $parameter->{'key'};
                    my $value_name = "$value_name key $key";
                    my $value = $key;

                    return "$value_name is not a defined value" unless defined $value;      # basic type: defined
                    return "$value_name is a reference" unless not ref $value;              # basic type: not_ref
                    {
                        my $parameter = $parameter->{'in_set'};
                        return "$value_name of $value is not part of list @$parameter"
                            unless reduce {$a || ($b eq $value)} 0, @$parameter;
                    }
                }
                {
                    my $parameter = $parameter->{'value'};
                    my $value_name = "$value_name value under key $key";

                    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int
                    {
                        my $parameter = $parameter->{'min'};
                        return "$value_name value of '$value' is not greater or equal '$parameter'" unless $value >= $parameter;
                    }
                    {
                        my $parameter = $parameter->{'max'};
                        return "$value_name value of '$value' is not less or equal '$parameter'" unless $value <= $parameter;
                    }
                }
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
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value = keys(%$value);
        my $parameter = keys(%$parameter);

        return "$value_name value of '$value' is not equal to '$parameter'" unless $value == $parameter;
    }
    {
        for my $key (sort keys %$value) {
            my $value = $value->{$key};
            {
                my $value_name = "$value_name key '$key'";
                return "$value_name does not exist in both HASHES" unless exists $parameter->{$key};
            }
            my $parameter = $parameter->{$key};
            {
                my $value_name = "$value_name value under key '$key'";
                return "$value_name value of '$value' is not equal to '$parameter'" unless $value == $parameter;
            }
        }
    }

    return '';
}
