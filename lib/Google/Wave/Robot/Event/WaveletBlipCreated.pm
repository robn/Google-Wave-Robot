package Google::Wave::Robot::Event::WaveletBlipCreated;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet Blip);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_BLIP_CREATED");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "WAVELET_BLIP_CREATED",
    init_arg => undef,
);

has new_blip_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

method new_blip () {
    return $self->wavelet->blip($self->new_blip_id);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
