
# data type like bool, int, num, str, etc

package Data::Store::Consistent::Type::Store;
use v5.12;
use warnings;

my %all;
my %basic;
my %parametric;
my %argument_by_parent;
my %argument_parents;
my %property_by_parent;
my %property_parents;
my %combinator;

sub get_type {
    my ($name) = @_;
    if (ref $name eq 'ARRAY') {
    } elsif (not ref $name){
    }
}
########################################################################
sub add_basic {
    my ($type) = @_;
    return 'type has to be a HASH' unless ref $type eq 'HASH';
    return 'type name is already used' if exists $all{ $type->{'name'} };
    $all{ $type->{'name'} } = 'basic';
    $basic{ $type->{'name'} } = $type;
}
sub get_basic {
    my ($type) = @_;
}

########################################################################
sub add_parametric {
    my ($type) = @_;
    return 'type has to be a HASH' unless ref $type eq 'HASH';
    return 'type name is already used' if exists $all{ $type->{'name'} };
    $all{ $type->{'name'} } = 'parametric';
    $parametric{ $type->{'name'} } = $type;
}
sub get_parametric {
    my ($type) = @_;
}

sub add_argument {
    my ($type) = @_;
    return 'type has to be a HASH' unless ref $type eq 'HASH';
    return 'type name is already used' if exists $all{ $type->{'name'} };
    $all{ $type->{'name'} } = 'argument';
    $argument{ $type->{'name'} } = $type;
}
sub get_argument {
    my ($type) = @_;
}

########################################################################
sub add_property {
    my ($type) = @_;
    return 'type has to be a HASH' unless ref $type eq 'HASH';
    return 'type name is already used' if exists $all{ $type->{'name'} }
        and (   ($all{ $type->{'name'} } ne 'property')
             or exists $property_parents{$type->{'name'}}{$type->{'parent'}} );
    $all{ $type->{'name'} } = 'property';
    $property_parents{ $type->{'name'} }{ $type->{'parent'} } = $type;
    $property_by_parent{ $type->{'parent'} } {$type->{'name'} } = $type;
    my ($type) = @_;
}
sub get_propety {
    my ($type) = @_;
}

########################################################################
sub add_combinator {
    my ($type) = @_;
    return 'type has to be a HASH' unless ref $type eq 'HASH';
    return 'type name is already used' if exists $all{ $type->{'name'} };
    $all{ $type->{'name'} } = 'combinator';
    $combinator{ $type->{'name'} } = $type;
}
sub get_combinator {
    my ($type) = @_;
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

basic
  ~name
   --
  ~help
  ~parent         |
  $default_value  |
  ~check_code     |
  ~eq_code        |
   ==
   source
   check_ref
   eq_ref

parametric: +
  :param_name
   param_type

argument: +
   name
  ~parent
 :$value

property: +
  ~name
  ~help
  ~code
 :~type
  ~parent

combinator: +
  ~name
  ~help ?
  ~parent
  @~check_code
  @~eq_code
 :%sub_type name => pos
  ~$default_value

