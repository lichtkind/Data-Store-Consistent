
# basic type assembly from definition
#
# int is parent of num is parent of not_ref  of defined
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
map { my $T = assemble($_); $type_store->{ $T->{'name'} } = $T } @type_def;

sub assemble {
    my $type_def = shift;
    return unless ref $type_def eq 'HASH';
    my $type = {%$type_def};
say $type->{'name'};
    $type->{'check_source'} = (exists $type->{'condition'})
                            ? ['return "$value_name should be '.$type->{'help'}.'" unless '.$type->{'condition'}.";\n" ]
                            : [];
    $type->{'check_source'} = [@{$type_store->{ $type->{'parent'} }{'check_source'}}, @{$type->{'check_source'}} ] if exists $type->{'parent'};

    my $check_args_code = 'my ($value, $value_name, $parameter) = @_;'."\n";
    my $default_name = '$value_name //= "value";'."\n";
    my $tail_code = "return ''; \n";
    my @lines = ($check_args_code, $default_name, @{$type->{'check_source'}}, $tail_code);
    @lines = map {'  '.$_} @lines;
    my $check_code = wrap_code_in_anon_sub( join '', @lines );
say $check_code;
    $type->{'checker_ref'} = eval $check_code;
    return if $@;

    $type->{'default_value'} = $type_store->{ $type->{'parent'} }{'default_value'} unless exists $type->{'default_value'};
    return if $type->{'default value'};

    $type->{'eq_source'} = (exists $type->{'equality'})
                         ? 'return "$value_name of $value_a is not equal to $value_b" unless '.$type->{'equality'}.";\n"
                         : $type_store->{ $type->{'parent'} }->{'eq_source'} ;
    my $eq_args_code = 'my ($value_a, $value_b, $value_name) = @_;'."\n";
    @lines = ($eq_args_code, $default_name, $type->{'eq_source'}, $tail_code);
    @lines = map {'  '.$_} @lines;
    my $eq_code = wrap_code_in_anon_sub( join '', @lines );
    $type->{'eq_ref'} = eval $eq_code;
    return if $@;
    return $type;
}
sub wrap_code_in_anon_sub { return 'sub {'."\n".$_[0]."}\n" if defined $_[0] }

my $value = 45;
say "is $value an integer?";

say "looks good"         unless check( $value, 'number of states');
say "also equal to 45 !" unless not_equal( $value, 45, 'number of states');

sub check     { $type_store->{'int'}{'checker_ref'}->(@_) }
sub not_equal { $type_store->{'int'}{'eq_ref'}->(@_)      }


# return "$value_name is not $help "
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
   source
   check_ref
   eq_ref

