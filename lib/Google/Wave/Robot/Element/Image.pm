package Google::Wave::Robot::Element::Image;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str Int);

extends ("Google::Wave::Robot::Element");

__PACKAGE__->register_element_class("IMAGE", attributes => [qw(url width height attachmentId caption)]);

has url => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has width => (
    is      => "ro",
    isa     => Int,
    default => 0,
);

has height => (
    is      => "ro",
    isa     => Int,
    default => 0,
);

has attachment_id => (
    is      => "ro",
    isa     => Str,
    default => '',
);

has caption => (
    is      => "ro",
    isa     => Str,
    default => '',
);

__PACKAGE__->meta->make_immutable;

1;

__END__
