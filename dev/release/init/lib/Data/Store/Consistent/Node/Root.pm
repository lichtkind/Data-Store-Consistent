
# root of data tree, node search

package Data::Store::Consistent::Node::Root;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Inner;


sub new {
    my ($pkg, $note) = @_;
    bless { child => {} , note => $note//''};
}
sub note        { $_[0]->{'note'} }
sub change_note { $_[0]->{'note'}  = $_[1] }

#### local node API - same as inner node ###############################
sub get_child    { Data::Store::Consistent::Node::Inner::get_child(@_) }
sub add_child    { Data::Store::Consistent::Node::Inner::add_child(@_) }
sub remove_child { Data::Store::Consistent::Node::Inner::remove_child(@_) }

sub read         { Data::Store::Consistent::Node::Inner::read(@_) }
sub write        { Data::Store::Consistent::Node::Inner::write(@_) }
sub reset        { Data::Store::Consistent::Node::Inner::reset(@_) }

#### node path ops #####################################################
sub split_path {
    my ($node_path) = @_;
    return unless defined $node_path and $node_path;
    my $path_wo_attr = (split(':', $node_path))[0];
    return split '/', $path_wo_attr;
}

sub join_path {
    return unless @_;
    return '/'.join('/', @_);
}

#### global node API ###################################################
sub node_exists {
    my ($self, $node_path) = @_;
    (ref $self->get_node($node_path)) ? 1 : 0;
}
sub get_node {
    my ($self, $node_path) = @_;
    my $node = $self;
    my $current_path = '';
    for my $name ( split_path($node_path) ){
        $node = $node->get_child( $name );
        return "node path $current_path has no child named $name" unless ref $node;
    }
    return $node;
}

sub add_node        {
    my ($self, $node, $node_path) = @_;
    my $parent = $self->get_node( $node_path );
    return $parent unless ref $parent;
    return 'can not attach a node to an outer node like '.$node_path
        if ref $node eq 'Data::Store::Consistent::Node::Outer';
    $node->add_child( $node );
}

sub remove_node     {
    my ($self, $node_path) = @_;
    return 'can not remove root node' unless defined $node_name and $node_name;
    my @names = split_path($node_path);
    my $last_name = pop @names;
    my $parent_path = join_path(@names);
    my $node = $self->get_node( $parent_path );
    return $node unless ref $node;
    return "node path $parent_path has no child named $last_name" unless ref $node->get_child($last_name);
    $node->remove_child( $last_name );
}

#### IO API ############################################################
sub read_node {
    my ($self, $node_path) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->read();
}

sub silent_read_node {
    my ($self, $node_path) = @_;
    my ($self, $node_path) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->read( 1 );
}

sub write_node {
    my ($self, $node_path, $data) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->write( $data );
}



1;
