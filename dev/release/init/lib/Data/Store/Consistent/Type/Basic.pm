
# store of data type objects, definitions are in D::S::C::Type::Definition

package Data::Store::Consistent::Type::Set;
use v5.12;
use warnings;
use Scalar::Util qw/blessed looks_like_number/;

########################################################################

sub new {        # ~name ~help - ~code .parent $default  --> .type | ~errormsg
    my $pkg = shift;
    my ($name, $help, $code, $parent, $default) = _unhash_arg_(@_);
    $code //= '';
    my $name_error = _check_name($name);
    return $name_error if $name_error;
    return "'parent' of basic type '$name' has to be an instance of ".__PACKAGE__ if defined $parent and ref $parent ne __PACKAGE__;
    return "definition of basic type '$name' misses description under the key 'help'" unless defined $help;
    return "definition of basic type '$name' misses code either from key 'code' or 'parent'"
        unless $code or (ref $parent and (exists $parent->{'code'} or exists $parent->{'checks'}));
    my $checks = [];
    my $parents = [];
    if (defined $parent){
        @$checks = @{$parent->source};
        $default //= $parent->default_value;
        push @$parents, $parent->ID, $parent->parents;
    }
    if ($code) {  push @$checks, $help, $code }
    else       { $checks->[-2] = $help  }
    return "basic type '$name' misses 'default' value or a 'parent' type to inherit a default from" unless defined $default;
    my $source = _compile_( $name, $checks );
    my $coderef = eval $source;
    return "basic type '$name' checker source 'code' - '$source' - could not eval because: $@ !" if $@;
    my $error = $coderef->( $default );
    return "type '$name' default value '$default' does not pass check - '$source' - because: $error!" if $error;
    bless {name=> $name, coderef=> $coderef, checks=> $checks, default=> $default, parents=> $parents };
}


#### getter ####################################################################
sub kind            { 'basic' }                    # _                  -->  'basic'|'param'
sub ID              { $_[0]->{'name'} }            # _                  -->  ~name
sub ID_equals       {(defined $_[1] and not ref $_[1] and $_[0]->ID eq $_[1] ) ? 1 : 0 } # _ $typeID  -->  ?
sub name            { $_[0]->{'name'} }            # _                  -->  ~name
sub full_name       { $_[0]->{'name'} }            # _                  -->  ~name
sub help            { $_[0]->{'checks'}[-2] }      # _                  -->  ~help
sub code            { $_[0]->{'checks'}[-1] }      # _                  -->  ~code
sub parents         { @{$_[0]->{'parents'}} }      # _                  -->  @.parent~name
sub parameter       { '' }                         # _                  -->  ''  # make API compatible
sub has_parent      {
    defined $_[1] ? ($_[1] ~~ $_[0]->{'parents'})
                  : int @{$_[0]->{'parents'}} > 0 }# _  ~parent         -->  ?
sub source          { $_[0]->{'checks'} }          # _                  -->  @checks
sub default_value   { $_[0]->{'default'} }         # _                  -->  $default
#### public API ################################################################
sub checker         { $_[0]->{'coderef'} }         # _                  -->  &checker
sub check_data      { $_[0]->{'coderef'}->($_[1]) }# _  $val            -->  '' | ~errormsg
#### internal util #############################################################
sub assemble_source { _asm_($_[0]->name, $_[0]->source) }
sub _check_name  {
    return "type name is not defined" unless defined $_[0];
    return "type name $_[0] has to contain only lower case char, digits and underscore (_)" if  $_[0] =~ /[^a-z0-9_]/;
    return "type name $_[0] has to start with a letter" unless $_[0] =~ /^[a-z]/;
    return "type name $_[0] can not be longer than 16 chracter" if  length $_[0] > 16;
    return "type name $_[0] has to have at least 3 character" if  length $_[0] < 3;
    '';
}
sub _compile_ { 'sub { my( $value ) = @_; no warnings "all";'. _asm_(@_) . "return ''}" }
sub _asm_ {
    my ($name, $checks) = @_;
    my $source = '';
    for (my $i = 0; $i < @$checks; $i+=2) {
        $source .= 'return "value $value'." needed to be of type $name, but failed test: $checks->[$i]\" unless $checks->[$i+1];"
    }
    $source;
}
################################################################################
# example      : {name => bool, help=> '0 or 1', code=> '$_[0] eq 0 or $_[0] eq 1', parent=> 'value',  default =>0}
# compiled to  : {check => ['not a reference', 'not ref $_[0]', '0 or 1', '$_[0] eq 0 or $_[0] eq 1'], parents => ['value']
#                 coderef => eval{ sub{ return $_[0] 'failed not a reference' unless not ref $_[0]; ...; 0} } }

