package Google::Wave::Robot::Event::BlipSubmitted;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::JSON qw(JSON);
use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "BLIP_SUBMITTED";

__PACKAGE__->meta->make_immutable;

1;

__END__
