
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
    $self->add_type( $def->{'name'}, $def->{'help'}, $def->{'code'}, $def->{'parent'}, $def->{'default'} );
}

sub add_type {
    my ($self, $name, $help, $condition, $parent, $default_value) = @_;
    return 'type misses name'                      unless defined $name and $name and not ref $name;
    return "type $name misses help text"           unless defined $help and $help and not ref $help;
    return "type $name misses source code of condition" unless (defined $condition and $condition and not ref $condition)
                                                            or (defined $parent and $parent and not ref $parent);
    return "type $name misses parent or default value"  unless (defined $default_value and not ref $default_value)
                                                            or (defined $parent and $parent and not ref $parent);
    return "type $name already exists is type set" if exists $self->{ $name };
    return "type $name requires unknow parent"     if defined $parent and not exists $self->{ $parent };

    $default_value = $self->{$parent}{'default_value'} unless defined $default_value;

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

    $self->{$name} = { parent => $parent, default_value => $default_value, checks => $checks, coderef => $coderef };
    0;
}

sub get_type_checker {
    my ($self, $name) = @_;
    return "need a type name as first argument" unless defined $name and $name;
    return "type $name is not element of this set" unless exists $self->{ $name };
    return $self->{ $name }{'coderef'};
}

sub get_default_value {
    my ($self, $name) = @_;
    return "need a type name as first argument" unless defined $name and $name;
    return "type $name is not element of this set" unless exists $self->{ $name };
    return $self->{ $name }{'default_value'};
}

sub has_type { (exists $_[0]->{ $_[1] }) ? 1 : 0 }

1;
