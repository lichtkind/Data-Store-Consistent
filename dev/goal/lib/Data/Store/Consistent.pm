
# main module

package Data::Store::Consistent;


sub new {
    my ($pkg, $schema, $data) = @_;
    # eval args
    # eval schema
    # load data
}

sub read {
    my ($self, $node_ID) = @_;
    # node exists ?
    # trigger action
    # return data
}
sub write {
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


sub add_type {
    my ($self, $name, $help, $code, $default -- $parent ) = @_; # default can be undef when $parent exists
}
sub remove_type {
    my ($self, $name, $trigger, $target, $code) = @_;
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

1;
