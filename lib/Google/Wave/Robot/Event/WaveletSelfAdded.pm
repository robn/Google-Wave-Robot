package Google::Wave::Robot::Event::WaveletSelfAdded;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::JSON qw(JSON);
use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "WAVELET_SELF_ADDED";

__PACKAGE__->meta->make_immutable;

1;

__END__
