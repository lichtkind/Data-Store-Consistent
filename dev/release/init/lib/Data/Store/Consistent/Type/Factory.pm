
# assemble type objects from definition

package Data::Store::Consistent::Type::Factory;
use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number blessed/;
use List::Util qw/reduce sum0/;
use Data::Store::Consistent::Type::Store;

# load the defaults

########################################################################
sub assemble_from_definition {
    my ($def) = @_;
    my $set = {};
    add_type_def($set, $_) for @Data::Store::Consistent::Type::Definition::basic;
    bless $set;
}

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

sub assemble_basic {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};

    return "type def of basic type: $type->{name} contains unknown parent type name"
        unless ref link_lineage( $type );

    my $return_val_source = (exists $type->{'ancestor'}{'defined'}) ? 'of \'$value\' ' : '';
    $return_val_source = 'return "$value_name '.$return_val_source.'should be ';
    $type->{'checker_source'} = [];
    $type->{'checker_source'} = [ $return_val_source . $type->{'description'}.'" unless '.$type->{'condition'}.";" ]
        if exists $type->{'condition'} and exists $type->{'description'};

    my $checker_source = wrap_checker_source( combine_ancestor_checker_source( $type ) );
    $type->{'checker'} = eval $checker_source;
    return "type checker code of basic type $type->{name} has issue: $@" if $@;

    return "basic type $type->{name} needs default value or parent"
        unless exists $type->{'default_value'} or exists $type->{'parent'};
    $type->{'default_value'} = $type->{'parent'}{'default_value'} unless exists $type->{'default_value'};
    my $default_value = $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'};
    return 'default value of basic type $type->{name} does not pass its own type check'
        if $type->{'checker'}->( $default_value, {}, 'test default value' );

    return "basic type $type->{name} needs equality condition: 'equality' or parent with one"
        unless exists $type->{'equality'} or exists $type->{'parent'};
    $type->{'eq_checker'} = eval wrap_checker_source( set_eq_source( $type ) );
    return "value equality checker code of basic type $type->{name} has issue: $@" if $@;
    return 'default value of basic type $type->{name} does not pass its own equality check'
        if $type->{'eq_checker'}->( $default_value, $default_value, 'test default value' );

    return $type;
}

sub assemble_parametric {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};

    return "type def of parametric type: $type->{name} contains unknown parent type name"
        unless ref link_lineage($type);
    if ($type->{'parameter_type'}){
        if (exists $type_store->{ $type->{'parameter_type'} }){
            $type->{'parameter_type'} = $type_store->{ $type->{'parameter_type'} };
        } else { return "type def of parametric type: $type->{name} contains unknown parameter type name: $type->{'parameter_type'}" }
    }

    my $return_val_source = (exists $type->{'ancestor'}{'defined'}) ? 'of \'$value\' ' : '';
    $return_val_source = 'return "$value_name '.$return_val_source.'should be ';
    $type->{'checker_source'} = [ '{', 'my $parameter = $parameter->{"'.$type->{'name'}.'"};',
                                  $return_val_source . $type->{'description'}.'" unless '.$type->{'condition'}.";", '}' ];
    $type->{'parameter_checker_source'} = [ '{', 'my $value = $parameter;',
                                            'my $value_name = "$value_name parameter \''.$type->{'name'}.'\'";',
                                            combine_ancestor_checker_source($type->{'parameter_type'}) ,'}' ];
    my @lines = @{$type->{'checker_source'}};        # insert point: 2
    splice @lines, 2, 0, @{$type->{'parameter_checker_source'}};
    unshift @lines, combine_ancestor_checker_source( $type->{'parent'} );
    my $checker_source = wrap_checker_source( @lines );
    $type->{'checker'} = eval $checker_source;
    return "type checker code of parametric type $type->{name} has issue: $@" if $@;

    $type->{'default_value'} = $type->{'parent'}{'default_value'} unless exists $type->{'default_value'};
    my $default_value = $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'};
    my $param = $type->{'parameter_type'}{'default_value'} ? (eval $type->{'parameter_type'}{'default_value'})
                                                           : $type->{'parameter_type'}{'default_value'};
    return 'default value of parametric type $type->{name} does not pass own type checks'
        if $type->{'checker'}->( $default_value, { $type->{'name'} => $param }, 'test default values' );

    return "parametric type $type->{name} needs equality condition: 'equality' or parent with one"
        unless exists $type->{'equality'} or exists $type->{'parent'};
    $type->{'eq_checker'} = eval wrap_checker_source( set_eq_source( $type ) );
    return "value equality checker code of parametric type $type->{name} has issue: $@" if $@;
    return 'default value of parametric type $type->{name} does not pass its own equality check'
        if $type->{'eq_checker'}->( $default_value, $default_value, 'test default value' );

    return $type;
}