2;
__END__

use Kephra::Base::Data::Type::Basic;
use Kephra::Base::Data::Type::Parametric;

use Exporter 'import';
our @EXPORT_OK = qw/is_type /;
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

my $btclass = 'Kephra::Base::Data::Type::Basic';
my $ptclass = 'Kephra::Base::Data::Type::Parametric';
my %type_class = (basic => $btclass, param => $ptclass);
my %class_type = ($btclass => 'basic', $ptclass => 'param');
my @type_kinds = keys %type_class;
my @type_class_names = values %type_class;

##### main function & helper ###################################################

sub create_type      {  # $Tdef      --> @[full_name => .T, ..] .T =^ (basic | param)
    my $Tdef = shift;
    return "type definitions have to be a HASH ref with keys like 'name', 'help' and 'code'"
        unless ref $Tdef eq 'HASH';
    _has_parameter($Tdef) ? Kephra::Base::Data::Type::Parametric->new($Tdef)
                          : Kephra::Base::Data::Type::Basic->new($Tdef);
}

sub create_type_chain {  # $Tdef      --> @[full_name => .T, ..] .T =^ (basic | param)
    my $Tdef = shift;
    return "type definitions have to be a HASH ref" unless ref $Tdef eq 'HASH';
    my @open = get_ID_resolver( $Tdef );
    return @open if @open;
    my @ret = _create_type_chain( $Tdef );
    wantarray ? @ret : $ret[-1];
}
sub _create_type_chain       {
    my $Tdef = shift;
    my @ret;
    if (ref $Tdef->{'parent'} eq 'HASH'){
        my @Tobj = _create_type_chain( $Tdef->{'parent'} );
        return @Tobj if @Tobj == 1;
        push @ret, @Tobj;
        $Tdef->{'parent'} = $Tobj[-1];
    }
    if (ref $Tdef->{'parameter'} eq 'HASH'){
        my @Tobj = _create_type_chain( $Tdef->{'parameter'} );
        return @Tobj if @Tobj == 1;
        push @ret, @Tobj;
        $Tdef->{'parameter'} = $Tobj[-1];
    }
    my $Tobj = create_type($Tdef);
    return $Tobj unless ref $Tobj;
    push @ret, $Tobj->full_name, $Tobj;
    @ret;
}
sub get_ID_resolver          { # %Tdef      --> - .R - .R
    my $Tdef = shift;
    return unless ref $Tdef eq 'HASH';
    my @open;
    my @parent_ID = root_parent_ID( $Tdef );
    push @open, Kephra::Base::Data::Type::Resolver->new( @parent_ID, 'parent') if @parent_ID;
    my @param_ID = root_parameter_ID( $Tdef );
    push @open, Kephra::Base::Data::Type::Resolver->new( @param_ID, 'parameter') if @param_ID;
    @open;
}
sub root_parent_ID           { # %Tdef      --> - typeID, %Tdef
    my ($type_def) = @_;
    return if ref $type_def ne 'HASH';
    $type_def = $type_def->{'parent'} while ref $type_def->{'parent'} eq 'HASH';
    return $type_def->{'parent'}, $type_def if is_type_ID( $type_def->{'parent'} );
}
sub root_parameter_ID        { # %Tdef      --> - typeID, %Tdef
    my ($type_def) = @_;
    return if ref $type_def ne 'HASH';
    $type_def = $type_def->{'parent'} while ref $type_def->{'parent'} eq 'HASH'
                                        and not exists $type_def->{'parameter'};
    return unless exists $type_def->{'parameter'};
    return $type_def->{'parameter'}, $type_def if is_type_ID( $type_def->{'parameter'} );

    $type_def = $type_def->{'parameter'} if ref $type_def->{'parameter'} eq 'HASH';
    $type_def = $type_def->{'parent'} while ref $type_def->{'parent'} eq 'HASH';
    return $type_def->{'parent'}, $type_def if is_type_ID( $type_def->{'parent'} );
}

