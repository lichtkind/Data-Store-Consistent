
# definitions of standard data types

package Data::Store::Consistent::Type::Default;
use v5.12;
use warnings;
use utf8;

our @basic = (
 {name=> 'any',       help=> 'any value',               condition=> '1',                                              default_value=> '', equality=> '$value_a eq $value_b', },
 {name=> 'defined',   help=> 'a defined value',         condition=> 'defined $value',                                 default_value=> '', equality=> '$value_a eq $value_b', },
 {name=> 'not_ref',   help=> 'not a reference',         condition=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'bool',      help=> '0 or 1',                  condition=> '$value eq 0 or $value eq 1', parent=> 'not_ref', default_value=> 0,  equality=> '$value_a == $value_b', },
 {name=> 'num',       help=> 'any type of number',      condition=> 'looks_like_number($value)',  parent=> 'not_ref', default_value=> 0,  equality=> '$value_a == $value_b', },
 {name=> 'int',       help=> 'number without decimals', condition=> 'int($value) == $value',      parent=> 'num',                   },
 {name=> 'str',       help=> 'string of characters',                                              parent=> 'not_ref',               },
 {name=> 'char',      help=> 'one character',           condition=> 'length($value) == 1',        parent=> 'str',     default_value=> 'a' },
 {name=> 'ne_str',    help=> 'none empty string',       condition=> '$value',                     parent=> 'not_ref', default_value=> ' ' },
 {name=> 'word',      help=> 'only word character',     condition=> '$value =~ /^\w+$/',          parent=> 'ne_str',  default_value=> 'A' },
 {name=> 'identifier',help=> 'begins with a letter',    condition=> '$value =~ /^[a-z_]/',        parent=> 'lc_word',               },
);

our @parametric = (
 {name=> 'min',       help=> 'greater or equal then minimum of $parameter', condition=> '$value >= $parameter',      parent => 'num',  parameter_type=> 'num', },
 {name=> 'inf',       help=> 'greater then infimum of $parameter',          condition=> '$value >  $parameter',      parent => 'num',  parameter_type=> 'num', },
 {name=> 'max',       help=> 'less or equal then maximum of $parameter',    condition=> '$value <= $parameter',      parent => 'num',  parameter_type=> 'num', },
 {name=> 'sup',       help=> 'less then supremum of $parameter',            condition=> '$value <  $parameter',      parent => 'num',  parameter_type=> 'num', },
 {name=> 'ref',       help=> 'a $parameter reference',                      condition=> 'ref $value eq $parameter',                    parameter_type=> 'str', },
 {name=> 'enum',      help=> 'part of list @$parameter',                    condition=> 'reduce {$a || ($b eq $value)} 0, @$parameter', parent => 'str',  parameter_type=> ['ARRAY','str'],},
 {name=> 'enum',      help=> 'part of list @$parameter',                    condition=> 'reduce {$a || ($b == $value)} 0, @$parameter', parent => 'num',  parameter_type=> ['ARRAY','num'],},

);

our @argument = (
 {name=> 'pos',       help=> 'positive number',         parent=> 'min',      value=> 0 },
 {name=> 'spos',      help=> 'strictly positive number',parent=> 'inf',      value=> 0 },
 {name=> 'array',     help=> 'ARRAY reference',         parent=> 'ref',      value=> 'ARRAY' },
 {name=> 'hash',      help=> 'HASH reference',          parent=> 'ref',      value=> 'HASH' },
 {name=> 'code',      help=> 'CODE reference',          parent=> 'ref',      value=> 'CODE' },
);

our @property = (
 {name=> 'length',    help=> '',                                 calculation=> '$value',         parent=> 'num'  ,   type=> '' },
 {name=> 'length',    help=> 'an string with length of $param',  calculation=> 'length($value)', parent=> 'str'  ,   type=> 'int' },
 {name=> 'length',    help=> 'number of ARRAY elements',         calculation=> '@$value',        parent=> 'array',   type=> 'int' },
 {name=> 'length',    help=> 'number of HASH keys',              calculation=> 'keys(%$value)',  parent=> 'hash' ,   type=> 'int' },
 {name=> 'lc',        help=> 'lower case string',                calculation=> 'lc $value',      parent=> 'ne_str',  type=> '',   },
 {name=> 'uc',        help=> 'upper case string',                calculation=> 'uc $value',      parent=> 'ne_str',  type=> '',   },
 {name=> 'mod',       help=> 'modulo $param',                    calculation=> '$value % $param',parent=> 'num',     type=> '',   },
);

our @combinator = (
 {name=> 'OR',        help=> '',           parent=> 'str' ,     },
 {name=> 'IS',        help=> '',           parent=> 'str' ,     },
 {name=> 'PARAM',     help=> '',           parent=> 'str' ,     },
 {name=> 'ARRAY',     help=> 'ARRAY of typed elements', parent=> 'array',   default_value => ['[',']'],
                      eq_properties=>['length'],  component_pos=> ['element'], component_check=> {index => 1, element => 1},
                      check_code=> ['for my $index (0 .. $#value) { my $value = $value[$index];','}'],
                      eq_code=> ['for my $index (0 .. $#value) { my $value = $value[$index];','}'],  },
 {name=> 'HASH',      help=> 'HASH of typed elements',  parent=> 'hash',    default_value => ['{','}'],
                      eq_properties=>['length'],  component_pos=> ['key', 'value'],  component_check=> {key => 1, value => 1},
                      check_code=> ['for my $key (sort keys %$value) { my $value = $value->{$key};'."\n","}\n"],
                      eq_code=> ['for my $key (sort keys %$value_a) { '."\n".
                                 'my $value_a = $value_a->{$key};'."\n".
                                 'my $value_name = "$value_name element $index";'."\n".
                                 '{my $value_name = "$value_name key $key";'."\n".
                                 'return "$value_name does not exist in both HASHES" unless exists $value_b->{$key};'."\n".
                                 '}'."\n".'my $value_b = $value_b->{$key};'."\n"
                                 ,"}\n"],
                      },
);

1;

__END__

op types  like: not, lc, uc ?

  ~name ... of the combination (UC !)
  ~help ?
  ~parent
  ~@$default_value
  @~check_code
 :@component_pos    name, name

  @~eq_properties
  %component_check  name => pos
