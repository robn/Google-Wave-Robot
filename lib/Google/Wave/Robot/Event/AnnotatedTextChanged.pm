package Google::Wave::Robot::Event::AnnotatedTextChanged;

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
    default  => "ANNOTATED_TEXT_CHANGED",
    init_arg => undef,
);

has name => (
    is  => "ro",
    isa => Str,
);

has value => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    return {
        name  => $json->{properties}->{name},
        value => $json->{properties}->{value},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
