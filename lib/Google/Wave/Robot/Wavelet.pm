package Google::Wave::Robot::Wavelet;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Str Int HashRef ArrayRef Object);
use Google::Wave::Robot::Types qw(Blip BlipSet OperationQueue Participant ParticipantRole);

use Google::Wave::Robot::Blip;
use Google::Wave::Robot::Blip::Set;
use Google::Wave::Robot::Operation::Queue;
use Google::Wave::Robot::Participant;

use Carp;

has wavelet_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has wave_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has creator => (
    is       => "ro",
    isa      => Str,
    default  => '',
);

has creation_time => (
    is       => "ro",
    isa      => Int,
    default  => 0,
);

has last_modified_time => (
    is       => "ro",
    isa      => Int,
    default  => 0,
);


has title => (
    is      => "rw",
    isa     => Str,
    default => '',
);

around title => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig if not @_;

    # XXX util.force_unicode(title)
 
    my $title = shift;
    confess "wavelet title may not contain a newline" if $title =~ m/\n/smg;

    $self->$orig($title);

    $self->operation_queue->wavelet_set_title(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        title      => $title,
    );

    # XXX adjust the contents of the root blip
};


has operation_queue => (
    is       => "ro",
    isa      => OperationQueue,
    default  => sub { Google::Wave::Robot::Operation::Queue->new },
);

has robot_address => (
    is      => "rw",
    isa     => Str,
    default => '',
);

before robot_address => sub {
    my $self = shift;
    confess "robot_address is already set" if @_ > 0 && $self->robot_address;
};


has _data_documents => (
    traits   => [ "Hash" ],
    is       => "ro",
    isa      => HashRef[Str],
    default  => sub { {} },
    init_arg => "data_documents",
    handles  => {
        data_documents        => 'elements',
        data_document         => 'get',
        _add_data_document    => 'set',
        _remove_data_document => 'delete',
    },
);

method add_data_document ( Str $name, Str $data ) {
    return if $self->data_document($name);
    $self->_add_data_document($name, $data);

    $self->operation_queue->wavelet_datadoc_set(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        name       => $name,
        data       => $data,
    );
}

method remove_data_document ( Str $name ) {
    return if !$self->data_document($name);
    $self->_remove_data_document($name);

    $self->operation_queue->wavelet_datadoc_set(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        name       => $name,
        data       => undef,
    );
}



# XXX consider a string type here that matches foo@bar

subtype 'HashRefOfParticipants',
    as HashRef[Participant];

coerce 'HashRefOfParticipants',
    from ArrayRef[Str],
    via { scalar { map { $_ => Google::Wave::Robot::Participant->new(id => $_) } @{$_} } };

has _participants => (
    traits   => [ "Hash" ],
    is       => "ro",
    isa      => 'HashRefOfParticipants',
    coerce   => 1,
    default  => sub { {} },
    init_arg => "participants",
    handles  => {
        participants     => 'values',
        participant      => 'get',
        _add_participant => 'set',
    },
);

method add_participant ( Str $id ) {
    return if $self->participant($id);
    $self->_add_participant($id, Google::Wave::Robot::Participant->new(id => $id));

    $self->operation_queue->wavelet_add_participant(
        wave_id        => $self->wave_id,
        wavelet_id     => $self->wavelet_id,
        participant_id => $id,
    );
}


subtype 'HashRefOfStr',
    as HashRef[Str];

coerce 'HashRefOfStr',
    from ArrayRef[Str],
    via { scalar { map { $_ => 1 } @{$_} } };

has _tags => (
    traits   => [ "Hash" ],
    is       => "ro",
    isa      => 'HashRefOfStr',
    coerce   => 1,
    default  => sub { {} },
    init_arg => 'tags',
    handles  => {
        tags        => 'keys',
        tag         => 'get',
        _add_tag    => 'set',
        _remove_tag => 'delete',
    },
);

method add_tag ( Str $tag ) {
    return if $self->tag($tag);
    $self->_add_tag($tag, 1);

    $self->operation_queue->wavelet_modify_tag(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        tag        => $tag,
        modify_how => "add",
    );
}

