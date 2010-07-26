package Google::Wave::Robot::Event::OperationError;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("OPERATION_ERROR");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "OPERATION_ERROR",
    init_arg => undef,
);

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
