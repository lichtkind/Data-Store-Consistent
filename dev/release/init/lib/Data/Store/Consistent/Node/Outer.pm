
# data holding tree leave

package Data::Store::Consistent::Node;
use v5.12;
use warnings;

sub new {
    my ($pkg, $default_value, $help, $condition, $parent, $default) = @_;
}

sub read {
    my ($self ) = @_;
    # node exists ?
    # trigger action
    # return data
}
sub write {
    my ($self, $data) = @_;
    # node exists ?
    # data of type ?
    # data different ?
    # write data
    # trigger action
}



1;
__END__
    leaves hold data
    nodes hold nodes or leaves

    type => basic_name | 'ARRAY'| 'hash'
    description => 'help text'
    default_value => ... fall back on type default value

    leave : type, default_value?, description ?
    node : type, children, description ?,




structure:

   root: data, types,

    read_callbacks
    write_callbacks
