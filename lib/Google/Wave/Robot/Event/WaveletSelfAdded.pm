package Google::Wave::Robot::Event::WaveletSelfAdded;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_SELF_ADDED");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "WAVELET_SELF_ADDED",
    init_arg => undef,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
