
# node holding other nodes in data tree structure

package Data::Store::Consistent::Node::Accessor;
use v5.12;
use warnings;
use Data::Store::Consistent::Node::Root;

sub new {
    my ($pkg, $node, $read_permission, $write_permission) = @_;
    return 'got no node to access' unless ref $node eq 'Data::Store::Consistent::Node::Inner'
                                       or ref $node eq 'Data::Store::Consistent::Node::Outer';

    bless { name => $name, description => $description // '', note => $note // '', child => {} };
}



#### node API ##########################################################
sub get_node {
    my ($self, $silent) = @_;
    return { map { $_ => $self->{'child'}{ $_ }->read( $silent ) } keys %{$self->{'child'}} };
}

#### node API ##########################################################
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
