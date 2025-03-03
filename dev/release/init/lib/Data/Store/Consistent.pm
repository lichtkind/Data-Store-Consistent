
# main module, public API

package Data::Store::Consistent;
use v5.12;
use warnings;
use Data::Store::Consistent::Actions;
use Data::Store::Consistent::Schema;
use Data::Store::Consistent::Type;

sub new {
    my ($pkg, $schema, $type_defs, $action_defs, $config) = @_; # maybe config
    return unless ref $schema eq 'HASH'
           and (not defined $type_defs or ref $type_defs eq 'ARRAY')
           and (not defined $action_defs or ref $action_defs eq 'ARRAY');

    my $type_store = Data::Store::Consistent::Type->new();
    for my $type_def (@$type_defs) {
        return 'got invalid type definition' unless $type_store->add( $type_def );
    }

    my $data_tree = Data::Store::Consistent::Schema::build_data_tree_from_schema( $schema );
    return $data_tree unless ref $data_tree;                    # returning error

    my $actions = Data::Store::Consistent::Actions->new();
    for my $type_def (@$action_defs) {
        my $error = $actions->add_action( $tree, $type_def );
        return 'got invalid action definition: '.$error if $error;
    }
    bless { data_tree => $data_tree, actions => $actions };
}


sub add_action      { my $self = shift; $self->{'actions'}->add( $self->{'data_tree'}, @_ ); }
sub remove_action   { my $self = shift; $self->{'actions'}->remove( @_ ); }
sub pause_action    { my $self = shift; $self->{'actions'}->pause( @_ ); }
sub resume_action   { my $self = shift; $self->{'actions'}->resume( @_ ); }
sub action_names    { my $self = shift; $self->{'actions'}->get_names( @_ ); }
sub action_property { my $self = shift; $self->{'actions'}->get_property( @_ ); }

sub read_data       { my $self = shift; $self->{'data_tree'}->read(@_); }
sub write_data      { my $self = shift; $self->{'data_tree'}->write(@_); }
sub get_node        { my $self = shift; $self->{'data_tree'}->get_node(@_); }


1;

__END__

=pod

=head1 NAME

Data::Store::Consistent -

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
