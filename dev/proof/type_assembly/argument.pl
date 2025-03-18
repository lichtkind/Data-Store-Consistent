
# argument type mechanics on example of spos = inf 0
# unless parameter types, argument dont have to be checked only compile time
#
# spos
# inf 0

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my @basic_type_def = (
 {name=> 'defined', description=> 'a defined value',         condition=> 'defined $value',                                 default_value=> '', equality=> '$value eq $parameter',},
 {name=> 'not_ref', description=> 'not a reference',         condition=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'num',     description=> 'any type of number',      condition=> 'looks_like_number($value)',  parent=> 'not_ref', default_value=> '0',  equality=> '$value == $parameter',},
 {name=> 'int',     description=> 'number without decimals', condition=> 'int($value) == $value',      parent=> 'num',                   },
);

my @param_type_def = (
 {name=> 'min',     description=> 'greater or equal then minimum of $parameter', condition=> '$value >= $parameter', parent=> 'num', parameter_type=> 'num',},
 {name=> 'max',     description=> 'less or equal then maximum of $parameter',    condition=> '$value <= $parameter', parent=> 'num', parameter_type=> 'num',},
 {name=> 'inf',     description=> 'greater then infimum of $parameter',          condition=> '$value >  $parameter', parent=> 'num', parameter_type=> 'num', default_value => '1'},
);

my @arg_type_def = (
 {name=> 'spos',    description=> 'a strictly positive number',  parametric_type=> 'inf', parameter_value=> '0' },
);

my $type_store = {};
map { my $T = assemble_basic($_); $type_store->{ $T->{'name'} } = $T }      @basic_type_def;
map { my $T = assemble_parametric($_); $type_store->{ $T->{'name'} } = $T } @param_type_def;
map { my $T = assemble_argument($_); $type_store->{ $T->{'name'} } = $T }   @arg_type_def;
my $type = assemble_full('spos');

my $value = 45;
say "$value is strictly positive !" unless $type->{'checker'}->( $value, {}, 'random number' );
say "is equal to $value !"   unless $type->{'eq_checker'}->( $value, $value, {}, 'random number');
say "not equal to 0 !"       if $type->{'eq_checker'}->( $value, 1, 'random number');
say "bad argument, ",           $type->{'checker'}->( 0, {}, 'zero');



sub assemble_full {
    my $type_desciption = shift;
    $type_store->{ $type_desciption };
}

sub assemble_argument {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};

say $type->{'name'};

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

    my $checker_source = wrap_anon_checker_sub( combine_checker_source( $type ) );
    $type->{'checker'} = eval $checker_source;
    return "type checker code of argument type $type->{name} has issue: $@" if $@;

  say "$checker_source";

    $type->{'default_value'} = $type->{'parametric_type'}{'default_value'} unless exists $type->{'default_value'};
    my $default_value = $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'};
    return 'default value of argument type $type->{name} does not pass own type checks'
        if $type->{'checker'}->( $default_value, { }, 'test default value' );

    return "argument type $type->{name} needs equality condition: 'equality' or parent with one"
        unless exists $type->{'equality'} or exists $type->{'parent'};
    $type->{'eq_checker'} = eval wrap_anon_checker_sub( set_eq_source( $type ) );
    return "value equality checker code of argument type $type->{name} has issue: $@" if $@;
    return 'default value of argument type $type->{name} does not pass its own equality check'
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
    my $checker_source = wrap_anon_checker_sub( @lines );
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
    $type->{'eq_checker'} = eval wrap_anon_checker_sub( set_eq_source( $type ) );
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

    my $checker_source = wrap_anon_checker_sub( combine_ancestor_checker_source( $type ) );
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
    $type->{'eq_checker'} = eval wrap_anon_checker_sub( set_eq_source( $type ) );
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

sub wrap_anon_checker_sub {
    my @lines = @_;
    unshift @lines, 'sub {',  'my ($value, $parameter, $value_name) = @_;', '$value_name //= "value";';
    push @lines,   "return '';", '}';
    join '', map { $_."\n" } @lines;
}


__END__
parametric: +
  ~name
  :param_type
  ~description
  ~condition
   --
  $default_value  |
  ~parent         |
   ==
  %ancestor
  @~checker_source
   ~eq_source
  &checker
  &eq_checker

argument:
  ~name
  ~description
  ~parametric_type
  $parameter_value
   --
   ==
  %ancestor
  @~checker_source
   ~eq_source
  &checker
  &eq_checker


