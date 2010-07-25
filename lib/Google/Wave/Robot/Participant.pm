package Google::Wave::Robot::Participant;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

has id => (
	is		 => "ro",
	isa		 => Str,
	required => 1,
);

has role => (
	is       => "ro",
	isa      => enum([qw(FULL READ_ONLY)]),
	default  => "FULL",
);

__PACKAGE__->meta->make_immutable;

1;
