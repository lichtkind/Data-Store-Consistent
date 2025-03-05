
# holding data tree, trigger scheduling

package Data::Store::Consistent::Tree;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Root;

sub new {
    my ($pkg) = @_;
    { root = Data::Store::Consistent::Node::Root->new(), trigger => '' }
}

#### base access #######################################################
sub root     { $_[0]->{'root'} }
sub get_node { $_[0]->root->get_node( $node, $_[1] ) }

sub add_node        {
    my ($self, $node_def, $node_path) = @_;
    my $node = Data::Store::Consistent::Schema::node_from_definition( $node_def );
    return $node unless ref $node;
    $self->root->add_node( $node, $node_path );
}
sub remove_node     {
    my ($self, $node_path) = @_;
    $self->root->add_node( $node, $node_path );
}



#### trigger ###########################################################
sub add_trigger      {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->add( @param );
}
sub remove_trigger      {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->remove( @param );
}
sub freeze_trigger    {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->freeze( @param );
}
sub thaw_trigger    {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->thaw( @param );
}

#### base IO ###########################################################
sub read_data {
    my ($self, $node_path) = @_;
    $self->root->read_node( $node_path );
}

sub silent_read_data {
    my ($self, $node_path) = @_;
    $self->root->silent_read_node( $node_path );
}

sub write_data      {
    my ($self, $node_path, $data) = @_;
    $self->root->write_node( $node_path, $data );
}



1;
