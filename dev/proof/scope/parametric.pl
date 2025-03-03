
# locally scoped var in pad

use v5.12;
use warnings;

my $value = [12,13,14];


sub check {
    my ($value) = @_;
    return "   " unless ref $value;
}
{
    my $value = 2;
    say $value;
}
    say $value;

for
