
# assemble type objects from definition

package Data::Store::Consistent::Type::Validate;
use v5.12;
use warnings;

#### public API ########################################################
sub definition {
    my ($def) = @_;
    my $kind = get_kind( $def );
    return "type definition is no HASH" unless $kind;
    my $error = ($kind eq 'basic')      ? basic(      $def ) :
                ($kind eq 'parametric') ? parametric( $def ) :
                ($kind eq 'argument')   ? argument(   $def ) :
                ($kind eq 'property')   ? property(   $def ) :
                ($kind eq 'parametric') ? parametric( $def ) :
                ($kind eq 'combinator') ? combinator( $def ) : 'unknown kind of type';
    return $error, $kind;
}

sub get_kind {
    my ($def) = @_;
    return unless ref $def eq 'HASH';
    my $kind = (exists $def->{'parameter_type'})  ? 'parametric' :
               (exists $def->{'parameter_value'}) ? 'argument'   :
               (exists $def->{'calculation'})     ? 'property'   :
               (exists $def->{'component_pos'})   ? 'combinator' : 'basic';
    $kind;
}

########################################################################
sub basic {
    my ($def) = @_;
    return "type definition is no HASH" unless ref $def eq 'HASH';
    my $error_sum = '';
    $error_sum .= "type definition lacks property name\n"        unless exists $def->{ 'name' };
    $error_sum .= "type definition lacks property description\n" unless exists $def->{ 'description' };
    unless (exists $def->{ 'parent' }){
        for my $key (qw/condition equality default_value/){
            $error_sum .=  "type definition without parent has to have property: '$key'\n" unless exists $def->{ $key };
        }
    }
    for my $key (qw/name description condition equality parent/){
        return "type property: '$key' has to be a string \n" if exists $def->{$key} and not is_str( $def->{$key} );
    }
    return $error_sum;
}

sub parametric {
    my ($def) = @_;
    return "type definition is no HASH" unless ref $def eq 'HASH';
    my $error_sum = basic( $def );
    for my $key (qw/parameter_type/){
        $error_sum .= "type definition lacks property $key" unless exists $def->{ $key };
        $error_sum .= "type property $key has to be a string" unless is_str( $def->{ $key } );
    }
    return $error_sum;
}

sub argument {
    my ($def) = @_;
    return "type definition is no HASH" unless ref $def eq 'HASH';
    my $error_sum = '';
    for my $key (qw/name description parametric_type parameter_value/){
        $error_sum .= "type definition lacks property $key" unless exists $def->{ $key };
        next if $key eq 'parameter_value';
        $error_sum .= "type property '$key' has to be a string" unless is_str( $def->{$key} );
    }
    return $error_sum;
}

sub property {
    my ($def) = @_;
    return "type definition is no HASH" unless ref $def eq 'HASH';
    my $error_sum = '';
    for my $key (qw/name description calculation type parent/){
        $error_sum .= "type definition lacks property $key" unless exists $def->{ $key };
        $error_sum .= "type property $key has to be a string" unless is_str( $def->{ $key } );
    }
    return $error_sum;
}

sub combinator {
    my ($def) = @_;
    return "type definition is no HASH" unless ref $def eq 'HASH';
    my $error_sum = '';
    for my $key (qw/name help check_code eq_properties component_check component_pos default_value parent/){
        return "type definition lacks property $key" unless exists $def->{ $key };
    }
    for my $key (qw/name help parent default_value/){
        return "combinator type property $key has to be a string" unless is_str( $def->{ $key } );
    }
    for my $key (qw/check_code eq_properties component_pos/){
        return "combinator type property '$key' has to be an ARRAY"   unless ref $def->{ $key } eq 'ARRAY';
    }
    return "combinator type property 'component_check' has to be a HASH" unless ref $def->{ 'component_check' } eq 'HASH';
    for my $val (values %{$def->{ 'component_check' }}, values %{$def->{ 'component_pos' }}, ){
        return "combinator type property 'component_check' values have to be integer" unless defined $val and int $val == $val;
    }
    for my $val (@{$def->{ 'check_code' }}){
        return "combinator type property 'check_code' has to be a list of strings" unless is_str( $val );
    }
    for my $val (@{$def->{ 'eq_properties' }}){
        return "combinator type property 'eq_properties' has to be a list of strings" unless is_str( $val );
    }
    return $error_sum;
}

#### util ##############################################################
sub is_str { (defined $_[0] and $_[0] and not ref $_[0]) ? 1 : 0 }

1;

__END__
# basic
  ~name
  ~description
   --
  ~condition      |
  ~equality       |
  $default_value  |
  ~parent         |-


# parametric:
  ~name
  ~description
  ~condition
  :parameter_type
   --
  ~equality       |
  $default_value  |
  ~parent         |-


# argument:
  ~name
  ~description
  ~parametric_type
 :$parameter_value
   --


# property:
  ~name
  ~description
 :~calculation
  ~type
  ~parent
   --


# combinator:
  ~name ... of the combination (UC !)
  ~description
  ~parent
  ~@$default_value
  @~check_code
  @~eq_code
  @~default_code
 :@component_pos    name, name

  @~eq_properties
  %component_check  name => pos
