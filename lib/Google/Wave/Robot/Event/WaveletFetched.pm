package Google::Wave::Robot::Event::WaveletFetched;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "WAVELET_FETCHED";

has "message" => (
    is  => "ro",
    isa => "Str",
);

method BUILDARGS ( ClassName $class: HashRef :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        message => $json->{properties}->{message},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
