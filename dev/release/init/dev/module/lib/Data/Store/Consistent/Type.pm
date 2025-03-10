
# bundle all type related functionality

package Data::Store::Consistent::Type;
use v5.12;
use warnings;
use Data::Store::Consistent::Type::Default;
use Data::Store::Consistent::Type::Factory;
use Data::Store::Consistent::Type::Store;

########################################################################

sub is_valid_description {
    my ($description) = @_;

}
sub is_valid_definition {
    my ($def) = @_;

}

sub add {
    my ($name, $def) = @_;
    my $type_or_error = Data::Store::Consistent::Type::Factory::create_type_object( $def );
    return $type_or_error unless ref $type_or_error;
    Data::Store::Consistent::Type::Store::add( $type_or_error );
}

sub remove { # none default
    my ($name, $def) = @_;
    my $type_or_error = Data::Store::Consistent::Type::Factory::create_type_object( $def );
    return $type_or_error unless ref $type_or_error;
    Data::Store::Consistent::Type::Store::add( $type_or_error );
}

sub exists {
    my ($name, $kind) = @_;
    Data::Store::Consistent::Type::Store::has_type( $name, $kind );
}

sub get_property {
    my ($name, $property) = @_;
    return "need a type name as first argument" unless defined $name and $name;
    # return "type $name is not element of this set" unless exists $self->{ $name };
    # return "need a type property for $name as second argument" unless defined $property and $property;
    # return $self->{ $name }{'help'}          if $property eq 'help';
    # return $self->{ $name }{'type_check'}    if $property eq 'type_checker';
    # return $self->{ $name }{'default_value'} if $property eq 'default_value';
    return "unknown type property: $property, try type_chacker, help or default_value";
}


# create default types #################################################

Data::Store::Consistent::Type::Store::add (
    Data::Store::Consistent::Type::Factory::create_type_object( $_ ) )
        for @Data::Store::Consistent::Type::Default::basic,
            @Data::Store::Consistent::Type::Default::parametric,
            @Data::Store::Consistent::Type::Default::argument,
            @Data::Store::Consistent::Type::Default::property,
            @Data::Store::Consistent::Type::Default::combinator;

1;

__END__

types have to

 - check for compliance
 - check for equality
 - accept and store arguments
 - accept temp args
 - be combinable
 - inherit each other
 - give best possible error messages

ARRAY{}<>
