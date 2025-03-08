
# translate a definition of a data tree into an object tree and back

package Data::Store::Consistent::Schema::Validate;
use v5.12;
use warnings;
use Data::Store::Consistent::Type;


sub is_valid { int ! tree( $_[0] ) }

sub tree {
    my ($schema) = @_;
    return 'schema is no HASH' unless ref $schema eq 'HASH';
    my ($error_sum, $node_paths) = _tree( $schema );
    my $path (@$node_paths){
        my $node_pointer = $schema;
        my $name (split_path( $path )){
            $node_pointer = $node_pointer->{'child'} if exists $node_pointer->{'child'};
            unless (exists $node_pointer->{ $name }){
                $error_sum .= "node path $path does not exist; \n";
                last;
            }
            $node_pointer = $node_pointer->{ $name };
        }
    }
    return $error_sum;
}
sub _tree {
    my ($schema) = @_;
    return 'schema is no HASH' unless ref $schema eq 'HASH';
    my $error_sum = '';
    my $node_paths = [];
    my ($error, $paths);

    for my $key (keys %$schema) {
        my $node = $schema->{$key};
        if (exists $node->{'type'}){
            ($error, $paths) = outer_node( $node );
            $error_sum .= "outer node $key definition has issue: $error; \n" if $error;
            push @$node_paths, @$paths if ref $paths eq 'ARRAY' and @$paths;
        } else {
            $error = inner_node( $node );
            $error_sum .= "outer node $key definition has issue: $error; \n" if $error;
            ($error, $paths) = _tree( $node->{'child'} );
            $error_sum .= "child of node $key has issue:\n $error; \n" if $error;
            push @$node_paths, @$paths if ref $paths eq 'ARRAY' and @$paths;
        }
    }
    return $error_sum, $node_paths;
}

#### validate nodes ####################################################
sub inner_node {
    my ($def ) = @_;
    return 'is not a HASH' unless ref $def eq 'HASH';
    my $error_sum = '';
    $error_sum .= 'lacks name property; ' unless exists $def->{'name'};
    $error_sum .= 'lacks children HASH; ' unless ref $def->{'child'} eq 'HASH';
    for my $key (keys %$def) {
        my $value = $def->{$key};
        if    ($key eq 'name')       { $error_sum .= 'name property contains no string; ' unless is_str( $value ) }
        elsif ($key eq 'note')       { $error_sum .= 'note contains no string; '          unless is_str( $value ) }
        elsif ($key eq 'description'){ $error_sum .= 'description contains no string;'    unless is_str( $value ) }
        elsif ($key eq 'child')      { $error_sum .= 'children are not stored in a HASH;' if ref $value ne 'HASH' }
        elsif ($key eq 'permission') { my $error = permission( $value );
                                       $error_sum .= 'malformed premission def: '.$error  if $error }
        else                         { $error_sum .= "contained unknow property $key;" }
    }
    return $error_sum;
}

sub outer_node {
    my ($def) = shift;
    return 'is not a HASH' unless ref $def eq 'HASH';
    my $error_sum = '';
    my $node_paths = [];
    $error_sum .= 'lacks name property; ' unless exists $def->{'name'};
    $error_sum .= 'lacks type property; ' unless exists $def->{'type'};
    $error_sum .= 'lacks description property; ' unless exists $def->{'description'};
    my ($error, $paths);
    for my $key (keys %$def) {
        my $value = $def->{$key};
        if    ($key eq 'name')       { $error_sum .= 'name property is not a string; '          unless is_str( $value ) }
        elsif ($key eq 'description'){ $error_sum .= 'description property contains no string;' unless is_str( $value ) }
        elsif ($key eq 'note')       { $error_sum .= 'note property contains no string; '       unless is_str( $value ) }
        elsif ($key eq 'defaul_value'){}
        elsif ($key eq 'permission') { $error = permission( $value );
                                       $error_sum .= 'malformed premission def: '.$error if $error }
        elsif ($key eq 'writer')     { ($error, $paths) = writer( $value );
                                       $error_sum .= 'malformed writer def: '.$error    if $error;
                                       push @$node_paths, @$paths if ref $paths eq 'ARRAY' and @$paths;
        } elsif ($key eq 'type'      { ($error, $paths) = type( $value );
                                       $error_sum .= 'malformed type def: '.$error    if $error;
                                       push @$node_paths, @$paths if ref $paths eq 'ARRAY' and @$paths;
        } else                       { $error_sum .= "contained unknow property $key;" }
    }
    return $error_sum, $node_paths;
}

#### validate properties ###############################################
sub is_str { (defined $_[0] and $_[0] and not ref $_[0]) ? 1 : 0 }
sub permission {
    my ($str) = shift;
    return 'not defined' unless defined $str;
    $str =~ tr/ //d;
    if (index( $str, ':' ) > -1){
    } else {
        return 'none of the acceptable values: full, write, read, secret, constant, none'
            if $str ne 'full' and $str ne 'write' and $str ne 'read'
           and $str ne 'none' and $str ne 'secret' and $str ne 'constant';
    }
    for my $part (split ';', $str){
        my @domain_right = split ':', $part;
        return 'double colon ":" can be used only once in one scope declaration as in - "direct:write"'
            unless @domain_right == 2;
        return 'only scopes are "direct" and "bulk"' unless $domain_right[0] eq 'direct' or $domain_right[0] eq 'bulk';
        return 0 unless $domain_right[1] eq 'read'   or $domain_right[1] eq 'write' or
                        $domain_right[1] eq 'full'   or $domain_right[1] eq 'none';
    }
    return 0;
}

sub writer { # {code => '', ref => '', trigger => '' -- argument => {name => '/path/to/node'}}
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

sub callback { # {read => {name => &sub}, write => {name => &sub}}
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

    return 0 unless exists $def->{'code'}    and is_str($def->{'code'});
    return 0 unless exists $def->{'trigger'} and is_str($def->{'trigger'});
    return 0 unless exists $def->{'trigger'} and is_str($def->{'trigger'});
}

sub type { # {read => {name => &sub}, write => {name => &sub}}
    my ($def) = shift;
    if (is_str($def))  { return 0 unless Data::Store::Consistent::Type::is_valid_description( $def ) }
    elsif (ref $def eq 'HASH') {
        if    (exists $def->{'type'})     { return 0 unless Data::Store::Consistent::Type::is_valid_description( $def->{'type'} ) }
        elsif (exists $def->{'type_def'}) { return 0 unless Data::Store::Consistent::Type::is_valid_definition(  $def->{'type_def'} ) }
        else                              { return 0 unless Data::Store::Consistent::Type::is_valid_definition(  $def ) }
    }
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

