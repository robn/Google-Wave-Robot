package Google::Wave::Robot::Element::TextArea;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Element");

__PACKAGE__->register_element_class("TEXTAREA", attributes => [qw(name value)]);

has name => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has value => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
