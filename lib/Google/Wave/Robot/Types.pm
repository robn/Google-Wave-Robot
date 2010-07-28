package Google::Wave::Robot::Types;

use 5.010;

use namespace::autoclean;

use MooseX::Types -declare => [qw(
    Robot Wavelet Blip BlipSet Operation OperationQueue Participant
)];

use MooseX::Types::Moose qw(Str);

use Google::Wave::Robot::Participant;

class_type Robot,          { class => 'Google::Wave::Robot' };
class_type Wavelet,        { class => 'Google::Wave::Robot::Wavelet' };
class_type Blip,           { class => 'Google::Wave::Robot::Blip' };
class_type BlipSet,        { class => 'Google::Wave::Robot::Blip::Set' };
class_type Operation,      { class => 'Google::Wave::Robot::Operation' };
class_type OperationQueue, { class => 'Google::Wave::Robot::Operation::Queue' };
class_type Participant,    { class => 'Google::Wave::Robot::Participant' };

coerce Participant,
    from Str,
        via { Google::Wave::Robot::Participant->new(id => $_) };

1;

__END__
