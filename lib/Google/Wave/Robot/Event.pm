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
    is  => "ro",
    isa => Str,
);

has type => (
    is  => "ro",
    isa => Str,
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

has blip => (
    is  => "ro",
    isa => Blip,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    my $args = {
        json         => $json,
        type         => $json->{type},
        modified_by  => $json->{modifiedBy},
        timestamp    => $json->{timestamp} // 0,
        proxying_for => $json->{proxyingFor},
    };

    $args->{properties} = $json->{properties} // {},

    $args->{blip_id} = $args->{properties}->{blipId} if exists $args->{properties}->{blip_id};
    $args->{blip} = $wavelet->blip($args->{blip_id}) if exists $args->{blip_id};

    return $args;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
