
# bundle all type related functionality

package Data::Store::Consistent::Type;
use v5.12;
use warnings;
use Data::Store::Consistent::Type::Default;
use Data::Store::Consistent::Type::Factory;
use Data::Store::Consistent::Type::Store;

########################################################################
my $basic = Data::Store::Consistent::Type::Basic->new();
my $param = Data::Store::Consistent::Type::Parametric->new();


sub add {
    my ($name, $def) = @_;
}

sub compile {
    my ($name, $def) = @_;
}

sub get {
    my ($names) = @_;
}


1;

__END__

types have to

 - check for compliance
 - check for equality
 - store arguments
 - accept temp args

ARRAY{}<>
