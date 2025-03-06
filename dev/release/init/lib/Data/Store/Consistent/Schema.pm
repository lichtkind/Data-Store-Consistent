
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema;
use v5.12;
use warnings;
use Data::Store::Consistent::Tree;


sub is_valid {
    my ($schema ) = @_;

}
sub is_node_definition { is_inner_node_definition($_[0]) or is_outer_node_definition($_[0]) }
sub is_inner_node_definition {
    my ($def) = shift;
}
sub is_outer_node_definition {
    my ($def) = shift;

}

sub is_permission {
    my ($str) = shift;
}
sub is_writer {
    my ($str) = shift;
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
    my ($tree) = @_;
    my $schema;
    $schema;
}

sub definition_from_inner_node {
    my ($node) = @_;
    my $definition;
    $definition;
}
sub definition_from_outer_node {
    my ($node) = @_;
    my $definition;
    $definition;
}

1;
__END__
Data::Store::Consistent::Node::Root::join_path()


 = inner:
    1 ~name
    2 %children
    ----
    3 ~description
    4 ~permission: full read write secret constant hidden
                   direct:   ;  above:
    5 ~note
    =====
    - &read_trigger
    - &write_trigger

 = outer:
    1 ~name
    2 ~description
    3 ~permission
    4 ~type | %type_def: num{0,1} | {name => '', help => , code => '', argument => '/path/to/node'}
    ----
    5 ~note
    6 $default_value
    7 %writer: {code => '', trigger => '' -- arguments => ['/path/to/node'], }
    =====
    - &typechecker
    - &equality_checker
    - &read_trigger
    - &write_trigger
