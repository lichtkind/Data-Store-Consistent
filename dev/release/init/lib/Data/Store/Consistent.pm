
# main module, public API

package Data::Store::Consistent;
use v5.12;
use warnings;
use Data::Store::Consistent::Type;
use Data::Store::Consistent::Schema;

sub new {
    my ($pkg, $schema, $types, $actions) = @_;
    return unless ref $schema eq 'HASH'
           and (not defined $types or ref $types eq 'ARRAY')
           and (not defined $actions or ref $actions eq 'ARRAY');
    # check args
    # check types
    # check actions
    # check schema
    # check check action cycles
    # eval types
    # eval schema: create tree from schema
    # eval actions
    #
    # bless {root => }
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
