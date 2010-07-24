package Google::Wave::Robot::Event::WaveletCreated;

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
    default  => "WAVELET_CREATED",
    init_arg => undef,
);

has message => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    return {
        message => $json->{properties}->{message},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
