
# main module, public API

package Data::Store::Consistent;
use v5.12;
use warnings;
use Data::Store::Consistent::Schema;
use Data::Store::Consistent::Tree;
use Data::Store::Consistent::Type;

sub new { # $schema -- @types, @actions, $config?
    my ($pkg, $schema, $types, $actions) = @_;
    return unless ref $schema eq 'HASH'
           and (not defined $types or ref $types eq 'ARRAY')
           and (not defined $actions or ref $actions eq 'ARRAY');
    # check args
    # check types
    # check actions
    # check schema
    # check check action cycles
    # eval types
    # eval schema: create tree from schema
    # eval actions
    #
    # bless { data_tree => {}, actions => {} };
}


sub add_action      { my $self = shift; $self->{'actions'}->add( @_ ); }
sub remove_action   { my $self = shift; $self->{'actions'}->remove( @_ ); }
sub pause_action    { my $self = shift; $self->{'actions'}->pause( @_ ); }
sub resume_action   { my $self = shift; $self->{'actions'}->resume( @_ ); }
sub action_names    { my $self = shift; $self->{'actions'}->get_names( @_ ); }
sub action_property { my $self = shift; $self->{'actions'}->get_property( @_ ); }

sub read_data {
    my ($self, $node_ID) = @_;
    # node exists ?
    # trigger action
    # return data
}
sub write_data {
    my ($self, $node_ID, $data) = @_;
    # node exists ?
    # data of type ?
    # data different ?
    # write data
    # trigger action
}

sub get_node {
    my ($self, $node_ID, $data) = @_;
    # node exists ?
}

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
