package Google::Wave::Robot::Element::RadioButton;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Element");

__PACKAGE__->register_element_class("RADIO_BUTTON", attributes => [qw(name value=group)]);

has name => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has group => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
