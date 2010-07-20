package Google::Wave::Robot::Event::BlipContributorsChanged;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

extends ("Google::Wave::Robot::Event");

use constant name => "BLIP_CONTRIBUTORS_CHANGED";

has "contributors_added" => (
    is  => "ro",
    isa => "ArrayRef[Str]",
);

has "contributors_removed" => (
    is  => "ro",
    isa => "ArrayRef[Str]",
);

method BUILDARGS ( ClassName $class: HashRef :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    return {
        contributors_added   => $json->{properties}->{contributorsAdded},
        contributors_removed => $json->{properties}->{contributorsRemoved},
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
