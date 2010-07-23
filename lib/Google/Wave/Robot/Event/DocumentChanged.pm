package Google::Wave::Robot::Event::DocumentChanged;

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
    default  => "DOCUMENT_CHANGED",
    init_arg => undef,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
