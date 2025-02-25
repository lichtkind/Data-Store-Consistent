use v5.20;
use warnings;
use utf8;

# definition and set (namespace) of standard data type checker objects

package Data::Store::Consistent::Type::Definition;
our $VERSION = 1.0;

our @list = (
 {name=> 'any',        help=> 'anything',                code=> '1',                                                 default=> '', },
 {name=> 'value',      help=> 'defined value',           code=> 'defined $value',                                    default=> '', },
 {name=> 'no_ref',     help=> 'not a reference',         code=> 'not ref $value',              parent=> 'value',                   },
 {name=> 'bool',       help=> '0 or 1',                  code=> '$value eq 0 or $value eq 1',  parent=> 'no_ref',    default=> 0,  },
 {name=> 'num',        help=> 'any type of number',      code=> 'looks_like_number($value)',   parent=> 'no_ref',    default=> 0,  },
 {name=> 'pos_num',    help=> 'a number >= 0',           code=> '$value >= 0',                 parent=> 'num'                      },
 {name=> 'spos_num',   help=> 'a number > 0',            code=> '$value > 0',                  parent=> 'num',       default=> 1,  },
 {name=> 'int',        help=> 'number without decimals', code=> 'int($value) == $value',       parent=> 'no_ref',    default=> 0,  },
 {name=> 'pos_int',    help=> 'integer greater equal 0', code=> '$value >= 0',                 parent=> 'int',                     },
 {name=> 'spos_int',   help=> 'integer > 0',             code=> '$value > 0',                  parent=> 'int',       default=> 1,  },
 {name=> 'str',        help=> 'character string',                                              parent=> 'no_ref',                  },
 {name=> 'char',       help=> 'one letter',              code=> 'lrngth($value) == 1',         parent=> 'str',       default=> 'a' },
 {name=> 'not_empty',  help=> 'none empty string',       code=> '$value or ~$value',           parent=> 'no_ref',    default=> ' ' },
 {name=> 'lc_str',     help=> 'lower case string',       code=> 'lc $value eq $value',         parent=> 'not_empty', default=> 'a' },
 {name=> 'uc_str',     help=> 'upper case string',       code=> 'uc $value eq $value',         parent=> 'not_empty', default=> 'A' },
 {name=> 'word',       help=> 'only word character',     code=> '$value =~ /^\w+$/',           parent=> 'not_empty', default=> 'A' },
 {name=> 'lc_word',    help=> 'lower case name',         code=> 'lc $value eq $value',         parent=> 'word',      default=> 'a' },
 {name=> 'identifier', help=> 'string that beginns with a letter',code=> '$value =~ /^[a-z_]/',parent=> 'lc_word',                 },
);

1;
