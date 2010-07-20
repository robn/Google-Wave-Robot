package Google::Wave::Robot::Event::AnnotatedTextChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "ANNOTATED_TEXT_CHAGED";

has "name" => (
    is  => "ro",
    isa => "Str",
);

has "value" => (
    is  => "ro",
    isa => "Str",
);

method BUILDARGS ( ClassName $class: HashRef :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        name  => $json->{properties}->{name},
        value => $json->{properties}->{value},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
