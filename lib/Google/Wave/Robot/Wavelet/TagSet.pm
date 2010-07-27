package Google::Wave::Robot::Wavelet::TagSet;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(HashRef Bool Str);
use Google::Wave::Robot::Types qw(OperationQueue);

use Google::Wave::Robot::Operation::Queue;

has _tags => (
    traits  => [ "Hash" ],
    is      => "ro",
    isa     => HashRef[Str],
    default => sub { {} },
    handles => {
        exists  => 'exists',
        tags    => 'keys',
        _set    => 'set',
        _delete => 'delete',
        get     => 'get',
    },
);

has wave_id => (
    is  => "ro",
    isa => Str,
);

has wavelet_id => (
    is  => "ro",
    isa => Str,
);

method standalone () {
    return !($self->wave_id && $self->wavelet_id);
}

has operation_queue => (
    is      => "ro",
    isa     => OperationQueue,
    default => sub { Google::Wave::Robot::Operation::Queue->new },
);

method add ( Str $tag ) {
    return if $self->exists($tag);
    $self->_set($tag => 1);

    if (!$self->standalone) {
        $self->operation_queue->wavelet_modify_tag(
            wave_id    => $self->wave_id, 
            wavelet_id => $self->wavelet_id, 
            tag        => $tag,
            modify_how => "add",
        );
    }
}

method remove ( Str $tag ) {
    return if !$self->exists($tag);
    $self->_delete($tag);

    if (!$self->standalone) {
        $self->operation_queue->wavelet_modify_tag(
            wave_id    => $self->wave_id, 
            wavelet_id => $self->wavelet_id, 
            tag        => $tag,
            modify_how => "remove",
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
