package Google::Wave::Robot::Event::OperationError;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "OPERATION_ERROR";

has "operation_id" => (
    is  => "ro",
    isa => "Str",
);

has "message" => (
    is  => "ro",
    isa => "Str",
);

method BUILDARGS ( ClassName $class: HashRef :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        operation_id => $json->{properties}->{operationId},
        message      => $json->{properties}->{message},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
