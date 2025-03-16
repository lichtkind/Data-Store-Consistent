
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

  say $type->{'name'};

    $type->{'parents'} = {};
    if (exists $type->{'parent'}){
        if (exists $type_store->{ $type->{'parent'} }){
            $type->{'parent'} = $type_store->{ $type->{'parent'} };
            $type->{'parents'} = { $type->{'parent'}{'name'} => $type->{'parent'}, %{$type->{'parent'}{'parents'}} };
        } else { return "type def of basic type: $type->{name} contains unknown parent type name" }
    }

    my $return_val_source = (exists $type->{'parents'}{'defined'}) ? 'of $value ' : '';
    $return_val_source = 'return "$value_name '.$return_val_source.'should be ';
    $type->{'checker_source'} = [];
    $type->{'checker_source'} = [ $return_val_source . $type->{'help'}.'" unless '.$type->{'condition'}.";" ]
        if exists $type->{'condition'} and exists $type->{'help'};

    my $T = $type;
    my @lines = @{$T->{'checker_source'}};
    while (exists $T->{'parent'}){
        $T = $T->{'parent'};
        unshift @lines, @{$T->{'checker_source'}};
    }
    unshift @lines, 'sub {',  'my ($value, $value_name) = @_;', '$value_name //= "value";';
    push @lines,   "return '';", '}';
    my $checker_source = join '', map { $_."\n" } @lines;
    $type->{'checker'} = eval $checker_source;
    return "type checker code of basic type $type->{name} has issue: $@" if $@;

  say $checker_source;

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

   say $eq_source;

    return $type;
}


my $value = 45;
my $type = 'int';

say "$value is $type"    unless check( $value, 'number of states');
say "also equal to 45 !" unless not_equal( $value, 45, 'number of states');
say not_equal( $value, 42, 'number of states');

sub check     { $type_store->{$type}{'checker'}->(@_) }
sub not_equal { $type_store->{$type}{'eq_checker'}->(@_)      }

__END__

basic
  ~name
   --
  ~help              &
  ~condition      |  &
  ~equality       |
  $default_value  |
  ~parent         |
   ==
   checker_source
   eq_source
   checker
   eq_checker
   %parents
