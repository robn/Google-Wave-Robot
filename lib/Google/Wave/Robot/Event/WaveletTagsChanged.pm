package Google::Wave::Robot::Event::WaveletTagsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "WAVELET_TAGS_CHANGED";

__PACKAGE__->meta->make_immutable;

1;

__END__
