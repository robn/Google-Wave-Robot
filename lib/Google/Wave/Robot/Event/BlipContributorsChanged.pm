package Google::Wave::Robot::Event::BlipContributorsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::ClassAttribute;
use MooseX::Types::Moose qw(Str ArrayRef);
use Google::Wave::Robot::Types qw(Wavelet);

extends ("Google::Wave::Robot::Event");

class_has type => (
    is       => "ro",
    isa      => Str,
    default  => "BLIP_CONTRIBUTORS_CHANGED",
    init_arg => undef,
);

has contributors_added => (
    is  => "ro",
    isa => ArrayRef[Str],
);

has contributors_removed => (
    is  => "ro",
    isa => ArrayRef[Str],
);

method BUILDARGS ( ClassName $class: HashRef :$json, Wavelet :$wavelet ) {
    return {
        contributors_added   => $json->{properties}->{contributorsAdded},
        contributors_removed => $json->{properties}->{contributorsRemoved},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
