package Google::Wave::Robot::Types;

use 5.010;

use namespace::autoclean;

use Moose;
use Moose::Util::TypeConstraints;

class_type 'Google::Wave::Robot';
class_type 'Google::Wave::Robot::Wavelet';
class_type 'Google::Wave::Robot::Blip';
class_type 'Google::Wave::Robot::Operation';
class_type 'Google::Wave::Robot::Operation::Queue';

__PACKAGE__->meta->make_immutable;

1;

__END__
