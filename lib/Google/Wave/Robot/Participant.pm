package Google::Wave::Robot::Participant;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(ParticipantRole);

# XXX include profile stuff here?

has id => (
	is		 => "ro",
	isa		 => Str,
	required => 1,
);

has role => (
	is       => "ro",
	isa      => ParticipantRole,
	default  => "FULL",
);

__PACKAGE__->meta->make_immutable;

1;
