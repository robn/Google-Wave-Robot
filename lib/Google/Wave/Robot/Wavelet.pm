package Google::Wave::Robot::Wavelet;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str HashRef ArrayRef Object);
use Google::Wave::Robot::Types qw(Blip OperationQueue);

has "wavelet_id" => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has "wave_id" => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has "creator" => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has "creation_time" => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has "last_modified_time" => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has "title" => (
    is       => "rw",
    isa      => Str,  # XXX hook setter to call set_title and adjust the content
    default  => '',
);

has "operation_queue" => (
    is       => "ro",
    isa      => OperationQueue,
    required => 1,
);

has "robot_address" => (
    is  => "ro",
    isa => Str,  # XXX can't be set if already set
);

has "data_documents" => (
    is  => "ro",
    isa => HashRef[Str],    # XXX key/value pairs, needs some handlers that hook DATADOC_SET
);

has "participants" => (
    is  => "ro",
    isa => ArrayRef[Str],  # XXX list of addresses, needs handlers that hook ADD_PARTICIPANT
                             # XXX seperate objects with roles included? +profiles when that api hits
);

has "root_thread" => (
    is  => "ro",
    isa => Object,  # XXX BlipThread
);

has "tags" => (
    is  => "ro",
    isa => ArrayRef[Str], # XXX list of tags, needs handlers that hook MODIFY_TAG
);

has "root_blip_id" => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has "root_blip" => (
    is       => "ro",
    isa      => Blip,
    # XXX required => 1,
);

method BUILDARGS ( ClassName $class: HashRef :$json, OperationQueue :$operation_queue? ) {
    my $args = {};

    $args->{operation_queue} = $operation_queue || Google::Wave::Robot::Operation::Queue->new;

    my $wavelet_data = $json->{wavelet} || $json->{waveletData} || $json;
    $args->{wavelet_id}         = $wavelet_data->{waveletId};
    $args->{wave_id}            = $wavelet_data->{waveId};
    $args->{creator}            = $wavelet_data->{creator};
    $args->{creation_time}      = $wavelet_data->{creationTime};
    $args->{last_modified_time} = $wavelet_data->{lastModifiedTime};
    $args->{title}              = $wavelet_data->{title} // '';
    $args->{root_blip_id}       = $wavelet_data->{rootBlipId};

    # XXX do blips, threads

    $args->{robot_address} = $json->{robotAddress} if exists $json->{robotAddress};

    return $args;
}

method serialize () {
}

method proxy_for () {
}

method add_proxying_participant () {
}

method submit_with () {
}

method reply () {
}

method delete () {
}

__PACKAGE__->meta->make_immutable;

1;

__END__
