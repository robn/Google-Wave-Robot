package Google::Wave::Robot::Event::WaveletBlipRemoved;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_BLIP_CREATED");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "WAVELET_BLIP_REMOVED",
    init_arg => undef,
);

has removed_blip_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
