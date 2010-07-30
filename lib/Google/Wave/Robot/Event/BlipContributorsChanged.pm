package Google::Wave::Robot::Event::BlipContributorsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str ArrayRef);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("BLIP_CONTRIBUTORS_CHANGED");

has _contributors_added => (
    traits   => [ "Array" ],
    is       => "ro",
    isa      => ArrayRef[Str],
    default  => sub { [] },
    init_arg => "contributors_added",
    handles  => {
        contributors_added => 'elements',
    },
);

has _contributors_removed => (
    traits   => [ "Array" ],
    is       => "ro",
    isa      => ArrayRef[Str],
    default  => sub { [] },
    init_arg => "contributors_removed",
    handles  => {
        contributors_removed => 'elements',
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
