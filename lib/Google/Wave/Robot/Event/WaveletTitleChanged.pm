package Google::Wave::Robot::Event::WaveletTitleChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("WAVELET_TITLE_CHANGED");

has title => (
    is      => "ro",
    isa     => Str,
    default => '',
);

__PACKAGE__->meta->make_immutable;

1;

__END__
