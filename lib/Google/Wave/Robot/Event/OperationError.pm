package Google::Wave::Robot::Event::OperationError;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet);

extends ("Google::Wave::Robot::Event");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "OPERATION_ERROR",
    init_arg => undef,
);

has operation_id => (
    is  => "ro",
    isa => Str,
);

has message => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    return {
        operation_id => $json->{properties}->{operationId},
        message      => $json->{properties}->{message},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
