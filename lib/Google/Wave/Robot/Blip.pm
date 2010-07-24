package Google::Wave::Robot::Blip;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str HashRef ArrayRef);
use Google::Wave::Robot::Types qw(OperationQueue Blip);

has blip_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has wavelet_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has wave_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has parent_blip_id => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has child_blip_ids => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has creator => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has contributors => (
    is       => "ro",
    isa      => ArrayRef[Str],
    required => 1,
);

has last_modified_time => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has version => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has text => (
    is       => "ro",
    isa      => Str,
    required => 1,
);

has annotations => (
    is       => "ro",
    isa      => ArrayRef,   # XXX ArrayRef[Annotation]
);

has elements => (
    is       => "ro",
    isa      => ArrayRef,   # XXX ArrayRef[Elements]
);

method BUILDARGS ( ClassName $class: HashRef :$json, OperationQueue :$operation_queue?, ArrayRef[Blip] :$other_blips )
{
    my $args = {};

    $args->{operation_queue} = $operation_queue || Google::Wave::Robot::Operation::Queue->new;

    $args->{blip_id}            = $json->{blipId};
    $args->{wavelet_id}         = $json->{waveletId};
    $args->{wave_id}            = $json->{waveId};
    $args->{parent_blip_id}     = $json->{parentBlipId};
    $args->{child_blip_ids}     = $json->{childBlipIds};
    $args->{creator}            = $json->{creator};
    $args->{contributors}       = $json->{contributors};
    $args->{last_modified_time} = $json->{lastModifiedTime};
    $args->{version}            = $json->{version};
    $args->{text}               = $json->{content};

    # XXX annotations, elements
    
    return $args;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
