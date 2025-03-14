
# basic type assembly from definition
#
# doing type inheritance
# int is parent of num is parent of not_ref of defined
# defined --> not_ref --> num --> int


use v5.12;
use warnings;
use Scalar::Util qw/looks_like_number/;

my @type_def = (
 {name=> 'defined',   help=> 'a defined value',         condition=> 'defined $value',                                 default_value=> '', equality=> '$value_a eq $value_b', },
 {name=> 'not_ref',   help=> 'not a reference',         condition=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'num',       help=> 'any type of number',      condition=> 'looks_like_number($value)',  parent=> 'not_ref', default_value=> 0,  equality=> '$value_a == $value_b', },
 {name=> 'int',       help=> 'number without decimals', condition=> 'int($value) == $value',      parent=> 'num',                   },
);

my $type_store = {};
map { my $T = assemble_basic($_); $type_store->{ $T->{'name'} } = $T } @type_def;

sub assemble_basic {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};
    my $parent = (exists $type->{'parent'}) ? $type_store->{ $type->{'parent'} } : undef;
    $type->{'parent'} = (defined $parent) ? [@{$parent->{'parent'}}, $type->{'parent'}]
                                          : [];

  say $type->{'name'};

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

  say $eq_source;

    return $type;
}

sub wrap_source_in_anon_sub { return 'sub {'."\n".$_[0]."}\n" if defined $_[0] }

my $value = 45;
my $type = 'int';

say "$value is $type"    unless check( $value, 'number of states');
say "also equal to 45 !" unless not_equal( $value, 45, 'number of states');
say not_equal( $value, 42, 'number of states');

sub check     { $type_store->{$type}{'checker'}->(@_) }
sub not_equal { $type_store->{$type}{'equal'}->(@_)      }

__END__

basic
  ~name
   --
  ~help              +
  ~condition      |  +
  ~equality       |
  $default_value  |
  ~parent         |
   ==
   checker_source
   eq_source
   checker
   equal

