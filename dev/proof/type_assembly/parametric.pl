
# parametric type mechanics on example of min and max
# unless argument types, parameter types have to be checked at run time every time
#
# int[min(0); max(255);]
# int{0,255}

use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my @basic_type_def = (
 {name=> 'defined', help=> 'a defined value',         condition=> 'defined $value',                                 default_value=> '', equality=> '$value_a eq $value_b',},
 {name=> 'not_ref', help=> 'not a reference',         condition=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'num',     help=> 'any type of number',      condition=> 'looks_like_number($value)',  parent=> 'not_ref', default_value=> 0,  equality=> '$value_a == $value_b',},
 {name=> 'int',     help=> 'number without decimals', condition=> 'int($value) == $value',      parent=> 'num',                   },
);

my @param_type_def = (
 {name=> 'min',     help=> 'greater or equal then minimum of $parameter', condition=> '$value >= $parameter', parent=> 'num', parameter_type=> 'num',},
 {name=> 'max',     help=> 'less or equal then maximum of $parameter',    condition=> '$value <= $parameter', parent=> 'num', parameter_type=> 'num',},
);


my $type_store = {};
map { my $T = assemble_basic($_); $type_store->{ $T->{'name'} } = $T } @basic_type_def;
map { my $T = assemble_parametric($_); $type_store->{ $T->{'name'} } = $T } @param_type_def;
my $type = assemble_full('int:min(0),max(255)');

my $value = 45;
say "$value a color value !" unless $type->{'checker'}->( $value, 'color value', {min => 0, max => 255} );
say "is equal to $value !"   unless $type->{'eq_checker'}->( $value, $value, 'color value', {min => 0, max => 255});
say "not equal to 0 !"       if $type->{'eq_checker'}->( $value, 0, 'color value');
say "bad argument, ",           $type->{'checker'}->( $value, {min => 0, max => 'max'}, 'color value');


sub assemble_full {
    my $type_desciption = shift;
    my $type = {};
    my ($basic_type, $param_types) = split(':', $type_desciption);
    $basic_type = $type_store->{ $basic_type };
    my @param_types = split(',', $param_types);
    @param_types = map {$_->[-1] =~ tr/)//d; $_} map {[split(/\(/, $_)]} @param_types;

    my @lines = basic_source_lines( $basic_type );
#    say "@$_" for @param_types if ;

 say '--';
    return $basic_type;
}

sub assemble_parametric {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};

    $type->{'ancestor'} = {};
    if (exists $type->{'parent'}){
        if (exists $type_store->{ $type->{'parent'} }){
            $type->{'parent'} = $type_store->{ $type->{'parent'} };
            $type->{'ancestor'} = { $type->{'parent'}{'name'} => $type->{'parent'}, %{$type->{'parent'}{'ancestor'}} };
        } else { return 'type def of parametric type: $type->{name} contains unknown parent type name' }
    }
    if ($type->{'parameter_type'}){
        if (exists $type_store->{ $type->{'parameter_type'} }){
            $type->{'parameter_type'} = $type_store->{ $type->{'parameter_type'} };
        } else { return 'type def of parametric type: $type->{name} contains unknown parameter type name' }
    }

    my $return_val_source = (exists $type->{'ancestor'}{'defined'}) ? 'of $value ' : '';
    $return_val_source = 'return "$value_name '.$return_val_source.'should be ';
    $type->{'checker_source'} = [];
    $type->{'checker_source'} = [ $return_val_source . $type->{'help'}.'" unless '.$type->{'condition'}.";" ]
        if exists $type->{'condition'} and exists $type->{'help'};

    my @lines = ('{', 'my $parameter = $parameter->{"'.$type->{'name'}.'"};', basic_source_lines( $type ), '}'); # insert point: 2
    splice @lines, 2, 0, ('{', 'my $value = $parameter;', basic_source_lines($type->{'parameter_type'}) ,'}');
    my $checker_source = join '', map { $_."\n" } wrap_anon_checker_sub( @lines );
    $type->{'checker'} = eval $checker_source;
    return "type checker code of parametric type $type->{name} has issue: $@" if $@;

  say $checker_source;

    return "parametric type $type->{name} needs default value or parent"
        unless exists $type->{'default_value'} or exists $type->{'parent'};
    $type->{'default_value'} = $type->{'parent'}{'default_value'} unless exists $type->{'default_value'};
    my $value = $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'};
    my $param = $type->{'parameter_type'}{'default_value'} ? (eval $type->{'parameter_type'}{'default_value'})
                                                           : $type->{'parameter_type'}{'default_value'};
    return 'type  default value does not pass type checks'
        if $type->{'checker'}->( $value, { $type->{'name'} => $param }, 'test default values' );


    return "parametric type $type->{name} needs equality condition: 'equality' or parent"
        unless exists $type->{'equality'} or exists $type->{'parent'};
    $type->{'eq_source'} = 'return "$value_name is $value_a, which is not equal to $value_b" unless '.
                            $type->{'equality'}.";" if exists $type->{'equality'};
    $type->{'eq_source'} = $type->{'parent'}{'eq_source'} unless exists $type->{'eq_source'};
    my $eq_source = join '', map { $_."\n" }
        'sub {',  'my ($value_a, $value_b, $value_name) = @_;',
        '$value_name //= "value";', $type->{'eq_source'}, "return '';", '}';
    $type->{'eq_checker'} = eval $eq_source;
    return "value equality checker code of parametric type $type->{name} has issue: $@" if $@;

