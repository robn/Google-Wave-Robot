package Google::Wave::Robot::Event::WaveletParticipantsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

class_has "type" => (
    is       => "ro",
    isa      => "Str",
    default  => "WAVELET_PARTICIPANTS_CHANGED",
    init_arg => undef,
);

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
