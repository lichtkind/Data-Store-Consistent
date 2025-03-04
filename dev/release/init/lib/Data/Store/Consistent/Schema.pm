
#

package Data::Store::Consistent::Schema;
use Data::Store::Consistent::Tree;


sub is_valid { #  $schema --> ?
    my ($schema ) = @_;

}

sub build_data_tree_from_schema {
    my ($schema ) = @_;
    my $tree;
    $tree:
}

1;
__END__


 = inner:
    - name: ~
    - help: ~
    - children: {}
    ----
    =====
    - uplink


 = outer:
    - name: ~ !
    - help: ~ !
    - type: ~ !
    ----
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
