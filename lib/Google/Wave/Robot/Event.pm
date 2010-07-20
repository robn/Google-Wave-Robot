package Google::Wave::Robot::Event;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use Moose::Util::TypeConstraints;
use MooseX::Types::JSON qw(JSON);

BEGIN {
    class_type 'Google::Wave::Robot::Wavelet';
}

has "json" => (
    is  => "ro",
    isa => "Str",
);

has "type" => (
    is  => "ro",
    isa => "Str",
};

has "modified_by" => (
    is  => "ro",
    isa => "Str",
);

has "timestamp" => (
    is  => "ro",
    isa => "Int",
);

has "proxying_for" => (
    is  => "ro",
    isa => "Str",
);

has "properties" => (
    is  => "ro",
    isa => "HashRef",
);

has "blip_id" => (
    is  => "ro",
    isa => "Str",
);

has "blip" => (
    is  => "ro",
    isa => "Google::Wave::Robot::Blip",
);

method BUILDARGS ( ClassName $class: JSON :$json, Google::Wave::Robot::Wavelet :$wavelet ) {
    my $args = {
        json         => $json,
        type         => $json->{type},
        modified_by  => $json->{modifiedBy},
        timestamp    => $json->{timestamp} // 0,
        proxying_for => $json->{proxyingFor},
    };

    $args->{properties} = $json->{properties} // {},

    $args->{blip_id} = $args->{properties}->{blipId} if exists $args->{properties}->{blip_id};
    $args->{blip} = $wavelet->blip($args->{blip_id}) if exists $args->{blip_id};

    return $args;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
