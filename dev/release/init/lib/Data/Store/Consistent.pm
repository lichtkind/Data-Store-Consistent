
# main module, public API

package Data::Store::Consistent;
use v5.12;
use warnings;
use Data::Store::Consistent::Schema;
use Data::Store::Consistent::Tree;
use Data::Store::Consistent::Type;

sub new {
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
    # bless {data => {}, actions => {}};
}


sub add_action {
    my ($self, $name, $trigger, $target, $code) = @_;
}
sub remove_action {
    my ($self, $name) = @_;
}
sub pause_action {
    my ($self, $name) = @_;
}
sub resume_action {
    my ($self, $name) = @_;
}
sub get_all_action_names {
    my ($self, $name) = @_;
}
sub get_action_property {
    my ($self, $name, $property_name) = @_;
}


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
