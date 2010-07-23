package Google::Wave::Robot::Event::WaveletSelfRemoved;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

class_has "type" => (
    is       => "ro",
    isa      => Str,
    default  => "WAVELET_SELF_REMOVED",
    init_arg => undef,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