##### ID names conversion ######################################################

sub base_name_from_ID        { # $typeID     --> ~name
    return '' unless defined $_[0];
    return $_[0] unless ref $_[0];
    (ref $_[0] eq 'ARRAY' and @{$_[0]} == 2) ? $_[0][0] : '';

}
sub param_name_from_ID       { # $typeID     --> ~name
    (ref $_[0] eq 'ARRAY' and @{$_[0]} == 2) ? $_[0][1] : '';
}
sub full_name_from_ID        { # $typeID     --> ~full_name
    return '' unless defined $_[0];
    return $_[0] unless ref $_[0];
    (ref $_[0] eq 'ARRAY' and @{$_[0]} == 2) ? $_[0][1].' of '.$_[0][1] : '';
}
sub ID_from_full_name        { # ~full_name  --> $typeID
    return '' unless defined $_[0] and not ref $_[0] and $_[0];
    my @parts = split / of /, shift;
    (@parts == 1) ? $_[0] : (@parts == 2) ? \@parts : '';
}
sub full_name_kind          { # ~full_name  --> ( 'basic' | 'param' | '' )
    return '' unless defined $_[0] and not ref $_[0] and $_[0];
    my @parts = split / of /, shift;
    (@parts == 1) ? 'basic' : (@parts == 2) ? 'param' : '';
}


sub is_type_ID               { # $typeID     --> ?
    return 0 unless defined $_[0];
    return 1 if ref $_[0] eq 'ARRAY' and @{$_[0]} == 2;
    (not ref $_[0] and $_[0]) ? 1 : 0;
}
sub type_ID_kind             { # $typeID     --> ( 'basic' | 'param' | '' )
    return '' unless defined $_[0];
    return 'param' if ref $_[0] eq 'ARRAY' and @{$_[0]} == 2;
    (not ref $_[0] and $_[0]) ? 'basic' : '';

}

##### type def checker #########################################################

sub is_type_def              { # %Tdef       --> ?
    my $def = shift;
    return 0 unless ref $def eq 'HASH';
    return 0 unless exists $def->{'name'} and exists $def->{'help'};
}
sub is_basic_type_def        { # %Tdef       --> ?
    my $def = shift;
    return 0 unless ref $def eq 'HASH';
    return 0 unless exists $def->{'name'} and exists $def->{'help'};
    return 0 unless (exists $def->{'code'} and exists $def->{'default'})
                  or exists $def->{'parent'};
    1;
}
sub _has_parameter {
    exists $_[0]->{'parameter'}
    or (ref $_[0]->{'parent'} eq 'HASH' and exists $_[0]->{'parent'}{'parameter'})
    or (ref $_[0]->{'parent'} eq $ptclass);
}
sub is_param_type_def        { # %Tdef       --> ?
    my $def = shift;
    return 0 unless is_basic_type_def($def);
    _has_parameter( $def ) ? 1 : 0;
}
sub type_def_kind            { # %Tdef       --> ( 'basic' | 'param' | '' )
    my $def = shift;
    return '' unless is_basic_type_def($def);
    _has_parameter( $def ) ? 'param' : 'basic';
}

##### type object checker #######################################################

sub is_type                  { exists $class_type{ ref $_[0] } }
sub is_basic_type            { ref $_[0] eq $type_class{'basic'} }
sub is_param_type            { ref $_[0] eq $type_class{'param'} }
sub type_kind                { $class_type{ ref $_[0] } }


package Kephra::Base::Data::Type::Resolver;

