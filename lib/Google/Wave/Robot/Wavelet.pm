package Google::Wave::Robot::Wavelet;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str Int HashRef ArrayRef Object);
use Google::Wave::Robot::Types qw(Blip BlipSet OperationQueue ParticipantSet);

use Google::Wave::Robot::Blip;
use Google::Wave::Robot::Blip::Set;
use Google::Wave::Robot::Operation::Queue;

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
    is       => "rw",
    isa      => Str,  # XXX hook setter to call set_title and adjust the content
    default  => '',
);

has operation_queue => (
    is       => "ro",
    isa      => OperationQueue,
    default  => sub { Google::Wave::Robot::Operation::Queue->new },
);

has robot_address => (
    is      => "ro",
    isa     => Str,  # XXX can't be set if already set
    default => '',
);

has data_documents => (
    is      => "ro",
    isa     => HashRef[Str],    # XXX key/value pairs, needs some handlers that hook DATADOC_SET
    default => sub { {} },
);

has participants => (
    is      => "ro",
    isa     => ParticipantSet,  # XXX needs handlers that hook ADD_PARTICIPANT
    handles => {
        participant => 'get',
    },
    default => sub { Google::Wave::Robot::Participant::Set->new },
    lazy    => 1,
);

=pod
has root_thread => (
    is  => "ro",
    isa => Object,  # XXX BlipThread
);
=cut

=pod
has tags => (
    is  => "ro",
    isa => ArrayRef[Str], # XXX list of tags, needs handlers that hook MODIFY_TAG
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
    default => sub { Google::Wave::Robot::Blip::Set->new },
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
        my $blip = Google::Wave::Robot::Blip->new(
            json            => $blip_data,
            operation_queue => $operation_queue,
            other_blips     => $blips,
        );
        $blips->add($blip->blip_id, $blip);
    }
    
    # XXX do threads

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

    # XXX put this into the particpants set class
    $self->operation_queue->wavelet_add_participant(wave_id => $self->wave_id, wavelet_id => $self->wavelet_id, participant_id => $new_id);
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
    my $blip = Google::Wave::Robot::Blip->new(
        json            => $blip_data,
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
