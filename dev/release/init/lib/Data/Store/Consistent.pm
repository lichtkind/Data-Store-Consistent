
# main module, public API

package Data::Store::Consistent;
use v5.12;
use warnings;
use Data::Store::Consistent::Schema;
use Data::Store::Consistent::Type;

sub new {
    my ($pkg, $schema, $type_defs, $config) = @_; # maybe config
    return unless ref $schema eq 'HASH'
           and (not defined $type_defs or ref $type_defs eq 'ARRAY');

    for my $type_def (@$type_defs) {
        my $error = Data::Store::Consistent::Type::add( $type_def );
        return "got invalid type definition: $type_def - problem: $error" if $error;
    }

    my $data_tree = Data::Store::Consistent::Schema::build_data_tree_from_schema( $schema );
    return $data_tree unless ref $data_tree;                    # returning error

    bless { data_tree => $data_tree };
}

#### schema ############################################################
sub add_type        {
    my ($self, $type_def) = @_;
    Data::Store::Consistent::Type::add( $type_def );
}
sub remove_type     {
    my ($self, $type_name) = @_;
    Data::Store::Consistent::Type::remove( $type_name );
}
sub add_node        {
    my ($self, $node_def) = @_;
    $self->{'data_tree'}->add( $node_def );
    my $self = shift; $self->{'data_tree'}->add( @_ );
}
sub remove_node     {
    my ($self, $node_ID) = @_;
    $self->{'data_tree'}->remove( $node_ID );
}
sub get_schema      {
    Data::Store::Consistent::Schema::schema_from_data_tree( $_[0]->{'data_tree'} );
}

#### trigger ###########################################################
sub add_trigger      {
    my ($self, $node_ID, @param) = @_;
    my $node = $self->get_node( $node_ID );
    return $node unless ref $node;
    $node->triggers->add( @param );
}
sub remove_trigger      {
    my ($self, $node_ID, @param) = @_;
    my $node = $self->get_node( $node_ID );
    return $node unless ref $node;
    $node->->triggers->remove( @param );
}
sub freeze_trigger    {
    my ($self, $node_ID, @param) = @_;
    my $node = $self->get_node( $node_ID );
    return $node unless ref $node;
    $node->triggers->freeze( @param );
}
sub thaw_trigger    {
    my ($self, $node_ID, @param) = @_;
    my $node = $self->get_node( $node_ID );
    return $node unless ref $node;
    $node->triggers->thaw( @param );
}
sub name_trigger    {
    my ($self, $node_ID, @param) = @_;
    my $node = $self->get_node( $node_ID );
    return $node unless ref $node;
    $node->triggers->names( @param );
}
sub get_trigger_property {
    my ($self, $node_ID, @param) = @_;
    my $node = $self->get_node( $node_ID );
    return $node unless ref $node;
    $node->triggers->property( @param );
}

#### base IO ###########################################################
sub read_data       {
    my ($self, $node_ID) = @_;
    my $node = $self->get_node($node_ID);
    return $node unless ref $node;
    $node->read();
}

sub write_data      {
    my ($self, $node_ID, $data) = @_;
    my $node = $self->get_node($node_ID);
    return $node unless ref $node;
    $node->write( $data );
}

sub get_node {
    my ($self, $node_ID) = @_;
    $self->{'data_tree'}->get_node( $node_ID );
}


1;

__END__

=pod

=head1 NAME

Data::Store::Consistent - storage with consistency checks and autocompletion

=head1 SYNOPSIS



=head1 SEE ALSO


=head1 AUTHOR

Herbert Breunung (lichtkind@cpan.org)

=head1 COPYRIGHT & LICENSE

Copyright(c) 2025 by Herbert Breunung

All rights reserved.
This program is free software and can be used, changed and distributed
under the GPL 3 licence.

=cut
