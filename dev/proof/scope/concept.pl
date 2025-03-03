
# locally scoped var in pad

use v5.12;
use warnings;

my $value = 1;

{
    my $value = 2;
    say $value;
}
    say $value;