sub new                      { # $typeID, $Tdef, ('parent'|'parameter')  --> _ | ~!
    my $pkg = shift;
    return unless @_ == 3;
    bless [@_];
}
sub open_ID { $_[0][0] }       # _                                       --> $typeID
sub resolve_open_ID          { # .T | $Tdef                              --> ?
    return 0 unless ref $_[1] eq 'HASH' or Kephra::Base::Data::Type::Factory::is_type($_[1]);
    $_[0][1]{ $_[0][2] } = $_[1];
    1;
}

#### constructor, serialisation ################################################
sub new {      # -- |'open'   --> .tnamespace
    my ($pkg) = @_;                      #  0|1|'open' (stay)    __PACKAGE__  __FILE__
    bless {open => (exists $_[1] and lc $_[1] eq 'open') ? 'open' : 1,
           basic_type => {}, param_type => {},
           basic_owner => {}, param_owner => {}, basic_origin => {}, param_origin => {},
           basic_symbol => {}, basic_symbol_name => {}, param_symbol => {}, param_symbol_name => {},
           forbid_symbol => {},
};
}
sub state {    #            --> %state
    my ($self) = @_;
    my %state = (basic_symbol => {%{$self->{'basic_symbol'}}},  param_symbol => {%{$self->{'param_symbol'}}},
                 forbid_symbol => [@{$self->{'forbid_symbol'}}],  open => $self->{'open'}  );
    $state{'basic_type'}{$_->name} = $_->state for values %{$self->{'basic_type'}};
    $state{'basic_owner'} = {%{$self->{'basic_owner'}}} if exists $self->{'basic_owner'};
    $state{'basic_owner'} = {%{$self->{'basic_owner'}}} if exists $self->{'basic_owner'};
basic_owner => {%{$self->{'basic_owner'}}}, basic_origin => {%{$self->{'basic_origin'}}},

    for my $type_name (keys %{$self->{'param_type'}}) {
        $state{'param_type'}{$type_name}{$_->parameter->name} = $_->state for values %{$self->{'param_type'}{$type_name}};
        $state{'param_owner'}{$type_name} = {%{$self->{'param_owner'}{$type_name}}} if exists $self->{'param_owner'}{$type_name};
        $state{'param_origin'}{$type_name} = {%{$self->{'param_origin'}{$type_name}}} if exists $self->{'param_origin'}{$type_name};
    }
    \%state;
}
sub restate {  # %state     --> .tnamespace
    my ($pkg, $state) = @_;
    return unless ref $state eq 'HASH' and ref $state->{'basic_type'} eq 'HASH' and ref $state->{'param_type'} eq 'HASH';
    $state->{'basic_type'}{$_->{'name'}} = Kephra::Base::Data::Type::Basic->restate($_) for values %{ $state->{'basic_type'} };
    $state->{'basic_symbol_name'}{ $state->{'basic_symbol'}{$_} } = $_ for keys %{$state->{'basic_symbol'}};
    $state->{'param_symbol_name'}{ $state->{'basic_symbol'}{$_} } = $_ for keys %{$state->{'param_symbol'}};
    for my $type_name (keys %{$state->{'param_type'}}) {
        $state->{'param_type'}{$type_name}{$_->{'parameter'}{'name'}} = Kephra::Base::Data::Type::Parametric->restate($_)
            for values %{$state->{'param_type'}{$type_name}};
    }
    bless $state;
}

################################################################################
sub is_open { $_[0]->{'open'} }  # _ --> ? | 'open' # (cant be closed), closed cant be changed
sub close   {                    # _ --> ?
    return 0 if $_[0]->{'open'} eq 'open';
    delete $_[0]->{$_} for qw /basic_owner param_owner basic_origin param_origin/;
    $_[0]->{'open'} = 0;
    1;
}

##### type definition handling (resolving type names) ##########################
sub need_resolve { open_type_ID($_[1]) }                                     # _ .typedef -->  @ID (0-2)
sub can_resolve { grep {$_[0]->get_type($_)} $_[0]->need_resolve($_[1]) }    # _ .typedef -->  @ID (0-2)
sub resolve_type_ref {                                                          # _ .typedef --> +known, +solved
    my ($self, $type_def) = @_;
    return undef unless ref $type_def eq 'HASH';
    my @need = open_type_ID( $type_def );
    return (0,0) unless @need;
    my @have = grep {$_} map { $self->get_type($_) } @need;
    return (int @have, @need - @have) unless @need == @have;
    my %dict = map {Kephra::Base::Data::Type::Factory::full_name_from_ID( $need[$_] ), $have[$_]} 0 .. $#have;
    Kephra::Base::Data::Type::Factory::resolve_type_ref( $type_def, \%dict );
   (int @have, int @need );
}

