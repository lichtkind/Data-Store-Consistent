
# main module

package Data::Store::Consistent;
use v5.12;
use warnings;
use Data::Store::Consistent::Type;
use Data::Store::Consistent::Schema;

sub new {
    my ($pkg, $schema, $types, $actions) = @_;
    # eval args
    # check types
    # eval types
    # eval schema
    # bless {root => }
}

sub add_type {
    my ($self, $name, $help, $code, $parent -- $default ) = @_; # $parent can be undef when $default exists
    # check info
    # name free
    # compile type
    # return error if
    # insert type into set
    # return 1;
}

sub remove_type {
    my ($self, $name) = @_;
    # exists name
}


sub add_action {
    my ($self, $name, $trigger, $target, $code) = @_;
}
sub remove_action {
    my ($self, $name) = @_;
}
sub pause_action {
    my ($self, $name) = @_;
}
sub resume_action {
    my ($self, $name) = @_;
}
sub get_all_action_names {
    my ($self, $name) = @_;
}
sub get_action_property {
    my ($self, $name, $property_name) = @_;
}


sub read_data {
    my ($self, $node_ID) = @_;
    # node exists ?
    # trigger action
    # return data
}
sub write_data {
    my ($self, $node_ID, $data) = @_;
    # node exists ?
    # data of type ?
    # data different ?
    # write data
    # trigger action
}

sub get_node {
    my ($self, $node_ID, $data) = @_;
    # node exists ?
}

1;
