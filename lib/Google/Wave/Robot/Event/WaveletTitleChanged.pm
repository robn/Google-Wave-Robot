package Google::Wave::Robot::Event::WaveletTitleChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "WAVELET_TITLE_CHANGED";

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
