
# data type like bool, int, num, str, etc

package Data::Store::Consistent::Type::Store;
use v5.12;
use warnings;
use Data::Store::Consistent::Type::Validate;
use Data::Store::Consistent::Type::Default;

my %type = (all => {}, parametric => {}, argument => {}, combinator => {},
            property_by_parent => {}, property_parents => {}, );


########################################################################
sub add_type {
    my ($type) = @_;
    my ($error, $kind) = Data::Store::Consistent::Type::Validate::get_kind($type);
    return $error if $error;
    my $name = $type->{'name'};
    my $parent = $type->{'parent'};
    if ($kind eq 'property'){
        return "type property $name of $parent already exists" if exists $type{'all'}{ $name }
               and (   ($all{ $type->{'name'} } ne 'property')
                    or (exists $property_parents{$type->{'name'}}{$type->{'parent'}}));
    } else {
        return "type name $name is already in use" if exists $type{'all'}{ $name };
        $type{ 'all' }{ $name } = $kind;
        $type{ $kind }{ $name } = $type;
    }
}

sub remove_type {
    my ($name) = @_;
}

########################################################################
sub has_type      { (exists $_[0]->{ $_[1] }) ? 1 : 0 }
sub get_type_kind { (exists $_[0]->{ $_[1] }) ? 1 : 0 }

sub get_type {
    my ($name) = @_;
    return unless exists $type{ 'all' }{ $name };
    my $kind = $type{ 'all' }{ $name };

    if (ref $name eq 'ARRAY') {
    } elsif (not ref $name){
    }
}

sub get_type_checker {
    my ($name) = @_;
    if (ref $name eq 'ARRAY') {
    } elsif (not ref $name){
    }
}

sub get_eq_checker {
    my ($name) = @_;
    if (ref $name eq 'ARRAY') {
    } elsif (not ref $name){
    }
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
