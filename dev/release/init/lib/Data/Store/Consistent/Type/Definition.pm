
# definitions of standard data types, to be used by D::S::C::Type::Set

package Data::Store::Consistent::Type::Definition;
use v5.12;
use warnings;
use utf8;

our @basic = (
 {name=> 'any',       help=> 'any value',               code=> '1',                                              default=> '', equality=> '$a eq $b', },
 {name=> 'defined',   help=> 'defined value',           code=> 'defined $value',                                 default=> '', equality=> '$a eq $b', },
 {name=> 'no_ref',    help=> 'not a reference',         code=> 'not ref $value',             parent=> 'defined',               },
 {name=> 'bool',      help=> '0 or 1',                  code=> '$value eq 0 or $value eq 1', parent=> 'no_ref',  default=> 0,  },
 {name=> 'num',       help=> 'any type of number',      code=> 'looks_like_number($value)',  parent=> 'no_ref',  default=> 0,  equality=> '$a == $b', },
 {name=> 'int',       help=> 'number without decimals', code=> 'int($value) == $value',      parent=> 'no_ref',  default=> 0,  equality=> '$a == $b', },
 {name=> 'str',       help=> 'string of characters',                                         parent=> 'no_ref',                },
 {name=> 'char',      help=> 'one letter',              code=> 'length($value) == 1',        parent=> 'str',     default=> 'a' },
 {name=> 'ne_str',    help=> 'none empty string',       code=> '$value or ~$value',          parent=> 'no_ref',  default=> ' ' },
 {name=> 'lc_str',    help=> 'lower case string',       code=> 'lc $value eq $value',        parent=> 'ne_str',  default=> 'a' },
 {name=> 'uc_str',    help=> 'upper case string',       code=> 'uc $value eq $value',        parent=> 'ne_str',  default=> 'A' },
 {name=> 'word',      help=> 'only word character',     code=> '$value =~ /^\w+$/',          parent=> 'ne_str',  default=> 'A' },
 {name=> 'lc_word',   help=> 'lower case word',         code=> 'lc $value eq $value',        parent=> 'word',    default=> 'a' },
 {name=> 'identifier',help=> 'string begins with a letter',code=> '$value =~ /^[a-z_]/',     parent=> 'lc_word',               },
);

our @parametric = (
 {name=> 'min',        help=> 'greater or equal $param',  code=> '$param <= $value',           parent => ['num', 'int'] },
 {name=> 'inf',        help=> 'greater then $param',      code=> '$param <  $value',           parent => ['num', 'int'] },
 {name=> 'max',        help=> 'less or equal $param',     code=> '$param >= $value',           parent => ['num', 'int'] },
 {name=> 'sup',        help=> 'less then $param',         code=> '$param >  $value',           parent => ['num', 'int'] },
 {name=> 'enum',       help=> 'one of: @$param',          code=> '$value eq 0 or $value eq 1', parent => ['str']        },
 {name=> 'ref',        help=> 'ref type $param',          code=> 'ref $value eq $param'                                 },
);

our @argument = (
 {name=> 'pos',        help=> 'positive number',          parent=> 'min',      arg => 0 },
 {name=> 'spos',       help=> 'strictly positive number', parent=> 'inf',      arg => 0 },
 {name=> 'ARRAY',      help=> 'ARRAY reference',          parent=> 'ref',      arg => 'ARRAY' },
 {name=> 'HASH',       help=> 'HASH reference',           parent=> 'ref',      arg => 'HASH' },
 {name=> 'CODE',       help=> 'CODE reference',           parent=> 'ref',      arg => 'CODE' },
);

our @derivate = (
 {name=> 'value',      help=> 'value',        code=> '$value',         input => 'defined', output  => 'int' },
 {name=> 'len',        help=> 'length',       code=> 'length($value)', input => 'str'    , output  => 'int' },
 {name=> 'len',        help=> 'length',       code=> '@$value',        input => 'ARRAY'  , output  => 'int' },
 {name=> 'len',        help=> 'length',       code=> 'keys(%$value)',  input => 'HASH'   , output  => 'int' },
);

our @combinator = (
 {name=> 'LIST',        help=> 'list',       code=> '1',                     default=> '', },
 {name=> 'IN_SET',     help=> 'is value in set',       code=> '1',                     default=> '', },
 {name=> 'ARRAY',      help=> '',       code=> '1',                     default=> '', },
 {name=> 'HASH',       help=> '',       code=> '1',                     default=> '', },
 {name=> 'OR',         help=> '',       code=> '1',                     default=> '', },
);



1;
