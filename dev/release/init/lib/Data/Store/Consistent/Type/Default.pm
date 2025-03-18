
# definitions of standard data types

package Data::Store::Consistent::Type::Default;
use v5.12;
use warnings;
use utf8;

our @basic = (
 {name=> 'any',       description=> 'any value',               condition=> '1',                                              default_value=> '', equality=> '$value_a eq $value_b', },
 {name=> 'defined',   description=> 'a defined value',         condition=> 'defined $value',                                 default_value=> '', equality=> '$value_a eq $value_b', },
 {name=> 'not_ref',   description=> 'not a reference',         condition=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'bool',      description=> '0 or 1',                  condition=> '$value eq 0 or $value eq 1', parent=> 'not_ref', default_value=> 0,  equality=> '$value_a == $value_b', },
 {name=> 'num',       description=> 'any type of number',      condition=> 'looks_like_number($value)',  parent=> 'not_ref', default_value=> 0,  equality=> '$value_a == $value_b', },
 {name=> 'int',       description=> 'number without decimals', condition=> 'int($value) == $value',      parent=> 'num',                   },
 {name=> 'str',       description=> 'string of characters',                                              parent=> 'not_ref',               },
 {name=> 'char',      description=> 'one character',           condition=> 'length($value) == 1',        parent=> 'str',     default_value=> 'a' },
 {name=> 'ne_str',    description=> 'none empty string',       condition=> '$value',                     parent=> 'not_ref', default_value=> ' ' },
 {name=> 'word',      description=> 'only word character',     condition=> '$value =~ /^\w+$/',          parent=> 'ne_str',  default_value=> 'A' },
 {name=> 'identifier',description=> 'begins with a letter',    condition=> '$value =~ /^[a-z_]/',        parent=> 'lc_word',               },
);

our @parametric = (
 {name=> 'min',       description=> 'greater or equal then minimum of $parameter', condition=> '$value >= $parameter',      parent => 'num',    parameter_type=> 'num', },
 {name=> 'inf',       description=> 'greater then infimum of $parameter',          condition=> '$value >  $parameter',      parent => 'num',    parameter_type=> 'num', default_value => '1'},
 {name=> 'max',       description=> 'less or equal then maximum of $parameter',    condition=> '$value <= $parameter',      parent => 'num',    parameter_type=> 'num', },
 {name=> 'sup',       description=> 'less then supremum of $parameter',            condition=> '$value <  $parameter',      parent => 'num',    parameter_type=> 'num', },
 {name=> 'ref',       description=> 'a $parameter reference',                      condition=> 'ref $value eq $parameter',  parent=> 'defined', parameter_type=> 'str', },
 {name=> 'enum',      description=> 'part of list @$parameter',                    condition=> 'reduce {$a || ($b eq $value)} 0, @$parameter', parent => 'str',  parameter_type=> ['ARRAY','str'],},
 {name=> 'enum',      description=> 'part of list @$parameter',                    condition=> 'reduce {$a || ($b == $value)} 0, @$parameter', parent => 'num',  parameter_type=> ['ARRAY','num'],},

);

our @argument = (
 {name=> 'pos',       description=> 'positive number',         parametric_type=> 'min',      parameter_value=> '0' },
 {name=> 'spos',      description=> 'strictly positive number',parametric_type=> 'inf',      parameter_value=> '0',     default_value=> '1', },
 {name=> 'array',     description=> 'ARRAY reference',         parametric_type=> 'ref',      parameter_value=> 'ARRAY', default_value=> '[]', },
 {name=> 'hash',      description=> 'HASH reference',          parametric_type=> 'ref',      parameter_value=> 'HASH' , default_value=> '{}', },
 {name=> 'code',      description=> 'CODE reference',          parametric_type=> 'ref',      parameter_value=> 'CODE' , default_value=> 'sub {}',},
);

our @property = (
 {name=> 'length',    description=> 'number of ARRAY elements',  calculation=> '@$value',        parent=> 'array',   type=> 'int' },
 {name=> 'length',    description=> 'number of HASH keys',       calculation=> 'keys(%$value)',  parent=> 'hash' ,   type=> 'int' },
 {name=> 'length',    description=> 'length of a string',        calculation=> 'length($value)', parent=> 'str'  ,   type=> 'int' },
 {name=> 'lc',        description=> 'lower case string',         calculation=> 'lc $value',      parent=> 'ne_str',  type=> '',   },
 {name=> 'uc',        description=> 'upper case string',         calculation=> 'uc $value',      parent=> 'ne_str',  type=> '',   },
 {name=> 'mod',       description=> 'modulo $param',             calculation=> '$value % $param',parent=> 'num',     type=> '',   },
);

our @combinator = (
 {name=> 'OR',        description=> '',           parent=> 'str' ,     },
 {name=> 'IS',        description=> '',           parent=> 'str' ,     },
 {name=> 'PARAM',     description=> '',           parent=> 'str' ,     },
 {name=> 'ARRAY',     description=> 'ARRAY of typed elements', parent=> 'array',   default_value => ['[',']'],
                      eq_properties=>['length'],  component_pos=> ['element'], component_check=> {index => 1, element => 1},
                      check_code=> ['for my $index (0 .. $#value) { my $value = $value[$index];','}'],
                      eq_code=> ['for my $index (0 .. $#value) { my $value = $value[$index];','}'],  },
 {name=> 'HASH',      description=> 'HASH of typed elements',  parent=> 'hash',    default_value => ['{','}'],
                      eq_properties=>['length'],  component_pos=> ['key', 'value'],  component_check=> {key => 1, value => 1},
                      check_code=> ['for my $key (sort keys %$value) {', 'my $value = $value->{$key};',"}"],
                      eq_code=> ['for my $key (sort keys %$value_a) { '.
                                 'my $value_a = $value_a->{$key};'.
                                 'my $value_name = "$value_name element $index";'.
                                 '{my $value_name = "$value_name key $key";'.
                                 'return "$value_name does not exist in both HASHES" unless exists $value_b->{$key};'.
                                 '}','my $value_b = $value_b->{$key};',"}"],
                      },
);

1;

__END__

op types  like: not, lc, uc ?

  ~name ... of the combination (UC !)
  ~description ?
  ~parent
  ~@$default_value
  @~check_code
 :@component_pos    name, name

  @~eq_properties
  %component_check  name => pos
