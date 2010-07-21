package Google::Wave::Robot::Event::BlipSubmitted;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

has "type" => (
    is      => "ro",
    isa     => "Str",
    default => "BLIP_SUBMITTED",
    init_arg => undef,
);

__PACKAGE__->meta->make_immutable;

1;

__END__
