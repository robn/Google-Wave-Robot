package Google::Wave::Robot::Event::AnnotatedTextChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str);

extends ("Google::Wave::Robot::Event");

__PACKAGE__->register_event_class("ANNOTATED_TEXT_CHANGE");

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
