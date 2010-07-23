package Google::Wave::Robot::Wavelet;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str HashRef ArrayRef Object);
use Google::Wave::Robot::Types qw(Blip OperationQueue);

has "wavelet_id" => (
    "is"  => "ro",
    "isa" => Str,
);

has "wave_id" => (
    "is"  => "ro",
    "isa" => Str,
);

has "creator" => (
    "is"  => "ro",
    "isa" => Str,
);

has "creation_time" => (
    "is"  => "ro",
    "isa" => Str,
);

has "data_documents" => (
    "is"  => "ro",
    "isa" => HashRef[Str],    # XXX key/value pairs, needs some handlers that hook DATADOC_SET
);

has "last_modified_time" => (
    "is"  => "ro",
    "isa" => Str,
);

has "participants" => (
    "is"  => "ro",
    "isa" => ArrayRef[Str],  # XXX list of addresses, needs handlers that hook ADD_PARTICIPANT
                             # XXX seperate objects with roles included? +profiles when that api hits
);

has "root_thread" => (
    "is"  => "ro",
    "isa" => Object,  # XXX BlipThread
);

has "tags" => (
    "is"  => "ro",
    "isa" => ArrayRef[Str], # list of tags, needs handlers that hook MODIFY_TAG
);

has "title" => (
    "is"  => "rw",
    "isa" => Str,  # XXX hook setter to call set_title and adjust the content
);

has "robot_address" => (
    "is"  => "ro",
    "isa" => Str,  # XXX can't be set if already set
);

has "root_blip" => (
    "is"  => "ro",
    "isa" => Blip,
);

has "operation_queue" => (
    "is"  => "ro",
    "isa" => OperationQueue,
);

method new_from_json ( HashRef :$json, OperationQueue :$operation_queue ) {
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
