
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema;
use v5.12;
use warnings;
use Data::Store::Consistent::Schema::Validate;
use Data::Store::Consistent::Tree;


sub data_tree_from_schema {
    my ($schema ) = @_;
    # build tree
    my $tree = Data::Store::Consistent::Tree->new();
    $tree;
}

sub node_from_definition {
    my ($def) = @_;
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
