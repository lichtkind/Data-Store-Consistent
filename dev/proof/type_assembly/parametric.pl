
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
my $type = assemble_full('int{0,255}');

my $value = 45;
say "$value a color value !" unless $type->{'checker'}->( $value, 'color value', {min => 0, max => 255} );
say "is equal to $value !"   unless $type->{'equal'}->( $value, $value, 'color value', {min => 0, max => 255});
say "not equal to 0 !"       if $type->{'equal'}->( $value, 0, 'color value', {min => 0, max => 255});
say "bad argument, ",  $type->{'checker'}->( $value, 'color value', {min => 0, max => 'max'});


sub assemble_full {
    my $type_def = shift;
    return {};
}

sub assemble_parametric {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';

    my $type = {%$type_def};
    my $parent = (exists $type->{'parent'}) ? $type_store->{ $type->{'parent'} } : undef;
    $type->{'parent'} = (defined $parent) ? [@{$parent->{'parent'}}, $type->{'parent'}]
                                          : [];

    my $condition_start = (exists $type->{'parent'}[0] and $type->{'parent'}[0] eq 'defined') ? 'of $value ' : '';
    $condition_start = 'return "$value_name '.$condition_start.'should be ';
    my $condition_source = (exists $type->{'condition'}) ? $condition_start . $type->{'help'}.'" unless '.$type->{'condition'}.";" : undef;
    my $paramtype = (exists $type->{'parameter_type'}) ? $type_store->{ $type->{'parameter_type'} } : undef;
    $type->{'checker_source'} = [];
    push @{$type->{'checker_source'}}, @{$parent->{'checker_source'}} if defined $parent;
    push @{$type->{'checker_source'}}, '{', 'my $parameter = $parameter->{"'.$type->{'name'}.'"};';
    push @{$type->{'checker_source'}}, '{', 'my $value = $parameter;';          # not for arg types
    push @{$type->{'checker_source'}}, @{$paramtype->{'checker_source'}}, '}';  # not for arg types
    push @{$type->{'checker_source'}}, $condition_source, '}' ;

    my $checker_args_source = 'my ($value, $value_name, $parameter) = @_;';
    my $default_name_source = '$value_name //= "value";';
    my $return_source = "return '';";
    my @lines = ($checker_args_source, $default_name_source, @{$type->{'checker_source'}}, $return_source);
    @lines = map { '  '.$_."\n" } @lines;
    my $checker_source = wrap_source_in_anon_sub( join '', @lines );
    $type->{'checker'} = eval $checker_source;
    return if $@;

say $checker_source;

    $type->{'default_value'} = $type_store->{ $type->{'parent'} }{'default_value'} unless exists $type->{'default_value'};
    say $type->{'checker'}->( $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'} );

    $type->{'eq_source'} = (exists $type->{'equality'})
                       ? 'return "$value_name is $value_a, which is not equal to $value_b" unless '.$type->{'equality'}.";"
                       : (defined $parent)
                       ? $parent->{'eq_source'} : return 'type def missing parent or equality checker source';
    my $eq_args_source = 'my ($value_a, $value_b, $value_name) = @_;';
    @lines = ($eq_args_source, $default_name_source, $type->{'eq_source'}, $return_source);
    @lines = map { '  '.$_."\n" } @lines;
    my $eq_source = wrap_source_in_anon_sub( join '', @lines );
    $type->{'equal'} = eval $eq_source;
    return if $@;

    return $type;
}



sub assemble_basic {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';

    my $type = {%$type_def};
    my $parent = (exists $type->{'parent'}) ? $type_store->{ $type->{'parent'} } : undef;
    $type->{'parent'} = (defined $parent) ? [@{$parent->{'parent'}}, $type->{'parent'}]
                                          : [];

    my $checker_source_start = (exists $type->{'parent'}[0] and $type->{'parent'}[0] eq 'defined') ? 'of $value ' : '';
    $checker_source_start = 'return "$value_name '.$checker_source_start.'should be ';
    $type->{'checker_source'} = [];
    push @{$type->{'checker_source'}}, @{$parent->{'checker_source'}} if defined $parent;
    push @{$type->{'checker_source'}}, $checker_source_start . $type->{'help'}.'" unless '.$type->{'condition'}.";"
        if exists $type->{'condition'} and exists $type->{'help'};

    my $checker_args_source = 'my ($value, $value_name) = @_;';
    my $default_name_source = '$value_name //= "value";';
    my $return_source = "return '';";
    my @lines = ($checker_args_source, $default_name_source, @{$type->{'checker_source'}}, $return_source);
    @lines = map { '  '.$_."\n" } @lines;
    my $checker_source = wrap_source_in_anon_sub( join '', @lines );
    $type->{'checker'} = eval $checker_source;
    return if $@;

    $type->{'default_value'} = $type_store->{ $type->{'parent'} }{'default_value'} unless exists $type->{'default_value'};
    say $type->{'checker'}->( $type->{'default_value'} ? (eval $type->{'default_value'}) : $type->{'default_value'} );

    $type->{'eq_source'} = (exists $type->{'equality'})
                       ? 'return "$value_name is $value_a, which is not equal to $value_b" unless '.$type->{'equality'}.";"
                       : (defined $parent)
                       ? $parent->{'eq_source'} : return 'type def missing parent or equality checker source';
    my $eq_args_source = 'my ($value_a, $value_b, $value_name) = @_;';
    @lines = ($eq_args_source, $default_name_source, $type->{'eq_source'}, $return_source);
    @lines = map { '  '.$_."\n" } @lines;
    my $eq_source = wrap_source_in_anon_sub( join '', @lines );
    $type->{'equal'} = eval $eq_source;
    return if $@;
    return $type;
}


sub wrap_source_in_anon_sub { return 'sub {'."\n".$_[0]."}\n" if defined $_[0] }

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
   checker_source
   eq_source
   checker
   equal

parametric: basic + (check_source is mandatory)
  :param_type
   ==
