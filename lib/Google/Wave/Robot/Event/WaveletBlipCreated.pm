package Google::Wave::Event::WaveletBlipCreated;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::JSON qw(JSON);
use Google::Wave::Robot::Types;

extends ("Google::Wave::Event");

use constant name => "WAVELET_BLIP_CREATED";

has "new_blip_id" => (
    is  => "ro",
    isa => "Str",
);

has "new_blip" => (
    is  => "ro",
    isa => "Google::Wave::Robot::Blip",
);

method BUILDARGS ( ClassName $class: JSON :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    my $args;

    $args->{new_blip_id} = $json->{properties}->{newBlipId};
    $args->{new_blip}    = $wavelet->blip($args->{new_blip_id});

    return $args;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
