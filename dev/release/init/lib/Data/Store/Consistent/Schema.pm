
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
    # build tree
    my $tree = Data::Store::Consistent::Tree->new();
    $tree;
}

sub node_from_definition {
    my ($definition) = @_;
    my $node;
    $node;
}

sub schema_from_data_tree {
    my ($tree ) = @_;
    my $schema;
    $schema;
}

sub definition_from_node {
    my ($node) = @_;
    my $definition;
    $definition;
}

1;
__END__
Data::Store::Consistent::Node::Root::join_path()

          R      W
          ---------
          W      W    hidden (code only for writer)
          L      -    constant
          -      L    secret
          G      L    write
          L      G    read
          L      L    full

{ name => 'der', children => {} }
{ name => 'der', children => {} }

 = inner:
    1 ~name
    2 %children
    ----
    3 ~description // ''
    4 ~permission // full
    5 ~note // ''
    =====
    - @read_trigger
    - @write_trigger


 = outer:
    1 ~name
    2 ~description
    3 ~permission
    4 ~type_def|%type_def:
    ----
    5 ? ~note
    6 ? $default_value // $type.default_value
    7 !6 &writer:
    8 ?7 @writer_trigger: ~node_path ? when &writer :: node_name/node_name # on read event
    9 ?7 @writer_param: ~node_path ? when &writer :: node_name/node_name # on write event
   10 ? @type_param: ~node_path :: node_name/node_name                 # on write event
    =====
    - typechecker
    - equality_checker
    - @read_trigger
    - @write_trigger