sub assemble_argument {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};

    return "type def of argument type: $type->{name} contains unknown parent type name"
        unless ref link_lineage($type);
    return '"parametric_type" of argument type: $type->{name} is unkown!'
        unless exists $type_store->{ $type->{'parametric_type'} };
    $type->{'parametric_type'} = $type_store->{ $type->{'parametric_type'} };
    unless (exists $type->{'parent'}){
        $type->{'parent'} = $type->{'parametric_type'}{'parent'};
        $type->{'ancestor'} = $type->{'parametric_type'}{'ancestor'};
    }

    my $return_val_source = (exists $type->{'ancestor'}{'defined'}) ? 'of \'$value\' ' : '';
    $return_val_source = 'return "$value_name '.$return_val_source.'should be ';
    my $condition = $type->{'parametric_type'}{'condition'};
    my $val = '"' . $type->{'parameter_value'} . '"';
    $condition =~ s/\$parameter/$val/;
    $type->{'checker_source'} = [ $return_val_source . $type->{'description'}.'" unless '.$condition.";" ];

    $type->{'checker'} = eval wrap_checker_source( combine_ancestor_checker_source( $type ) );
    return "type checker code of argument type $type->{name} has issue: $@" if $@;

    $type->{'default_value'} = $type->{'parametric_type'}{'default_value'} unless exists $type->{'default_value'};
    my $default_value = $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'};
    return 'default value of argument type $type->{name} does not pass own type checks'
        if $type->{'checker'}->( $default_value, { }, 'test default value' );

    return "argument type $type->{name} needs equality condition: 'equality' or parent with one"
        unless exists $type->{'equality'} or exists $type->{'parent'};
    $type->{'eq_checker'} = eval wrap_checker_source( set_eq_source( $type ) );
    return "value equality checker code of argument type $type->{name} has issue: $@" if $@;
    return 'default value of argument type $type->{name} does not pass its own equality check'
        if $type->{'eq_checker'}->( $default_value, $default_value, 'test default value' );

    return $type;
}

sub assemble_property {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $property = {%$type_def};

    return "type property def: $property->{name} contains unknown parent type name"
        unless ref link_lineage( $property );
    return "type property $property->{name} has unknow type: $property->{type}!"
        unless exists $type_store->{ $property->{'type'} };
    $property->{'type'} = $type_store->{ $property->{'type'} };

    $property->{'seed_source'} = ['$property{\''."$property->{name}'} = $property->{calculation};"];
    my @boiler_plate_source = ('{','my $property_name = \''.$property->{name}.'\';',
                               'my $value = $property{$property_name};',
                               'my $parameter = $parameter->{$property_name} if ref $parameter eq "HASH" and exists $parameter->{$property_name};',
                               'my $value_name = "$property_name of $value_name";');
    $property->{'checker_source'} = [@boiler_plate_source, '',combine_ancestor_checker_source( $property->{'type'} ), '}' ];
    $property->{'source_insert_pos'} = -1;
    return $property;
}

########################################################################
sub link_lineage {
    my $type = shift;
    return unless ref $type eq 'HASH';
    $type->{'ancestor'} = {};
    if (exists $type->{'parent'}){
        if (exists $type_store->{ $type->{'parent'} }){
            $type->{'parent'} = $type_store->{ $type->{'parent'} };
            $type->{'ancestor'} = { $type->{'parent'}{'name'} => $type->{'parent'}, %{$type->{'parent'}{'ancestor'}} };
        } else { return;  }
    }
    $type;
}

sub combine_ancestor_checker_source {
    my $type = shift;
    my @lines = @{$type->{'checker_source'}};
    while (exists $type->{'parent'}){
        $type = $type->{'parent'};
        unshift @lines, @{$type->{'checker_source'}};
    }
    @lines;
}

sub set_eq_source {
    my $type = shift;
    $type->{'eq_source'} = 'return "$value_name has value of \'$value\', but expected was \'$parameter\'" unless '.
                            $type->{'equality'}.";" if exists $type->{'equality'};
    $type->{'eq_source'} = $type->{'parent'}{'eq_source'} unless exists $type->{'eq_source'};
    $type->{'eq_source'};
}

sub wrap_checker_source {
    my @lines = @_;
    unshift @lines, 'sub {',  'my ($value, $parameter, $value_name) = @_;', '$value_name //= "value";';
    push @lines,   "return '';", '}';
    join '', map { $_."\n" } @lines;
}
########################################################################
1;
