
# extendable collection of type objects came from D::S::C::Type

package Data::Store::Consistent::Type::Set;
use v5.12;
use warnings;
use Scalar::Util qw/blessed looks_like_number/;
use Data::Store::Consistent::Type::Definition;


sub new { }                                                            --> .
sub compile_type_def { } ~name, ~help, ~condition, ~parent -- $default --> .type
sub get_type_checker { } ~name                                         --> &checker
sub has_type         { } ~name                                         --> ?


1;
