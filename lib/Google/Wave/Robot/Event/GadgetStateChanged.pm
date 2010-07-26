package Google::Wave::Robot::Event::GadgetStateChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("GADGET_STATE_CHANGED");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "GADGET_STATE_CHANGED",
    init_arg => undef,
);

has index => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has old_state => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
