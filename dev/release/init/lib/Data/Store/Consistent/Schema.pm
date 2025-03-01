
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


    my ($pkg, $name, $help, $write_trigger, $read_trigger) = @_;

 = inner:
    - help: ~
    - children: {}

    #~ - help: ~
    #~ - type: ~typename | ~typedef
    #~ - ?default_value: $               # optional when type name given | to init
    #~ - ?writer: &
    #~ - $write_trigger: @node_path      # trigger writer when on of these nodes changes
