
# holding data tree, trigger scheduling

package Data::Store::Consistent::Tree;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Root;

sub new {
    my ($pkg) = @_;
    my $trigger = Data::Store::Consistent::Node::Actions->new();
    my $root = Data::Store::Consistent::Node::Root->new();
    bless { root => $root, trigger => $trigger };
}

#### base access #######################################################
sub root     { $_[0]->{'root'} }
sub get_node { $_[0]->root->get_node( $_[1] ) }

sub add_node        {
    my ($self, $node_def, $node_path) = @_;
    my $node = Data::Store::Consistent::Schema::node_from_definition( $node_def );
    return $node unless ref $node;
    $self->root->add_node( $node, $node_path );
}
sub remove_node     {
    my ($self, $node_path) = @_;
    $self->root->remove_node( $node_path );
}

#### trigger ###########################################################
sub add_callback      {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->add( @param );
}
sub remove_callback      {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->remove( @param );
}
sub freeze_callback    {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->freeze( @param );
}
sub thaw_callback    {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->thaw( @param );
}

#### base IO ###########################################################
sub read_data        { my ($self, $node_path) = @_; $self->root->read_node( $node_path ); }
sub silent_read_data { my ($self, $node_path) = @_; $self->root->silent_read_node( $node_path ); }
sub write_data       { my ($self, $node_path, $data) = @_; $self->root->write_node( $node_path, $data ); }

1;

__END__

process writers in right order
update type params --> type checks
outward callbacks
