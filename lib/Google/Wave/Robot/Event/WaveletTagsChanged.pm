package Google::Wave::Robot::Event::WaveletTagsChanged;

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
    default  => "WAVELET_TAGS_CHANGED",
    init_arg => undef,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    return $class->SUPER::BUILDARGS(json => $json, wavelet => $wavelet);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
