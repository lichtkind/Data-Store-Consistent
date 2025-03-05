
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema;
use v5.12;
use warnings;
use Data::Store::Consistent::Tree;


sub is_valid {
    my ($schema ) = @_;

}

sub is_node_definition {
    my ($definition) = @_;

}

sub data_tree_from_schema {
    my ($schema ) = @_;
    my $tree;
    $tree:
}

sub node_from_definition {
    my ($definition) = @_;
    my $tree;
    $tree:
}

sub schema_from_data_tree {
    my ($tree ) = @_;
    my $tree;
    $tree:
}

sub definition_from_node {
    my ($node) = @_;
    my $tree;
    $tree:
}

1;
__END__


 = inner:
    - name: ~
    - help: ~
    - children: {} []
    ----
    - note: ~
    =====
    - uplink


 = outer:
    - name: ~
    - help: ~
    - type: ~
    ----
    - note: ~
    - $default_value ? must if no writer
    - &writer:
    - writer_param: @node_path ? when &writer :: node_name/node_name:w
    =====
    - uplink
    - typechecker
    - equality_checker

    #~ - help: ~
    #~ - type: ~typename | ~typedef
    #~ - ?default_value: $               # optional when type name given | to init
    #~ - ?writer: &
    #~ - $read_trigger: @node_path       # trigger these nodes when read
    #~ - $write_trigger: @node_path      # trigger these nodes when written

action_def: {sources : [], target : ~}