sub create_type {                                 # %typedef --> .type
    my ($self, $type_def) = @_;
    return undef unless ref $type_def eq 'HASH';
    my ($known, $open) = $self->resolve_type_ref( $type_def );
    return "definition of type '$type_def->{name}' refers to unknown types, by name resolved $known" if $open;
    Kephra::Base::Data::Type::Factory::_create_type($type_def);
}

#### type handling (add remove lookup) ########################################
sub add_type {                               # .type - ~symbol ?public      --> .type, @ID | ~!
    my ($self, $type, $symbol, $public) = @_;
    return 'can not add to a closed type namespace' unless $self->{'open'};
    my ($package, $file, $line) = (defined $public and $public) ? ('', '', '') : caller();
    if (ref $type eq 'HASH'){
        for my $tname( $self->need_resolve( $type )) {
            return "definition of type $type->{name} refers to unknown type '$tname'" unless ref $self->get_type( $tname );
        }
        $self->_add_type_def( $type, $symbol, $package, $file );
    } elsif ( is_type($type) ) {
        $self->_add_type_object( $type, $symbol, $package, $file );
    } else { "this namespace accepts only type objects or type definitions (hash ref)" }
}
sub _add_type_def {
    my ($self, $type_def, $symbol, $package, $file ) = @_;
    my ($name, @added_ID);
    return unless ref $type_def eq 'HASH';
    if (ref $type_def->{'parameter'} eq 'HASH'){
        my @result = $self->_add_type_def( $type_def->{'parameter'}, undef, $package, $file);
        return @result unless ref $result[0];
        $type_def->{'parameter'} = shift @result;
        push @added_ID, @result;
    } elsif (exists $type_def->{'parameter'} ){
        my $ptype = $self->get_type( $type_def->{'parameter'} );
        return "definition of type '$type_def->{name}' has issue: parameter name '$type_def->{'parameter'}' refers to unknow type"
            unless ref $ptype;
        $type_def->{'parameter'} = $ptype;
    }
    if (ref $type_def->{'parent'}  eq 'HASH'){
        my @result = $self->_add_type_def( $type_def->{'parent'}, undef, $package, $file);
        return @result unless ref $result[0];
        $type_def->{'parent'} = shift @result;
        push @added_ID, @result;
    } elsif (exists $type_def->{'parent'}){
        my $ptype = $self->get_type( $type_def->{'parent'} );
        return "definition of type '$type_def->{name}' has issue: parent name '$type_def->{'parent'}' refers to unknow type"
            unless ref $ptype;
        $type_def->{'parent'} = $ptype;
    }
    $symbol = delete $type_def->{'symbol'} unless defined $symbol;

    my $type = Kephra::Base::Data::Type::Factory::_create_type($type_def);
    return $type unless ref $type;
    ($type, $name) = $self->_add_type_object( $type, $symbol, $package, $file );
    return $type unless ref $type;
    $type, $type->ID, @added_ID;
}
sub _add_type_object {
    my ($self, $type, $symbol, $package, $file) = @_;
    if (defined $symbol and $symbol){
         my $error = $self->_check_symbol( $symbol , $type->kind );
         return $error if $error;
    } else { $symbol = '' }
    my $type_name = $type->name;
    if ( is_type($type, 'basic') ){
        return "there is alreasy a basic type under the name '$type_name' in this namespace" if exists $self->{'basic_type'}{ $type_name};
        $self->{'basic_type'}{ $type_name} = $type;
        $self->{'basic_owner'}{ $type_name } = $package if $package;
        $self->{'basic_origin'}{ $type_name } = $file if $file;
        $self->{'basic_symbol'}{ $type_name } = $symbol if $symbol;
        $self->{'basic_symbol_name'}{ $symbol } = $type_name if $symbol;
        return $type, $type->ID;
    } elsif ( is_type($type, 'param') ) {
        my $param_name = $type->parameter->name;
        my $full_name = $type_name.' of '.$param_name;
        return "there is alreasy a parametric type under the name '$full_name' in this namespace"
            if exists $self->{'param_type'}{ $type_name}{ $param_name };
        $self->{'param_type'}{ $type_name}{ $param_name } = $type;
        $self->{'param_owner'}{ $type_name }{ $param_name } = $package if $package;
        $self->{'param_origin'}{ $type_name }{ $param_name } = $file if $file;
        if ($symbol and not exists $self->{'param_symbol'}{ $type_name }){
            $self->{'param_symbol'}{ $type_name } = $symbol;
            $self->{'param_symbol_name'}{ $symbol } = $type_name;
        }
        return $type, $type->ID;
    }
}

