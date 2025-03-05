
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

sub get_schema {
    Data::Store::Consistent::Schema::schema_from_data_tree( $_[0]->{'data_tree'} );
}

sub add_node        { my $self = shift; $self->{'data_tree'}->add_node( @_ ) }
sub remove_node     { my $self = shift; $self->{'data_tree'}->remove_node( @_ ) }

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
    $node->->triggers->remove( @param );
}
sub freeze_trigger    {
    my ($self, $node_path, @param) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->freeze( @param );
}
sub thaw_trigger    {
    my ($self, $node_path, @paramy) = @_;
    my $node = $self->get_node( $node_path );
    return $node unless ref $node;
    $node->triggers->thaw( @param );
}

#### base IO ###########################################################
sub get_node { my ($self, $node_path) = @_; $self->{'data_tree'}->get_node( $node_path ) }
sub read_data { my ($self, $node_path) = @_; $self->{'data_tree'}->read_data( $node_path ) }
sub read_data_silent {
    my ($self, $node_path) = @_;
    $self->{'data_tree'}->read_data_silent( $node_path )
}
sub write_data {
    my ($self, $node_path, $data) = @_;
    $self->{'data_tree'}->write_data( $node_path, $data )
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
