
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

sub add_type {
    my ($self, $name, $help, $condition, $parent, $default_value, $equality) = @_;
    return 'type misses name'                      unless defined $name and $name and not ref $name;
    return "type $name misses help text"           unless defined $help and $help and not ref $help;
    return "type $name already exists is type set" if exists $self->{ $name };
    return "type $name requires unknow parent"     if defined $parent and not exists $self->{ $parent };
    my $has_parent = int(defined $parent and $parent and not ref $parent);
    return "type $name misses source code of condition or parent"
                     unless (defined $condition and $condition and not ref $condition) or $has_parent;
    return "type $name misses default value or parent"
                     unless (defined $default_value and not ref $default_value) or $has_parent;
    return "type $name misses equality chacker code or parent"
                     unless (defined $equality and $equality and not ref $equality) or $has_parent;
    $self->_add_type( $name, $help, $condition, $parent, $default_value, $equality );
}
sub _add_type {
    my ($self, $name, $help, $condition, $parent, $default_value, $equality) = @_;
    $default_value = $self->{$parent}{'default_value'} unless defined $default_value;

    my $code = (defined $condition)
               ? '  return "$name value: $value'." needed to be of type $name, but failed test: $help!\" unless $condition;\n" : '';
    $code = $self->{$parent}{'code'} . $code if defined $parent;
    my $whole_sub = "sub { \n".'  my($value, $name, $params) = @_;'."\n".
                               '  $name //= ""; no warnings "all";'."\n". $code . "  return ''\n}";
    my $coderef = eval $whole_sub;
    return "type '$name' condition source 'code' - '$whole_sub' - could not eval because: $@ !" if $@;

    my $error = $coderef->( $default_value );
    return "type '$name' default value does not conform to type checks: $error!" if $error;

    $equality = $self->{$parent}{'equality'} unless defined $equality;
    my $eq_ref;
    if (defined $equality) {
        my $eq_source = 'sub {($a, $b) = @_; return '.$equality.' }';
        $eq_ref = eval $eq_source;
        return "type '$name' equality source 'code' - '$eq_source' - could not eval because: $@ !" if $@;
    } else {
        $eq_ref = $self->{$parent}{'equality'}
    }

    $parent = (not defined $parent)                   ? []
            : (not exists $self->{$parent}{'parent'}) ? [$parent]
            :                                           [$parent, @{$self->{$parent}{'parent'}}];

    $self->{$name} = { parent => $parent, default_value => $default_value,
                       code => $code, type_check => $coderef, eqality => $eq_ref };
    0;
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
