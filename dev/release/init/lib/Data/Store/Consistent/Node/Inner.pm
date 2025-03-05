
# node holding other nodes in data tree structure

package Data::Store::Consistent::Node::Inner;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Inner;
use Data::Store::Consistent::Node::Actions;

sub new {
    my ($pkg, $name, $help, $link_up, $write_call_back, $read_call_back) = @_;
    return 'need a data set object as first argument' unless ref $type_set eq 'Data::Store::Consistent::Type::Set';
    return 'need a node name as second argument' unless defined $name and $name;
    return 'need help text as third argument' unless defined $help and $help;
    $type //= 'any';
    return 'unkown type' unless $type_set->has_type( $type );
    $default //= $type_set->get_default_value( $type );

    bless { name => $name, help => $help, up => $link_up,
            write_trigger => $write_trigger, read_trigger => $read_trigger,
          };
}

sub get_child {
    my ($self, $node_ID, $data) = @_;
    # node exists ?
}

sub read {
    my ($self, $node ) = @_;
    # node exists ?
    # read trigger action
    # return data
}

sub write {
    my ($self, $node, $data) = @_;
    # node exists ?
    # data of type ?
    # data different ?
    # write data
    # write trigger action
}


1;
