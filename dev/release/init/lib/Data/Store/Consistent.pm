
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


#sub add_action      { my $self = shift; $self->{'data_tree'}->add( @_ ); }
#sub remove_action   { my $self = shift; $self->{'data_tree'}->remove( @_ ); }
sub pause_action    { my $self = shift; $self->{'data_tree'}->pause( @_ ); }
sub resume_action   { my $self = shift; $self->{'data_tree'}->resume( @_ ); }
sub action_names    { my $self = shift; $self->{'data_tree'}->get_names( @_ ); }
sub action_property { my $self = shift; $self->{'data_tree'}->get_property( @_ ); }

sub read_data       { my $self = shift; $self->{'data_tree'}->read(@_); }
sub write_data      { my $self = shift; $self->{'data_tree'}->write(@_); }
sub get_node        { my $self = shift; $self->{'data_tree'}->get_node(@_); }


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
