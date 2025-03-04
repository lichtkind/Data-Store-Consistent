
# assemble type objects from definition

package Data::Store::Consistent::Type::Factory;
use v5.12;
use warnings;
use Scalar::Util qw/blessed looks_like_number/;
use Data::Store::Consistent::Type::Store;

sub create_type_object {
    my ($def) = @_;
    my $set = {};
    add_type_def($set, $_) for @Data::Store::Consistent::Type::Definition::basic;
    bless $set;
}

sub add_type_def {
    my ($self, $def) = @_;
    return unless ref $def eq 'HASH' and exists $def->{'name'} and exists $def->{'help'};
    _add_type($self, $def->{'name'}, $def->{'help'}, $def->{'code'},
                     $def->{'parent'}, $def->{'default'}, $def->{'equality'} );
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
