package Google::Wave::Robot::Event;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str Int HashRef);
use Google::Wave::Robot::Types qw(Blip Wavelet);

# load event classes as a convenience to the caller
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
use Google::Wave::Robot::Event::Context;

has json => (
    is       => "ro",
    isa      => HashRef,
    required => 1,
);

has type => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has wavelet => (
    is       => "ro",
    isa      => Wavelet,
    required => 1,
);

has modified_by => (
    is  => "ro",
    isa => Str,
);

has timestamp => (
    is  => "ro",
    isa => Int,
);

has proxying_for => (
    is  => "ro",
    isa => Str,
);

has properties => (
    is  => "ro",
    isa => HashRef,
);

has blip_id => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    my $args = {};

    $args->{json}    = $json;
    $args->{wavelet} = $wavelet;

    $args->{type}         = $json->{type};
    $args->{modified_by}  = $json->{modifiedBy};
    $args->{timestamp}    = $json->{timestamp} || 0;
    $args->{proxying_for} = $json->{proxyingFor} if defined $json->{proxyingFor};

    if ($json->{properties}) {
        $args->{properties} = $json->{properties};
        $args->{blip_id}    = $json->{properties}->{blipId} if exists $json->{properties}->{blipId};
    }

    return $args;
}

method blip () {
    return if !$self->blip_id;
    return $self->wavelet->blip($self->blip_id);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
