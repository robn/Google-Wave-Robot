package Google::Wave::Robot::Event::BlipContributorsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str ArrayRef);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("BLIP_CONTRIBUTORS_CHANGED");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "BLIP_CONTRIBUTORS_CHANGED",
    init_arg => undef,
);

has contributors_added => (
    is      => "ro",
    isa     => ArrayRef[Str],   # XXX ParticipantSet?
    default => sub { [] },
);

has contributors_removed => (
    is      => "ro",
    isa     => ArrayRef[Str],
    default => sub { [] },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
