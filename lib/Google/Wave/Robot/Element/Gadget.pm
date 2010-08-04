package Google::Wave::Robot::Element::Gadget;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Element");

__PACKAGE__->register_element_class("GADGET", attributes => [qw(url)]);

has url => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
