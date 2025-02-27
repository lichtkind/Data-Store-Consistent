
# definitions of standard data types, to be used by D::S::C::Type::Set

package Data::Store::Consistent::Type::Definition;
use v5.12;
use warnings;
use utf8;

our @basic = (
 {name=> 'any',       help=> 'any value',               code=> '1',                                              default=> '', },
 {name=> 'value',     help=> 'defined value',           code=> 'defined $value',                                 default=> '', equality=> '$a eq $b', },
 {name=> 'no_ref',    help=> 'not a reference',         code=> 'not ref $value',             parent=> 'value',                 },
 {name=> 'bool',      help=> '0 or 1',                  code=> '$value eq 0 or $value eq 1', parent=> 'no_ref',  default=> 0,  },
 {name=> 'num',       help=> 'any type of number',      code=> 'looks_like_number($value)',  parent=> 'no_ref',  default=> 0,  equality=> '$a == $b', },
 {name=> 'pos_num',   help=> 'a number >= 0',           code=> '$value >= 0',                parent=> 'num'                    },
 {name=> 'spos_num',  help=> 'a number > 0',            code=> '$value > 0',                 parent=> 'num',     default=> 1,  },
 {name=> 'int',       help=> 'number without decimals', code=> 'int($value) == $value',      parent=> 'no_ref',  default=> 0,  equality=> '$a == $b', },
 {name=> 'pos_int',   help=> 'integer greater equal 0', code=> '$value >= 0',                parent=> 'int',                   },
 {name=> 'spos_int',  help=> 'integer > 0',             code=> '$value > 0',                 parent=> 'int',     default=> 1,  },
 {name=> 'str',       help=> 'string of characters',                                         parent=> 'no_ref',                },
 {name=> 'char',      help=> 'one letter',              code=> 'length($value) == 1',        parent=> 'str',     default=> 'a' },
 {name=> 'ne_str',    help=> 'none empty string',       code=> '$value or ~$value',          parent=> 'no_ref',  default=> ' ' },
 {name=> 'lc_str',    help=> 'lower case string',       code=> 'lc $value eq $value',        parent=> 'ne_str',  default=> 'a' },
 {name=> 'uc_str',    help=> 'upper case string',       code=> 'uc $value eq $value',        parent=> 'ne_str',  default=> 'A' },
 {name=> 'word',      help=> 'only word character',     code=> '$value =~ /^\w+$/',          parent=> 'ne_str',  default=> 'A' },
 {name=> 'lc_word',   help=> 'lower case name',         code=> 'lc $value eq $value',        parent=> 'word',    default=> 'a' },
 {name=> 'identifier',help=> 'string begins with a letter',code=> '$value =~ /^[a-z_]/',     parent=> 'lc_word',               },
);

our @parametric = (
 {name=> 'min',        help=> 'greater or equal $param',  code=> '$param <= $value',           parent => ['num', 'int'] },
 {name=> 'inf',        help=> 'greater then $param',      code=> '$param <  $value',           parent => ['num', 'int'] },
 {name=> 'max',        help=> 'less or equal $param',     code=> '$param >= $value',           parent => ['num', 'int'] },
 {name=> 'sup',        help=> 'less then $param',         code=> '$param >  $value',           parent => ['num', 'int'] },
 {name=> 'min',        help=> '$param character or more', code=> '$param <= length($value)',   parent => ['str'] },
 {name=> 'max',        help=> '$param character or less', code=> '$param >= length($value)',   parent => ['str'] },
 {name=> 'min',        help=> '$param character or more', code=> '$param <= @$value',          parent => ['ARRAY'] },
 {name=> 'max',        help=> '$param character or less', code=> '$param >= @$value',          parent => ['ARRAY'] },
 {name=> 'min',        help=> '$param character or more', code=> '$param <= keys(%$value)',    parent => ['HASH'] },
 {name=> 'max',        help=> '$param character or less', code=> '$param >= keys(%$value)',    parent => ['HASH'] },
 {name=> 'enum',       help=> 'one of: @$param',          code=> '$value eq 0 or $value eq 1', parent => ['str'] },
);

our @array = (
 {name=> 'any',        help=> 'accepts any value',       code=> '1',                                                 default=> '', },
);

our @hash = (
 {name=> 'any',        help=> 'accepts any value',       code=> '1',                                                 default=> '', },
);

1;
