package Google::Wave::Robot::Event::WaveletBlipCreated;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet Blip);

extends ("Google::Wave::Robot::Event");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "WAVELET_BLIP_CREATED",
    init_arg => undef,
);

has new_blip_id => (
    is  => "ro",
    isa => Str,
);

has new_blip => (
    is  => "ro",
    isa => Blip,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    my $args = $class->SUPER::BUILDARGS(json => $json, wavelet => $wavelet);

    $args->{new_blip_id} = $json->{properties}->{newBlipId};
    $args->{new_blip}    = $wavelet->blip($args->{new_blip_id});

    return $args;
}

#__PACKAGE__->meta->make_immutable;

1;

__END__
