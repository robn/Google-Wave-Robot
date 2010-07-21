package Google::Wave::Robot::Event::WaveletTitleChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

class_has "type" => (
    is       => "ro",
    isa      => "Str",
    default  => "WAVELET_TITLE_CHANGED",
    init_arg => undef,
);

has "title" => (
    is  => "ro",
    isa => "Str",
);

method BUILDARGS ( ClassName $class: HashRef :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        title => $json->{properties}->{title},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
