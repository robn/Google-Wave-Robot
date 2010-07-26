package Google::Wave::Robot::Event::BlipSubmitted;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("BLIP_SUBMITTED");

class_has type => (
    is       => "ro",
    isa      => "Str",
    default  => "BLIP_SUBMITTED",
    init_arg => undef,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
