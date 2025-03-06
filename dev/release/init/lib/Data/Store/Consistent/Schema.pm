
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema;
use v5.12;
use warnings;
use Data::Store::Consistent::Tree;


sub is_valid {
    my ($schema) = @_;
    return 0 unless ref $schema eq 'HASH';
    for my $key (keys %$schema) {
        my $node = $schema->{$key};
        if (exists $node->{'type'}){
            return 0 unless is_outer_node_definition( $node );
        } else {
            return 0 unless is_inner_node_definition( $node );
            return 0 unless is_valid( $node->{'child'} )
        }
    }
    return 1;
}
sub is_node_definition { is_inner_node_definition($_[0])
                      or is_outer_node_definition($_[0])
}
sub is_inner_node_definition {
    my ($def) = shift;
    return 0 unless ref $def eq 'HASH';
    return 0 unless exists $def->{'name'};
    return 0 unless ref $def->{'child'} eq 'HASH';
    for my $key (keys %$def) {
        my $value = $def->{$key};
        if ($key eq 'name' or
            $key eq 'note' or
            $key eq 'description')  { return 0 unless is_str( $value ) }
        elsif ($key eq 'child')     { return 0 if ref $value ne 'HASH' }
        elsif ($key eq 'permission'){ return 0 unless is_permission( $value ) }
        else                        { return 0 }
    }
    return 1;
}
sub is_outer_node_definition {
    my ($def) = shift;
    return 0 unless defined $def;

}

sub is_str { (defined $_[0] and $_[0] and not ref $_[0]) ? 1 : 0 }
sub is_permission {
    my ($str) = shift;
    return 0 unless defined $str;
    return 1 if $str eq 'full' or $str eq 'write' or $str eq 'read'
             or $str eq 'none' or $str eq 'secret' or $str eq 'constant';
    $str =~ tr/ //d;
    for my $part (split ';', $str){
        my @domain_right = split ':', $part;
        return 0 unless @domain_right == 2;
        return 0 unless $domain_right[0] eq 'direct' or $domain_right[0] eq 'above';
        return 0 unless $domain_right[1] eq 'read'   or $domain_right[1] eq 'write' or
                        $domain_right[1] eq 'full'   or $domain_right[1] eq 'none';
    }
    return 1;
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
    4 ~permission: full read write secret constant none
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
