package Google::Wave::Robot;
# ABSTRACT: Wave Robot client library for Perl

use 5.010;

our $VERSION = '0.01';

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str Int HashRef CodeRef);
use MooseX::Types::JSON qw(JSON);

use Google::Wave::Robot::Operation;
use Google::Wave::Robot::Operation::Queue;
use Google::Wave::Robot::Wavelet;

use Google::Wave::Robot::Event;
use Google::Wave::Robot::Event::Context;
use Google::Wave::Robot::Event::AnnotatedTextChanged;
use Google::Wave::Robot::Event::BlipContributorsChanged;
use Google::Wave::Robot::Event::BlipSubmitted;
use Google::Wave::Robot::Event::DocumentChanged;
use Google::Wave::Robot::Event::FormButtonClicked;
use Google::Wave::Robot::Event::GadgetStateChanged;
use Google::Wave::Robot::Event::OperationError;
use Google::Wave::Robot::Event::WaveletBlipCreated;
use Google::Wave::Robot::Event::WaveletBlipRemoved;
use Google::Wave::Robot::Event::WaveletCreated;
use Google::Wave::Robot::Event::WaveletFetched;
use Google::Wave::Robot::Event::WaveletParticipantsChanged;
use Google::Wave::Robot::Event::WaveletSelfAdded;
use Google::Wave::Robot::Event::WaveletSelfRemoved;
use Google::Wave::Robot::Event::WaveletTagsChanged;
use Google::Wave::Robot::Event::WaveletTitleChanged;

use JSON qw(encode_json decode_json);

has "_handlers" => (
    is      => "rw",
    isa     => HashRef,
    default => sub { {} },
);

has "capabilities_hash" => (
    is      => "ro",
    isa     => Int,
    writer  => "_set_capabilities_hash",
    default => 0,
);

has name => (
    is  => "ro",
    isa => Str,
);

has profile_url => (
    is  => "ro",
    isa => Str,
);

has image_url => (
    is  => "ro",
    isa => Str,
);

has profile_handler => (
    is  => "ro",
    isa => CodeRef,
);

has verification_token => (
    is       => "ro",
    isa      => Str,
);

has security_token => (
    is  => "ro",
    isa => Str,
);

has _consumer_key => (
    is  => "rw",
    isa => Str,
);

has _consumer_secret => (
    is  => "rw",
    isa => Str,
);

method _profile_sanity_check () {
    if ($self->profile_handler) {
        if ($self->name || $self->profile_url || $self->image_url) {
            confess "may not specify profile_handler with name/profile_url/image_url";
        }
    }
    else {
        if (!($self->name && $self->profile_url && $self->image_url)) {
            confess "must specify name/profile_url/image_url or profile_handler";
        }
    }
}

method BUILD {
    $self->_profile_sanity_check;
}

method setup_oauth () {
}

my $hash_func = sub {
    require B;
    return hex(B::hash(shift));
};

# XXX include context and filter
method register_handler ( Str $event_class, CodeRef $callback ) {
    my $type = $event_class->type;

    $self->_handlers->{$type} = {
        event_class => $event_class,
        callback    => $callback,
        # XXX context
        # XXX filter
    };

    $self->_set_capabilities_hash((
        $self->capabilities_hash * 13 +
        $hash_func->(Google::Wave::Robot::Operation::PROTOCOL_VERSION) + 
        $hash_func->($type)
        # XXX $hash_func->($context) +
        # XXX $hash_func->($filter)
    ) & 0xfffffff);
}

method capabilities_xml () {
    my $xml =
        q{<?xml version="1.0"?>}.
        q{<w:robot xmlns:w="http://wave.google.com/extensions/robots/1.0">}.
            q{<w:version>}.$self->capabilities_hash.q{</w:version>}.
            q{<w:protocolversion>}.Google::Wave::Robot::Operation::PROTOCOL_VERSION.q{</w:protocolversion>};

    if ($self->_consumer_key) {
        $xml .= q{<w:consumer_key>}.$self->_consumer_key.q{</w:consumer_key>};
    }

    if (keys %{$self->_handlers}) {
        my $handlers = $self->_handlers;

        $xml .= q{<w:capabilities>};

        for my $capability (keys %$handlers) {
            $xml .= q{<w:capability name='}.$capability.q{'/>};
            # XXX contexts & filters
        }

        $xml .= q{</w:capabilities>};
    }

    $xml .= q{</w:robot>};

    return $xml;
}

method profile_json () {
    if ($self->profile_handler) {
        return encode_json($self->profile_handler->($self));
    }

    return encode_json({
        name       => $self->name,
        profileUrl => $self->profile_url,
        imageUrl   => $self->image_url,
    });
}

method process_events ( JSON $json ) {
    my $parsed = decode_json($json);

    my $pending_ops = Google::Wave::Robot::Operation::Queue->new;
    my $event_wavelet = Google::Wave::Robot::Wavelet->new_from_json($parsed, operation_queue => $pending_ops);

    for my $event_data (@{$parsed->{events}}) {
        if (my $handler = $self->_handlers->{$event_data->{type}}) {
            my $event = $handler->{event_class}->new_from_json($event_data, wavelet => $event_wavelet);
            $handler->{callback}->($event, $event_wavelet);
        }
    }

    $pending_ops->capabilities_hash($self->capabilities_hash);
    return encode_json($pending_ops->serialize);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
