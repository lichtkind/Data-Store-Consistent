
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema;
use v5.12;
use warnings;
use Data::Store::Consistent::Schema::Validate;
use Data::Store::Consistent::Tree;


sub data_tree_from_schema {
    my ($schema) = @_;
    my $error = Data::Store::Consistent::Schema::Validate::tree( $schema );
    return $error if $error;
    # build tree
    my $tree = Data::Store::Consistent::Tree->new();
    $tree;
}

sub inner_node_from_definition {
    my ($def) = @_;
    my $node;
    $node;
}

sub outer_node_from_definition {
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
Data::Store::Consistent::Schema::Validate::split_path()
Data::Store::Consistent::Schema::Validate::join_path()

 = inner:
    1 ~name
    2 %children
    ----
    3 ~description
    4 ~permission: full read write secret constant none| direct: f|r|w|n ;  bulk:f|r|w|n
    5 ~note
    =====
    - &read_trigger
    - &write_trigger
    - %callback : {read => {name => &sub}, write => {name => &sub}}

 = outer:
    1 ~name
    2 ~type | %type_def | { type => ''| type_def => {}|, argument => {name => '/path/to/node'}}
    3 ~description
    ----
    4 ~permission
    5 ~note
    6 $default_value
    7 %writer: {code => '', trigger => ['']|argument, -- argument => {name => '/path/to/node'}, }
    =====
    - &typechecker
    - &equality_checker
    - &read_trigger
    - &write_trigger
    - %callback : {read => {name => &sub}, write => {name => &sub}}

