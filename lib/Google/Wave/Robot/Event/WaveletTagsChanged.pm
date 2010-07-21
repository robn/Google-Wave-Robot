package Google::Wave::Robot::Event::WaveletTagsChanged;

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
    default  => "WAVELET_TAGS_CHANGED",
    init_arg => undef,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
