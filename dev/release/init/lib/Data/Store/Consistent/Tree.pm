
#

package Data::Store::Consistent::Tree;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Inner;
use Data::Store::Consistent::Node::Outer;
use Data::Store::Consistent::Node::Root;

sub get_node {
    my ($self, $node_ID, $data) = @_;
    # node exists ?
}

sub read {
    my ($self ) = @_;
    # node exists ?
    # trigger action
    # return data
}

sub write {
    my ($self, $data) = @_;
    # node exists ?
    # data of type ?
    # data different ?
    # write data
    # trigger action
}



1;
