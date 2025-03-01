
# data holding leave in data tree structure

package Data::Store::Consistent::Node::Outer;
use v5.12;
use warnings;
use Data::Store::Consistent::Type;

sub new {
    my ($pkg, $name, $help, $link_up, $type, $writer, $write_trigger, $read_trigger) = @_;
    return 'need a data set object as first argument' unless ref $type_set eq 'Data::Store::Consistent::Type::Set';
    return 'need a node name as second argument' unless defined $name and $name;
    return 'need help text as third argument' unless defined $help and $help;
    $type //= 'any';
    return 'unkown type' unless $type_set->has_type( $type );
    $default //= $type_set->get_default_value( $type );

    bless { name => $name, help => $help, type => $type, checker => $type_set->get_type_checker( $type ),
            read_callbacks => [], write_callbacks => [],
          };
    #~ - help: ~
    #~ - type: ~typename | ~typedef
    #~ - ?default_value: $               # optional when type name given | to init
    #~ - ?writer: &
    #~ - $write_trigger: @node_path      # trigger writer when on of these nodes changes
}

sub read {
    my ($self) = @_;
    # trigger action
    # return data
}

sub write {
    my ($self, $data) = @_;
    # data of type ?
    # data different ?
    # write data
    # trigger action
}



1;

__END__