sub remove_type {                          # ~type - ~param                  --> .type|~!
    my $self = shift;
    return 'can not remove from a closed type namespace' unless $self->{'open'};
    my $type = $self->get_type( @_ );
    my $full_name = $type->full_name;
    return "type '$full_name' is unknown and can not be removed from namespace" unless ref $type;
    my ($package, $file, $line) = caller();
    my $owned = $self->_is_type_owned($type, $package, $file);
    return "type '$full_name' can not be deleted by caller '$package' in '$file', because it is no the owner" unless $owned;
    my $type_name = $type->name;
    if ($type->kind eq 'basic') {
        delete $self->{'basic_symbol_name'}{ delete $self->{'basic_symbol'}{ $type_name } } if exists $self->{'basic_symbol'}{ $type_name };
        delete $self->{'basic_origin'}{ $type_name };
        delete $self->{'basic_owner'}{ $type_name };
        delete $self->{'basic_type'}{ $type_name };
    } else {
        my $param_name = $type->parameter->name;
        my $type = delete $self->{'param_type'}{ $type_name }{ $param_name };
        delete $self->{'param_type'}{ $type_name } unless %{$self->{'param_type'}{ $type_name }};
        if (exists $self->{'param_symbol'}{ $type_name } and not exists $self->{'param_type'}{ $type_name }){
            delete $self->{'param_symbol_name'}{ delete $self->{'param_symbol'}{ $type_name } };
        }
        delete $self->{'param_origin'}{ $type_name }{ $param_name } if exists $self->{'param_origin'}{ $type_name };
        delete $self->{'param_origin'}{ $type_name }                unless %{$self->{'param_origin'}{ $type_name }};
        delete $self->{'param_owner'}{ $type_name }{ $param_name } if exists $self->{'param_owner'}{ $type_name };
        delete $self->{'param_owner'}{ $type_name }                unless %{$self->{'param_owner'}{ $type_name }};
    }
    $type;
}

sub get_type {                                 # ~type -- ~param       --> .btype|.ptype|undef
    my ($self, $type_name, $param_name) = @_;
    ($type_name, $param_name) = @$type_name if ref $type_name eq 'ARRAY';
    if (defined $param_name and $param_name){
       return $self->{'param_type'}{$type_name}{$param_name} if exists $self->{'param_type'}{$type_name}
    } elsif (defined $type_name) {
       return $self->{'basic_type'}{$type_name}
    }
    undef;
}
sub has_type      { ref get_type(@_) ? 1 : 0 }      # _ ~type - ~param --> ?
sub is_type_owned {                                 # _ ~type - ~param --> ?
    my $self = shift;
    my $type = $self->get_type(@_);
    return 0 unless ref $type;
    my ($package, $file, $line) = caller();
    $self->_is_type_owned( $type, $package, $file );
}
sub _is_type_owned {
    my ($self, $type, $package, $file) = @_;
    if ($type->kind eq 'basic'){
        return 1 if not exists $self->{'basic_owner'}{$type->name};
        return 1 if $self->{'basic_owner'}{$type->name} eq $package and $self->{'basic_origin'}{$type->name} eq $file;
    } else {
        return 1 if not exists $self->{'param_owner'}{$type->name}
                 or not exists $self->{'param_owner'}{$type->name}{$type->parameter->name};
        return 1 if $self->{'param_owner'}{$type->name}{$type->parameter->name} eq $package
                and $self->{'param_origin'}{$type->name}{$type->parameter->name} eq $file;
    }
    0;
}

