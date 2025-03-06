
# node holding other nodes in data tree structure

package Data::Store::Consistent::Node::Inner;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Outer;

sub new {
    my ($pkg, $name, $description, $note) = @_;
    return 'need a name for this inner data tree node' unless defined $name;

    bless { name => $name, description => $description // '', note => $note // '', child => {} };
}

sub name        { $_[0]->{'name'} }
sub description { $_[0]->{'description'} }
sub note        { $_[0]->{'note'} }
sub change_note { $_[0]->{'note'}  = $_[1] }

#### node API ##########################################################
sub get_child   {
    my ($self, $node_name) = @_;
    return $self->{'child'}{ $node_name } if exists $self->{'child'}{ $node_name };
}


sub add_child        {
    my ($self, $node) = @_;
    return 'can add only add inner and out data tree nodes' unless ref $node eq 'Data::Store::Consistent::Node::Innter'
                                                                or ref $node eq 'Data::Store::Consistent::Node::Outer';
    return 'node '.$node->name.' already exists as a child of '.$self->name if exists $self->{'child'}{ $node->name };
    $self->{'child'}{ $node->{'name'} } = $node;
}

sub remove_child     {
    my ($self, $node_name) = @_;
    return 'got no node name' unless defined $node_name and $node_name;
    return 'node '.$node_name.'does not exist' unless exists $self->{'child'}{ $node_name };
    delete  $self->{'child'}{ $node_name };
}

#### IO API ############################################################
sub read {
    my ($self, $silent) = @_;
    return { map { $_ => $self->{'child'}{ $_ }->read( $silent ) } keys %{$self->{'child'}} };
}

sub write {
    my ($self, $data) = @_;
    return 'got no data HASH' unless ref $data eq 'HASH';
    my $error_sum = '';
    for my $child_name (keys %{$self->{'child'}}){
        unless (exists $data->{$child_name}) {
            $error_sum .= "data for node $child_name is missing;";
            next;
        }
        my $error = $self->{'child'}{ $child_name }->write( $data->{$child_name} );
        $error_sum .= $error.';' if $error;
    }
    return $error_sum;
}

sub reset {
    my ($self) = @_;
    map { $_->reset } values %{$self->{'child'}};
}

########################################################################

1;
