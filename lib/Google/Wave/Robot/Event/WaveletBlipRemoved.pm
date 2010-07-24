package Google::Wave::Robot::Event::WaveletBlipRemoved;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet);

extends ("Google::Wave::Robot::Event");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "WAVELET_BLIP_REMOVED",
    init_arg => undef,
);

has removed_blip_id => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    return {
        removed_blip_id => $json->{properties}->{removedBlipId},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
