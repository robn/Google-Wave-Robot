package Google::Wave::Robot::Event::WaveletBlipRemoved;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::JSON qw(JSON);
use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "WAVELET_BLIP_REMOVED";

has "removed_blip_id" => (
    is  => "ro",
    isa => "Str",
);

method BUILDARGS ( ClassName $class: JSON :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        removed_blip_id => $json->{properties}->{removedBlipId},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
