package Google::Wave::Robot::Event::GadgetStateChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str);
use Google::Wave::Robot::Types qw(Wavelet);

extends ("Google::Wave::Robot::Event");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "GADGET_STATE_CHANGED",
    init_arg => undef,
);

has index => (
    is  => "ro",
    isa => Str,
);

has old_state => (
    is  => "ro",
    isa => Str,
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    my $args = $class->SUPER::BUILDARGS(json => $json, wavelet => $wavelet);

    $args->{index}     = $json->{properties}->{index};
    $args->{old_state} = $json->{properties}->{oldState};

    return $args;
}

#__PACKAGE__->meta->make_immutable;

1;

__END__
