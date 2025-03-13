
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

say "looks good !" unless check_named( $value, 'color hash',
    {ref => 'HASH', length => { is => 3 }, HASH => {key => {in_set => ['red','green','blue',]},
                                                  value => { min => 0, max => 255 }}},
);
say "got equal check !" unless not_equal( $value,    {red => 12, green => 13, blue => 14}, 'color hash' );
say "not equal check keys !" if not_equal( $value,   {redd => 12, green => 13, blue => 14}, 'color hash' );
say "not equal check values !" if not_equal( $value, {red => 11, green => 13, blue => 14}, 'color hash' );

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
        my $value = keys(%$value);
        {
            my $value_a = $value;
            my $value_b = $param->{'is'};
            return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
        }
    }
    {
        my $param = $param->{'HASH'};
        {
            for my $key (sort keys %$value) {
                my $value = $value->{$key};

                {
                    my $param = $param->{'key'};
                    my $value_name = "$value_name key $key";
                    my $value = $key;

                    return "$value_name is not a defined value" unless defined $value;      # basic type: defined
                    return "$value_name is a reference" unless not ref $value;              # basic type: not_ref
                    {
                        my $param = $param->{'in_set'};
                        return "$value_name of $value is not part of list @$param"
                            unless reduce {$a || ($b eq $value)} 0, @$param;
                    }
                }
                {
                    my $param = $param->{'value'};
                    my $value_name = "$value_name value under key $key";

                    return "$value_name is not a defined value" unless defined $value;                 # basic type: defined
                    return "$value_name is not any type of number" unless looks_like_number($value);   # basic type: num
                    return "$value_name is not number without decimals" unless int($value) == $value;  # basic type: int
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

sub not_equal {
    my ($value_a, $value_b, $value_name) = @_;
    $value_name //= "";

    {
        my $property = 'length';
        my $value_name = "$property of $value_name "; # how get ARRAY at end of this ?
        my $value_a = keys(%$value_a);
        my $value_b = keys(%$value_b);

        return "$value_name of $value_a is not equal to " unless $value_a == $value_b;
    }
    {
        for my $key (sort keys %$value_a) {
            my $value_a = $value_a->{$key};
            {
                my $value_name = "$value_name key $key";
                return "$value_name does not exist in both HASHES" unless exists $value_b->{$key};
            }
            my $value_b = $value_b->{$key};
            {
                my $value_name = "$value_name value under key $key";
                return "$value_name of $value_a is not equal to $value_b" unless $value_a == $value_b;
            }
        }
    }

    return '';
}
