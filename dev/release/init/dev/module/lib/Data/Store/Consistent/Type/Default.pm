
# definitions of standard data types

package Data::Store::Consistent::Type::Default;
use v5.12;
use warnings;
use utf8;

our @basic = (
 {name=> 'any',       help=> 'any value',               code=> '1',                                              default=> '', equality=> '$a eq $b', },
 {name=> 'defined',   help=> 'a defined value',         code=> 'defined $value',                                 default=> '', equality=> '$a eq $b', },
 {name=> 'not_ref',   help=> 'not a reference',         code=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'bool',      help=> '0 or 1',                  code=> '$value eq 0 or $value eq 1', parent=> 'not_ref', default=> 0,  },
 {name=> 'num',       help=> 'any type of number',      code=> 'looks_like_number($value)',  parent=> 'not_ref', default=> 0,  equality=> '$a == $b', },
 {name=> 'int',       help=> 'number without decimals', code=> 'int($value) == $value',      parent=> 'num',     default=> 0,  },
 {name=> 'str',       help=> 'string of characters',                                         parent=> 'not_ref',               },
 {name=> 'char',      help=> 'one character',           code=> 'length($value) == 1',        parent=> 'str',     default=> 'a' },
 {name=> 'ne_str',    help=> 'none empty string',       code=> '$value',                     parent=> 'not_ref', default=> ' ' },
 {name=> 'lc_str',    help=> 'lower case string',       code=> 'lc $value eq $value',        parent=> 'ne_str',  default=> 'a' },
 {name=> 'uc_str',    help=> 'upper case string',       code=> 'uc $value eq $value',        parent=> 'ne_str',  default=> 'A' },
 {name=> 'word',      help=> 'only word character',     code=> '$value =~ /^\w+$/',          parent=> 'ne_str',  default=> 'A' },
 {name=> 'lc_word',   help=> 'lower case word',         code=> 'lc $value eq $value',        parent=> 'word',    default=> 'a' },
 {name=> 'identifier',help=> 'string begins with a letter',code=> '$value =~ /^[a-z_]/',     parent=> 'lc_word',               },
);

our @parametric = (
 {name=> 'min',       help=> 'greater or equal $param', code=> '$value >= $param',           parent => 'num',   param_name=> 'minimum of $arg', },
 {name=> 'inf',       help=> 'greater then $param',     code=> '$value >  $param',           parent => 'num',   param_name=> 'infimum of $arg', },
 {name=> 'max',       help=> 'less or equal $param',    code=> '$value <= $param',           parent => 'num',   param_name=> 'maximum of $arg'  },
 {name=> 'sup',       help=> 'less then $param',        code=> '$value <  $param',           parent => 'num',   param_name=> 'supremum of $arg' },
 {name=> 'ref',       help=> 'ref type $param',         code=> 'ref $value eq $param'                           param_name=> '$arg reference' },
);

our @argument = (
 {name=> 'pos',       help=> 'positive number',         parent=> 'min',      value=> 0 },
 {name=> 'spos',      help=> 'strictly positive number',parent=> 'inf',      value=> 0 },
 {name=> 'array',     help=> 'ARRAY reference',         parent=> 'ref',      value=> 'ARRAY' },
 {name=> 'hash',      help=> 'HASH reference',          parent=> 'ref',      value=> 'HASH' },
 {name=> 'code',      help=> 'CODE reference',          parent=> 'ref',      value=> 'CODE' },
);

our @property = (
 {name=> 'length',    help=> '',                                 code=> '$value',         parent=> 'num'  ,         type_name=> '' },
 {name=> 'length',    help=> 'an string with length of $param',  code=> 'length($value)', parent=> 'str'  ,         type_name=> 'int' },
 {name=> 'length',    help=> 'number of ARRAY elements',         code=> '@$value',        parent=> ['ref','array'], type_name=> 'int' },
 {name=> 'length',    help=> 'number of HASH keys',              code=> 'keys(%$value)',  parent=> ['ref','hash'] , type_name=> 'int' },
);

our @combinator = (
 {name=> 'OR',        help=> '',           parent=> 'str' ,     },
 {name=> 'IN_SET',    help=> 'value is part of SET',    parent=> 'ne_str', type_name=> 'bool',
                      code=> ['for my $index (0 .. $#param) { my $param = $value[$index];','}'], },
 {name=> 'ARRAY',     help=> 'ARRAY of typed elements', parent=> ['ref','array'],        property=> {index => 1, element => 1},
                      code=> ['for my $index (0 .. $#value) { my $value = $value[$index];','}'],  },
 {name=> 'HASH',      help=> 'HASH of typed elements',  parent=> ['ref','hash'],         property=> {key => 1, value => 1},
                      code=> ['for my $key (keys %value) { my $value = $value{$key};'."\n","}\n"], },
);

1;

# op types  like: not, lc, uc ?
