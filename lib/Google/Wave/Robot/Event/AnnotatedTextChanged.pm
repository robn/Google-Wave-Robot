package Google::Wave::Robot::Event::AnnotatedTextChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("ANNOTATED_TEXT_CHANGE");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "ANNOTATED_TEXT_CHANGE",
    init_arg => undef,
);

has name => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has value => (
    is  => "ro",
    isa => Str,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
