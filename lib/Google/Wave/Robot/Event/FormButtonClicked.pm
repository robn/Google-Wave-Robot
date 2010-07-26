package Google::Wave::Robot::Event::FormButtonClicked;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("FORM_BUTTON_CLICKED");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "FORM_BUTTON_CLICKED",
    init_arg => undef,
);

has button_name => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