sub list_types   {                             # -                           --> @ ~ID|@ID
    my ($self) = @_;
    values %{$self->{'basic_type'}},
    map {values %$_} values %{$self->{'param_type'}}
}

sub list_type_names   {                        # - ~kind ~ptype              --> @~btype|@~ptype|@~param
    my ($self, $kind, $type_name) = @_;        # kind = 'basic' | 'param'
    ($kind = _key_from_kind_($kind)) or return;
    if (defined $type_name){
        return unless exists $self->{'param_type'}{$type_name} and $kind eq 'param';
        return sort keys %{ $self->{'param_type'}{$type_name}};
    }
    sort keys %{$self->{$kind.'_type'}};
}
sub _key_from_kind_ {
    return 'basic' if not defined $_[0] or or not $_[0] index($_[0], 'bas') > -1;
    return 'param' if index($_[0], 'para') > -1;
}

#### type symbols ##############################################################
sub add_symbol {                                     # _ ~symbol, ~base_name, ~param_name --> ~errormsg
    my ($self, $symbol, $base_name, $param_name) = @_;
    my $kind = Kephra::Base::Data::Type::Factory::full_name_kind( $name );
    return " '$name' is no valid type"
type_ID_kind

_key_from_kind_($kind)) or return;
    my $error = $self->_check_symbol($kind, $symbol)
    $self->{$kind.'_symbol'}{$name};
}
sub remove_symbol {                                  # _ ~kind ~symbol       --> ~errormsg
    my ($self, $symbol, $kind) = @_;
    ($kind = _key_from_kind_($kind)) or return;
    $self->{$kind.'_symbol_name'}{$symbol};
}
sub symbol_from_full_name {                          # _ ~name - ~kind       --> ~symbol|undef
    my ($self, $name, $kind) = @_;
    ($kind = _key_from_kind_($kind)) or return;
    $self->{$kind.'_symbol'}{$name};
}
sub full_name_from_symbol {                          # _ ~symbolt - ~kind    --> ?~full_name
    my ($self, $symbol, $kind) = @_;
    ($kind = _key_from_kind_($kind)) or return;
    $self->{$kind.'_symbol_name'}{$symbol};
}


sub list_symbols    {                                # _ - ~kind             --> @~symbol
    my ($self, $kind) = @_;
    ($kind = _key_from_kind_($kind)) or return;
    sort keys %{$self->{$kind.'_symbol_name'}};
}
sub list_forbidden_symbols { sort keys %{$_[0]->{'forbid_symbol'}} } # _     --> @~symbol
sub allow_symbols  {                                 # _ @~shortcut          --> @~symbol
    my ($self) = shift;
    return 'can not change a closed type set' unless $self->{'open'};
    grep {$_} map { delete $self->{'forbid_symbol'}{$_} } @_;
}
sub forbid_symbols  {                                # _ @~shortcut          --> @~symbol
    my ($self) = shift;
    return 'can not change a closed type set' unless $self->{'open'};
    map {$self->{'forbid_symbol'}{$_}++; $_} grep {not exists $self->{'forbid_symbol'}{$_}} grep { _is_symbol($_) } @_;
}
sub _check_symbol {
    my ($self, $symbol, $kind) = @_;
    ($kind = _key_from_kind_($kind)) or return;
    return "type symbol is undefined" unless defined $symbol;
    return "type symbol '$symbol' is not allowed (check list_forbidden_symbols)" if exists $self->{'forbid_symbol'}{$symbol};
    return "type symbol '$symbol' has to be one char (not a-z0-9_)" unless _is_symbol($symbol);
    return "$kind type symbol '$symbol' is already taken" if exists $self->{$kind.'_symbol_name'}{$symbol};
    '';
}
sub _is_symbol {length $_[0] == 1 and $_[0] !~ /[a-z0-9_]/ }  # _ ~symbol  --> ?
