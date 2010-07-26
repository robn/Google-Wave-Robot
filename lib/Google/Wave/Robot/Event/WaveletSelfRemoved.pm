package Google::Wave::Robot::Event::WaveletSelfRemoved;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_SELF_REMOVED");

__PACKAGE__->meta->make_immutable;

1;

__END__
