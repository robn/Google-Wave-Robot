package Google::Wave::Robot::Event::OperationError;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("OPERATION_ERROR");

has operation_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has message => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
