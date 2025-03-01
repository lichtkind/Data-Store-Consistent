
#

package Data::Store::Consistent::Event;
use v5.12;
use warnings;

sub new {
    my ($pkg, $type_set, $name, $help, $type, $default) = @_;
    return 'need a data set object as first argument' unless ref $type_set eq 'Data::Store::Consistent::Type::Set';
    return 'need a node name as second argument' unless defined $name and $name;
    return 'need help text as third argument' unless defined $help and $help;
    $type //= 'any';
    return 'unkown type' unless $type_set->has_type( $type );
    $default //= $type_set->get_default_value( $type );

    bless { name => $name, help => $help, type => $type, checker => $type_set->get_type_checker( $type ),
            read_callbacks => [], write_callbacks => [],
          };
}

1
