
# type property mechanic on example of string of lengths of 3
#
# str[length:is(3)])
# str{3}

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my @basic_type_def = (
 {name=> 'defined', description=> 'a defined value',         condition=> 'defined $value',                                 default_value=> '', equality=> '$value eq $parameter',},
 {name=> 'not_ref', description=> 'not a reference',         condition=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'str',     description=> 'string of characters',                                              parent=> 'not_ref',               },
 {name=> 'num',     description=> 'any type of number',      condition=> 'looks_like_number($value)',  parent=> 'not_ref', default_value=> '0', equality=> '$value == $parameter',},
 {name=> 'int',     description=> 'number without decimals', condition=> 'int($value) == $value',      parent=> 'num',                   },
);

my @param_type_def = (
 {name=> 'min',     description=> 'greater or equal then minimum of $parameter', condition=> '$value >= $parameter', parent=> 'num', parameter_type=> 'num',},
 {name=> 'max',     description=> 'less or equal then maximum of $parameter',    condition=> '$value <= $parameter', parent=> 'num', parameter_type=> 'num',},
 {name=> 'inf',     description=> 'greater then infimum of $parameter',          condition=> '$value >  $parameter', parent=> 'num', parameter_type=> 'num', default_value => '1'},
);

my @property_def = (
  {name=> 'length', description=> 'length of a string',  calculation=> 'length($value)', parent=> 'str'  ,   type=> 'int' },
);

my $type_store = {};
map { my $T = assemble_basic($_); $type_store->{ $T->{'name'} } = $T }      @basic_type_def;
map { my $T = assemble_parametric($_); $type_store->{ $T->{'name'} } = $T } @param_type_def;
map { my $T = assemble_property($_); $type_store->{ $T->{'name'} } = $T }   @property_def;
my $type = assemble_full('str [ length:is( 3 ) ] ');

my $value = '101';
say "$value has is str of length 3 !" unless $type->{'checker'}->( $value, {length => {is => 3}}, 'one cellgraph pattern' );
say "is equal to '$value' !"    unless $type->{'eq_checker'}->( $value, $value,  'one cellgraph pattern');
say "not equal to '010' !"          if $type->{'eq_checker'}->( $value, '010',  'one cellgraph pattern');
# say "bad argument, ",           $type->{'checker'}->( 0, {}, 'zero');


sub assemble_full {
    my $type_desciption = shift;
    $type_desciption =~ tr/ //d; # delete space
    my $ret_type = {};
    my ($type, $properties) = split('\[', $type_desciption);
    $properties =~ tr/]//d;
    my ($base_type, $param_types) = split(':', $type);
    return "base type $base_type is unknown" unless exists $type_store->{ $base_type };
    $base_type = $type_store->{ $base_type };

    my (@properties) = split(';', $properties);
    return 'no type properties in square brackets' unless @properties;
    my @prop_def;
    for my $property (@properties){
        my ($name, @conditions) = split(':', $property);
        push @prop_def, [$name, []];
        for my $condition (@conditions){
            chop $condition;
            my ($name, $args) = split('\(', $condition);
             my (@args) = split(',', $args);
            push @{$prop_def[-1][1]}, [$name, \@args];
        }
    }
    my @lines = (combine_ancestor_checker_source( $base_type ), '', 'my %property = (id => $value);');
    for my $property (@prop_def){
        my $name = $property->[0];
        return "type property '$name' is unkown" unless exists $type_store->{ $name };
        $property->[0] = $type_store->{ $name };
        my $parent = $property->[0]{'parent'}{'name'};
        return "type property '$name' can only derive from type '$parent'"
            unless $parent eq $base_type->{'name'} or exists $base_type->{'ancestor'}{$parent};
        push @lines, @{$property->[0]{'seed_source'}};
    }
    for my $property (@prop_def){
        my $prop_obj = $property->[0];
        my @prop_lines = @{$prop_obj->{'checker_source'}};
        for my $add_type (@{$property->[1]}){
            if ($add_type->[0] eq 'is'){
                return "equality check definition in property '$prop_obj->{name}' is missing an argument"
                    unless exists $add_type->[1] and @{$add_type->[1]} == 1;
                splice(@prop_lines, $prop_obj->{'source_insert_pos'}, 0, '{',
                'return "equality check parameter for type property \'$property_name\' is missing" unless ref $parameter eq "HASH" and exists $parameter->{is};',
                'my $parameter = $parameter->{is};',
                $prop_obj->{'type'}{'eq_source'},
                '}');
            }
        }
        push @lines, @prop_lines;
    }
    $ret_type->{'checker'} = eval wrap_checker_source( @lines );
    return "custom type '$type_desciption' has issue: $@" if $@;
    $ret_type->{'eq_checker'} = $base_type->{'eq_checker'};
    $ret_type;
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


__END__
property: +
  ~name
  ~description
  ~calculation
  ~parent
  ~type
    --
    ==
  %ancestor
  @~checker_source
   ~eq_source
  &checker
  &eq_checker