method remove_tag ( Str $tag ) {
    return if !$self->tag($tag);
    $self->_remove_tag($tag);

    $self->operation_queue->wavelet_modify_tag(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        tag        => $tag,
        modify_how => "remove",
    );
}


=pod
has root_thread => (
    is  => "ro",
    isa => Object,  # XXX BlipThread
);
=cut

has root_blip_id => (
    is      => "ro",
    isa     => Str,
    default => '',
);

has blips => (
    is      => "ro",
    isa     => BlipSet,
    handles => {
        blip => 'get',
    },
    default => sub { Google::Wave::Robot::Blip::Set->new }, # XXX array coercion?
    lazy    => 1,
);

method new_from_json ( ClassName $class: HashRef $json, OperationQueue :$operation_queue? ) {
    my $wavelet_data = $json->{wavelet} || $json->{waveletData} || $json;

    my %args = (
        wavelet_id => $wavelet_data->{waveletId},
        wave_id    => $wavelet_data->{waveId},
    );

    $args{operation_queue} = $operation_queue if $operation_queue;

    $args{creator}            = $wavelet_data->{creator}          if defined $wavelet_data->{creator};
    $args{creation_time}      = $wavelet_data->{creationTime}     if defined $wavelet_data->{creationTime};
    $args{last_modified_time} = $wavelet_data->{lastModifiedTime} if defined $wavelet_data->{lastModifiedTime};
    $args{title}              = $wavelet_data->{title}            if defined $wavelet_data->{title};
    $args{root_blip_id}       = $wavelet_data->{rootBlipId}       if defined $wavelet_data->{rootBlipId};

    $args{robot_address} = $json->{robotAddress} if exists $json->{robotAddress};

    my $wavelet = $class->new(%args);

    $operation_queue = $wavelet->operation_queue;
    my $blips = $wavelet->blips;

    for my $blip_data (values %{$json->{blips}}) {
        my $blip = Google::Wave::Robot::Blip->new_from_json($blip_data, operation_queue => $operation_queue, other_blips => $blips);
        $blips->add($blip->blip_id, $blip);
    }

    %{$args{participants}} = map {
        $_ => Google::Wave::Robot::Participant->new(
            id   => $_,
            role => $wavelet_data->{participantRoles}->{$_} // "FULL"
        )
    } @{$wavelet_data->{participants}};
 
    $args{tags} = $wavelet_data->{tags};

    $args{data_documents} = $wavelet_data->{dataDocuments};

    # XXX threads

    return $wavelet;
}

method root_blip () {
    return $self->blip($self->root_blip_id);
}

method serialize () {
}

method proxy_for () {
}

method add_proxying_participant ( Str $proxy_id ) {
    croak "need a robot address to add a proxying participant" if !$self->robot_address;

    # robotid+proxy#version@domain
    my ($robot_id, $old_proxy_id, $version, $domain) = $self->robot_address =~ m/^([^+#@]+)(?:\+([^#@]+))?(?:\#([^@]+))?\@(.*)$/;

    my $new_id = sprintf q{%s+%s%s@%s}, $robot_id, $proxy_id, $version ? "#$version" : '', $domain;

    $self->participants->add($new_id);
}

method submit_with () {
}

method reply ( Str $text? = "\n" ) {
    # XXX text = util.force_unicode(text)
    
    my $blip_data = $self->operation_queue->wavelet_append_blip(
        wave_id         => $self->wave_id,
        wavelet_id      => $self->wavelet_id,
        initial_content => $text,
    );
    # XXX gets it running again though I really feel like we should be
    # creating through the normal constructor. or, the opqueue helpers should
    # return a full blip object
    my $blip = Google::Wave::Robot::Blip->new_from_json($blip_data,
        operation_queue => $self->operation_queue,
        other_blips     => $self->blips,
    );
    $self->blips->add($blip->blip_id, $blip);
}

method delete () {
}

__PACKAGE__->meta->make_immutable;

1;

__END__
