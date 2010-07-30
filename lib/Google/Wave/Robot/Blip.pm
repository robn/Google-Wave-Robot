package Google::Wave::Robot::Blip;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str Int HashRef ArrayRef);
use Google::Wave::Robot::Types qw(Blip BlipSet OperationQueue);

use Google::Wave::Robot::Blip::Set;
use Google::Wave::Robot::Operation::Queue;

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
    is      => "ro",
    isa     => Str,
    default => '',
);

has child_blip_ids => (
    is      => "ro",
    isa     => ArrayRef[Str],
    default => sub { [] },
);

has creator => (
    is      => "ro",
    isa     => Str,
    default => '',
);

has _contributors => (
    traits   => [ "Array" ],
    is       => "ro",
    isa      => ArrayRef[Str],
    default  => sub { [] },
    init_arg => "contributors",
    handles  => {
        contributors => 'elements',
    },
);

has last_modified_time => (
    is      => "ro",
    isa     => Int,
    default => 0,
);

has version => (
    is      => "ro",
    isa     => Int,
    default => 0,
);

has content => (
    is       => "ro",
    isa      => Str,
    writer   => "_set_content",
    default  => '',
);

has operation_queue => (
    is      => "ro",
    isa     => OperationQueue,
    default => sub { Google::Wave::Robot::Operation::Queue->new },
);

=pod
has annotations => (
    is  => "ro",
    isa => ArrayRef,   # XXX ArrayRef[Annotation]
);

has elements => (
    is       => "ro",
    isa      => ArrayRef,   # XXX ArrayRef[Elements]
);
=cut

has _other_blips => (
    is      => "ro",
    isa     => BlipSet,
    default => sub { Google::Wave::Robot::Blip::Set->new },
    lazy    => 1,
);

method new_from_json ( ClassName $class: HashRef $json, OperationQueue :$operation_queue?, BlipSet :$other_blips? )
{
    my %args = (
        blip_id    => $json->{blipId},
        wavelet_id => $json->{waveletId},
        wave_id    => $json->{waveId},
    );

    $args{operation_queue} = $operation_queue if $operation_queue;
    $args{_other_blips}    = $other_blips if $other_blips;

    $args{parent_blip_id}     = $json->{parentBlipId}     if defined $json->{parentBlipId};
    $args{child_blip_ids}     = $json->{childBlipIds}     if defined $json->{childBlipIds};
    $args{creator}            = $json->{creator}          if defined $json->{creator};
    $args{content}            = $json->{content}          if defined $json->{content};
    $args{contributors}       = $json->{contributors}     if defined $json->{contributors};
    $args{last_modified_time} = $json->{lastModifiedTime} if defined $json->{lastModifiedTime};
    $args{version}            = $json->{version}          if defined $json->{version};

    # XXX annotations, elements
    
    my $blip = $class->new(%args);
    
    return $blip;
}

method reply () {
    my $blip_data = $self->operation_queue->blip_create_child(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        blip_id    => $self->blip_id,
    );
    my $blip = Google::Wave::Robot::Blip->new(
        json            => $blip_data,
        operation_queue => $self->operation_queue,
        other_blips     => $self->_other_blips,
    );
    $self->_other_blips->add($blip->blip_id, $blip);
}

method append_markup ( Str $markup ) {
    # XXX markup = util.force_unicode(markup)

    $self->operation_queue->document_append_markup(
        wave_id    => $self->wave_id,
        wavelet_id => $self->wavelet_id,
        blip_id    => $self->blip_id,
        content    => $markup,
    );

    $self->_set_content($self->content.$markup);
}

__PACKAGE__->meta->make_immutable;

1;

__END__
