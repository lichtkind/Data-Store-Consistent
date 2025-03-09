
# data type like bool, int, num, str, etc

package Data::Store::Consistent::Type::Store;
use v5.12;
use warnings;


my %type;

sub add {
    my ($type) = @_;
}

sub get {
    my ($name, $kind) = @_;
}

sub has_type {
    my ($name, $kind) = @_;
}

########################################################################

1;
__END__

sub get_type_property {
    my ($self, $name, $property) = @_;
    return "need a type name as first argument" unless defined $name and $name;
    return "type $name is not element of this set" unless exists $self->{ $name };
    return "need a type property for $name as second argument" unless defined $property and $property;
    return $self->{ $name }{'help'}          if $property eq 'help';
    return $self->{ $name }{'type_check'}    if $property eq 'type_checker';
    return $self->{ $name }{'default_value'} if $property eq 'default_value';
    return "unknown type property: $property, try type_chacker, help or default_value";
}

sub has_type { (exists $_[0]->{ $_[1] }) ? 1 : 0 }
