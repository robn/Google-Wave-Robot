package Google::Wave::Robot::Event::WaveletParticipantsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "WAVELET_PARTICIPANTS_CHANGED";

has "participants_added" => (
    is  => "ro",
    isa => "ArrayRef[Str]",
);

has "participants_removed" => (
    is  => "ro",
    isa => "ArrayRef[Str]",
);

method BUILDARGS ( ClassName $class: HashRef :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        participants_added   => $json->{properties}->{participantsAdded},
        participants_removed => $json->{properties}->{participantsRemoved},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
