
# extendable collection of type objects came from D::S::C::Type

package Data::Store::Consistent::Type::Set;
use v5.12;
use warnings;
use Scalar::Util qw/blessed looks_like_number/;
use Data::Store::Consistent::Type::Definition;

sub new {
    my $pkg = shift;
    my $set = {};
    add_type_def($set, $_) for @Data::Store::Consistent::Type::Definition::list;
    bless $set;
}


sub add_type_def {
    my ($self, $def) = @_;
    return unless ref $def eq 'HASH' and exists, $def->{'name'} and exists $def->{'help'};
    $self->add_type( $def->{'name'}, $def->{'help'}, $def->{'code'},
                     $def->{'parent'}, $def->{'default'}, $def->{'equality'} );
}

sub add_type {
    my ($self, $name, $help, $condition, $parent, $default_value, $equality) = @_;
    return 'type misses name'                      unless defined $name and $name and not ref $name;
    return "type $name misses help text"           unless defined $help and $help and not ref $help;
    return "type $name already exists is type set" if exists $self->{ $name };
    return "type $name requires unknow parent"     if defined $parent and not exists $self->{ $parent };
    my $has_parent = defined $parent and $parent and not ref $parent;
    return "type $name misses source code of condition or parent"
                     unless (defined $condition and $condition and not ref $condition) or $has_parent;
    return "type $name misses default value or parent"
                     unless (defined $default_value and not ref $default_value) or $has_parent;
    return "type $name misses equality chacker code or parent"
                     unless (defined $equality and equality and not ref $equality) or $has_parent;

    $default_value = $self->{$parent}{'default_value'} unless defined $default_value;
    $equality      = $self->{$parent}{'equality'} unless defined $equality;

    my $checks = (defined $condition) ? [$help, $condition] : [];
    $checks = [@{$self->{$parent}{'checks'}}, @$checks] if defined $parent;
    my $source = '';
    for (my $i = 0; $i < @$checks; $i+=2) {
        $source .= 'return "value $value'." needed to be of type $name, but failed test: $checks->[$i]\" unless $checks->[$i+1];"
    }

    $source = 'sub { my( $value ) = @_; no warnings "all";'. $source . "return ''}";
    my $coderef = eval $source;
    return "type '$name' condition source 'code' - '$source' - could not eval because: $@ !" if $@;

    my $error = $coderef->( $default_value );
    return "type '$name' default value triggers type checks: $error!" if $error;

    my $eq_source = 'sub {($a, $b)= @_; '.$equality.'}';
    my $eq_ref = eval $source;
    return "type '$name' equality source 'code' - '$eq_source' - could not eval because: $@ !" if $@;

    $self->{$name} = { parent => $parent, default_value => $default_value,
                       checks => $checks, type_check => $coderef, euality => $eq_ref };
    0;
}

sub get_type_property {
    my ($self, $name, $property) = @_;
    return "need a type name as first argument" unless defined $name and $name;
    return "type $name is not element of this set" unless exists $self->{ $name };
    return "need a type property for $name as second argument" unless defined $property and $property;
    return $self->{ $name }{'help'}          if $property eq 'help';
    return $self->{ $name }{'type_check'}    if $property eq 'type_checker';
    return $self->{ $name }{'default_value'} if $property eq 'default_value';
    return "unknown type property: $property";
}

sub has_type { (exists $_[0]->{ $_[1] }) ? 1 : 0 }

1;
