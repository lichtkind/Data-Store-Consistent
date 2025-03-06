
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
 {name=> 'int',       help=> 'number without decimals', code=> 'int($value) == $value',      parent=> 'num',     default=> 0,  equality=> '$a == $b', },
 {name=> 'str',       help=> 'string of characters',                                         parent=> 'not_ref',               },
 {name=> 'char',      help=> 'one letter',              code=> 'length($value) == 1',        parent=> 'str',     default=> 'a' },
 {name=> 'ne_str',    help=> 'none empty string',       code=> '$value',                     parent=> 'not_ref', default=> ' ' },
 {name=> 'lc_str',    help=> 'lower case string',       code=> 'lc $value eq $value',        parent=> 'ne_str',  default=> 'a' },
 {name=> 'uc_str',    help=> 'upper case string',       code=> 'uc $value eq $value',        parent=> 'ne_str',  default=> 'A' },
 {name=> 'word',      help=> 'only word character',     code=> '$value =~ /^\w+$/',          parent=> 'ne_str',  default=> 'A' },
 {name=> 'lc_word',   help=> 'lower case word',         code=> 'lc $value eq $value',        parent=> 'word',    default=> 'a' },
 {name=> 'identifier',help=> 'string begins with a letter',code=> '$value =~ /^[a-z_]/',     parent=> 'lc_word',               },
);

our @parametric = (
 {name=> 'min',       help=> 'greater or equal $param', code=> '$value >= $param',           parent => 'num'  }, # or children of num
 {name=> 'inf',       help=> 'greater then $param',     code=> '$value >  $param',           parent => 'num'  },
 {name=> 'max',       help=> 'less or equal $param',    code=> '$value <= $param',           parent => 'num'  },
 {name=> 'sup',       help=> 'less then $param',        code=> '$value <  $param',           parent => 'num'  },
 {name=> 'enum',      help=> 'one of: @$param',         code=> '$value eq 0 or $value eq 1', parent => 'str'  },
 {name=> 'ref',       help=> 'ref type $param',         code=> 'ref $value eq $param'                                 },
);

our @argument = (
 {name=> 'pos',       help=> 'positive number',         parent=> 'min',      arg=> 0 },
 {name=> 'spos',      help=> 'strictly positive number',parent=> 'inf',      arg=> 0 },
 {name=> 'array',     help=> 'ARRAY reference',         parent=> 'ref',      arg=> 'ARRAY' },
 {name=> 'hash',      help=> 'HASH reference',          parent=> 'ref',      arg=> 'HASH' },
 {name=> 'code',      help=> 'CODE reference',          parent=> 'ref',      arg=> 'CODE' },
 {name=> 'char',      help=> 'an string of length 1',    code=> 'keys(%$value)',  input=> 'hash' ,     output=> 'int' },
);

our @property = (
 {name=> 'len',       help=> '',                                 code=> '$value',         input=> 'num'  ,     output=> '' },
 {name=> 'len',       help=> 'an string with length of $param',  code=> 'length($value)', input=> 'str'  ,     output=> 'int' },
 {name=> 'len',       help=> 'an Array of length $param',        code=> '@$value',        input=> 'array',     output=> 'int' },
 {name=> 'len',       help=> 'an Hash of length $param',         code=> 'keys(%$value)',  input=> 'hash' ,     output=> 'int' },
);

our @combinator = (
 {name=> 'LIST',      help=> 'list',       parent=> ['str', 'num', 'int'],
                      code=> ['for my $index (0 .. $#param) { my $param = $param[$index];',,'}'], },
 {name=> 'IN_SET',    help=> '',           parent=> 'str' , },
 {name=> 'ARRAY',     help=> '',           parent=> 'array',               property=> ['index', 'element'],
                      code=> ['for my $index (0 .. $#value) { my $value = $value[$index];',,'}'],
 },
 {name=> 'HASH',      help=> '',           parent=> 'hash',                property=> ['key', 'value'],
                      code=> ['for my $key (keys %value) { my $value = $value{$key};',,'}'], },
 {name=> 'OR',        help=> 'alternative',  parent=> '',
                      code=> '1', },
);



1;

# durchgangstypen op liek not ?
