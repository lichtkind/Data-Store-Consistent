
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema::Validate;
use v5.12;
use warnings;
use Data::Store::Consistent::Tree;


sub is_valid { int ! tree( $_[0] ) }

sub tree {
    my ($schema) = @_;
    return 'schema is no HASH' unless ref $schema eq 'HASH';
    my $error_sum = '';
    for my $key (keys %$schema) {
        my $node = $schema->{$key};
        if (exists $node->{'type'}){
            my $error = outer_node( $node );
            $error_sum .= "outer node $key definition has issue: $error; \n" if $error;
        } else {
            my $error = inner_node( $node );
            $error_sum .= "outer node $key definition has issue: $error; \n" if $error;
            my $error = tree( $node->{'child'} )
            $error_sum .= "child of node $key has issue:\n $error; \n" if $error;
        }
    }
    # validate node paths in arguments
    return $error_sum;
}

sub inner_node {
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

sub outer_node {
    my ($def) = shift;
    return 0 unless ref $def eq 'HASH';
    return 0 unless exists $def->{'name'} and exists $def->{'description'} and exists $def->{'type'};
    for my $key (keys %$def) {
        my $value = $def->{$key};
        if ($key eq 'name' or
            $key eq 'note' or
            $key eq 'description')  { return 0 unless is_str( $value ) }
        elsif ($key eq 'defaul_value'){}
        elsif ($key eq 'permission'){ return 0 unless is_permission( $value ) }
        elsif ($key eq 'writer')    { return 0 unless is_writer( $value ) }
        elsif ($key eq 'type')      {
            if    (is_str($value))  { return 0 unless Data::Store::Consistent::Type::is_valid_description( $value ) }
            elsif (ref $value eq 'HASH') {
                if    (exists $value->{'type'})     { return 0 unless Data::Store::Consistent::Type::is_valid_description( $value->{'type'} ) }
                elsif (exists $value->{'type_def'}) { return 0 unless Data::Store::Consistent::Type::is_valid_definition( $value->{'type_def'} ) }
                else                                { return 0 unless Data::Store::Consistent::Type::is_valid_definition( $value ) }
            }
            else                    { return 0 }
        } else                      { return 0 }
        # collect node paths in arguments
    }
    return 1;
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

sub is_writer { # {code => '', trigger => '' -- argument => {name => '/path/to/node'}}
    my ($def) = shift;
    return 0 unless ref $def eq 'HASH';
    return 0 unless exists $def->{'code'} and exists $def->{'trigger'};
    for my $key (keys %$def) {
        my $value = $def->{$key};
        if ($key eq 'code' or $key eq 'trigger')  { return 0 unless is_str( $value ) }
        elsif ($key eq 'argument'){
            # every value is str
        } else                                    { return 0 }
    }

    return 0 unless exists $def->{'code'} and is_str($def->{'code'});
    return 0 unless exists $def->{'trigger'} and is_str($def->{'trigger'});
    return 0 unless exists $def->{'trigger'} and is_str($def->{'trigger'});
}

#### node path ops #####################################################
sub split_path {
    my ($node_path) = @_;
    return unless defined $node_path and $node_path;
    my $path_wo_attr = (split(':', $node_path))[0];
    return split '/', $path_wo_attr;
}

sub join_path {
    return unless @_;
    return '/'.join('/', @_);
}

1;
__END__
Data::Store::Consistent::Node::Root::join_path()


 = inner:
    1 ~name
    2 %children
    ----
    3 ~description
    4 ~permission: full read write secret constant none| direct: f|r|w|n ;  above:f|r|w|n
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
    7 %writer: {code => '', trigger => '', -- argument => {name => '/path/to/node'}, }
    =====
    - &typechecker
    - &equality_checker
    - &read_trigger
    - &write_trigger
    - %callback : {read => {name => &sub}, write => {name => &sub}}

