package Google::Wave::Robot::Event::WaveletParticipantsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str ArrayRef);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_PARTICIPANTS_CHANGED");

has participants_added => (
    is  => "ro",
    isa => ArrayRef[Str],   # XXX ParticipantSet?
    default => sub { [] },
);

has participants_removed => (
    is  => "ro",
    isa => ArrayRef[Str],
    default => sub { [] },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