say $eq_source;

    return $type;
}

sub assemble_basic {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};

    $type->{'ancestor'} = {};
    if (exists $type->{'parent'}){
        if (exists $type_store->{ $type->{'parent'} }){
            $type->{'parent'} = $type_store->{ $type->{'parent'} };
            $type->{'ancestor'} = { $type->{'parent'}{'name'} => $type->{'parent'}, %{$type->{'parent'}{'ancestor'}} };
        } else { return "type def of basic type: $type->{name} contains unknown parent type name" }
    }

    my $return_val_source = (exists $type->{'ancestor'}{'defined'}) ? 'of $value ' : '';
    $return_val_source = 'return "$value_name '.$return_val_source.'should be ';
    $type->{'checker_source'} = [];
    $type->{'checker_source'} = [ $return_val_source . $type->{'help'}.'" unless '.$type->{'condition'}.";" ]
        if exists $type->{'condition'} and exists $type->{'help'};

    my $checker_source = join '', map { $_."\n" } wrap_anon_checker_sub( basic_source_lines( $type ) );
    $type->{'checker'} = eval $checker_source;
    return "type checker code of basic type $type->{name} has issue: $@" if $@;

    return "basic type $type->{name} needs default value or parent"
        unless exists $type->{'default_value'} or exists $type->{'parent'};
    $type->{'default_value'} = $type->{'parent'}{'default_value'} unless exists $type->{'default_value'};
    return 'default value of basic type $type->{name} does not pass its own type check'
        if $type->{'checker'}->( $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'} );

    return "type $type->{name} needs equality condition: 'equality' or parent"
        unless exists $type->{'equality'} or exists $type->{'parent'};
    $type->{'eq_source'} = 'return "$value_name is $value_a, which is not equal to $value_b" unless '.
                            $type->{'equality'}.";" if exists $type->{'equality'};
    $type->{'eq_source'} = $type->{'parent'}{'eq_source'} unless exists $type->{'eq_source'};
    my $eq_source = join '', map { $_."\n" }
        'sub {',  'my ($value_a, $value_b, $value_name) = @_;',
        '$value_name //= "value";', $type->{'eq_source'}, "return '';", '}';
    $type->{'eq_checker'} = eval $eq_source;
    return "value equality checker code of basic type $type->{name} has issue: $@" if $@;
    return $type;
}


sub basic_source_lines {
    my $type = shift;
    my @lines = @{$type->{'checker_source'}};
    while (exists $type->{'parent'}){
        $type = $type->{'parent'};
        unshift @lines, @{$type->{'checker_source'}};
    }
    @lines;
}

sub wrap_anon_checker_sub {
    my @lines = @_;
    unshift @lines, 'sub {',  'my ($value, $parameter, $value_name) = @_;', '$value_name //= "value";';
    push @lines,   "return '';", '}';
    @lines;
}
sub wrap_eq_checker_sub {
    my @lines = @_;
    unshift @lines, 'sub {',  'my ($value_a, $value_b, $value_name) = @_;', '$value_name //= "value";';
    push @lines,   "return '';", '}';
    @lines;
}

__END__
basic
  ~name
   --
  ~help              +
  ~check_code     |  +
  ~eq_code        |
  $default_value  |
  ~parent         |
   ==
  %ancestor
  @~checker_source
   ~eq_source
  &checker
  &eq_checker

parametric: +
  ~name
  :param_type
  ~help
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
