
# data holding leave in data tree structure

package Data::Store::Consistent::Node::Outer;
use v5.12;
use warnings;
use Data::Store::Consistent::Type;

sub new {
    # my ($pkg, $def) = @_;
    my ($pkg, $name, $ype, $description, $permission, $note, $default_value, $read_trigger, $write_trigger) = @_;
    #~ return 'need a data set object as first argument' unless ref $type_set eq 'Data::Store::Consistent::Type::Set';
    #~ return 'need a node name as second argument' unless defined $name and $name;
    #~ return 'need help text as third argument' unless defined $help and $help;
    #~ $type //= 'any';
    #~ return 'unkown type' unless $type_set->has_type( $type );
    #~ $default //= $type_set->get_default_value( $type );

    #~ bless { name => $name, help => $help, type => $type, value => '',
            #~ type_checker => $type_set->get_type_checker( $type ), eq_checker => $type_set->get_equality_checker( $type ),
            #~ actions => '',
          #~ };
    #~ - help: ~
    #~ - type: ~typename | ~typedef
    #~ - ?default_value: $               # optional when type name given | to init
    #~ - ?writer: &
    #~ - $write_trigger: @node_path      # trigger writer when on of these nodes changes
}

sub get_property {
    my ($self, $property) = @_;
    # node exists ?
}

sub read {
    my ($self, $silent) = @_;
    $self->{'actions'}->trigger('read');
    $self->{'value'}; # clone?
}


sub write {
    my ($self, $data) = @_;
    return unless exists $self->{'type'}; # only to be written by writer
    # also stop if readonly
    my $error = $self->{'type_checker'}->($data, $self->{'name'});
    return $error if $error; # + params
    $error = $self->{'eq_checker'}->($data, $self->{'value'}, $self->{'name'});
    return $error if $error;
    $self->{'actions'}->trigger('write');
    $self->{'value'} = $data;
}

sub reset {
    my ($self, $silent) = @_;
    # also stop if readonly
    $self->write( $self->{'default_value'}, $silent );
}

1;

__END__

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
