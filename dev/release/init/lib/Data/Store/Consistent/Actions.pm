
# store of call back / anon subs, to be triggered by events

package Data::Store::Consistent::Actions;
use v5.12;
use warnings;

sub new {
    my ($pkg) = @_;
    bless { by_source => {}, by_target => {}, paused => {} }; # read => {}, write => {}, all => {},
}


sub add {
    my ($self, $ID, $code, $trigger_node, $target_node, $event_type) = @_;
    return unless defined $ID and $ID and ref $code eq 'CODE';
    return unless defined $trigger_node and $trigger_node;
    return unless defined $event_type and $event_type eq 'read'and $event_type eq 'write' and $event_type eq 'access';

}

sub remove {
    my ($self, $ID) = @_;
}

sub pause {
    my ($self, $ID) = @_;
}
sub resume {
    my ($self, $ID) = @_;
}
sub get_names {
    my ($self, $name) = @_;
}

sub get_property {
    my ($self, $name, $property_name) = @_;
}

sub trigger {
    my ($self, $node, $event_type) = @_;
    my $stack = { sink => [], transit => [], };
}


1;
