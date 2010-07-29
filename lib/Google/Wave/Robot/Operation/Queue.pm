package Google::Wave::Robot::Operation::Queue;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw(Str ArrayRef);
use Google::Wave::Robot::Types qw(Operation);

use Google::Wave::Robot::Operation;

use Clone qw(clone);

my $next_operation_id = 1;

has capabilities_hash => (
    is  => "rw",
    isa => Str,
);

has _pending => (
    traits  => ["Array"],
    is      => "rw",
    isa     => ArrayRef[Operation],
    default => sub { [] },
    handles => {
        push => 'push',
    },
);

has _proxy_for_id => (
    is  => "rw",
    isa => Str,
);

method _new_blip_data ( Str :$wave_id,
                        Str :$wavelet_id, 
                        Str :$initial_content? = '', 
                        Str :$parent_blip_id? ) {
    
    my $blip_id = sprintf q{TBD_%s_0x%08x}, $wavelet_id, int rand 2**32;

    return {
        waveId       => $wave_id,
        waveletId    => $wavelet_id,
        blipId       => $blip_id,
        content      => $initial_content,
        parentBlipId => $parent_blip_id,
    };
}

method _new_wavelet_data ( Str :$domain, ArrayRef :$participants ) {
    my $wave_id = sprintf q{%s!TBD_0x%08x}, $domain, int rand 2**32;
    my $wavelet_id = "$domain!conv+root";

    my $blip_data = $self->_new_blip_data(
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
    );

    my $wavelet_data = {
        waveId       => $wave_id,
        waveletId    => $wavelet_id,
        rootBlipId   => $blip_data->{blipId},
        participants => clone($participants),
    };

    return ($blip_data, $wavelet_data);
}

method serialize ( Str :$method_prefix? = '' ) {
    my @ops = @{$self->_pending};

    if ($self->capabilities_hash) {
        unshift @ops, Google::Wave::Robot::Operation->new(
            method => Google::Wave::Robot::Operation::ROBOT_NOTIFY,
            id     => Google::Wave::Robot::Operation::NOTIFY_OP_ID,
            params => {
                capabilitiesHash => $self->capabilities_hash,
                protocolVersion  => Google::Wave::Robot::Operation::PROTOCOL_VERSION,
            },
        );
    }

    return [map { $_->serialize(method_prefix => $method_prefix) } @ops];
}

method new_operation ( Str :$method, Str :$wave_id?, Str :$wavelet_id?, HashRef :$params? = {}) {
    $params = clone($params);

    $params->{waveId}    = $wave_id    if $wave_id;
    $params->{waveletId} = $wavelet_id if $wavelet_id;

    $params->{proxyingFor} = $self->_proxy_for_id if $self->_proxy_for_id;

    my $operation = Google::Wave::Robot::Operation->new(
        method => $method,
        id     => $next_operation_id++,
        params => $params,
    );
    $self->push($operation);

    return $operation;
}

method wavelet_append_blip ( Str :$wave_id, Str :$wavelet_id, Str :$initial_content? = '' ) {
    my $blip_data = $self->_new_blip_data(
        wave_id         => $wave_id,
        wavelet_id      => $wavelet_id,
        initial_content => $initial_content,
    );

    $self->new_operation(
        method     => Google::Wave::Robot::Operation::WAVELET_APPEND_BLIP,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipData => $blip_data,
        },
    );

    return $blip_data;
}

method wavelet_add_participant ( Str :$wave_id, Str :$wavelet_id, Str :$participant_id ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::WAVELET_ADD_PARTICIPANT,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            participantId => $participant_id,
        },
    );
}

method wavelet_datadoc_set ( Str :$wave_id, Str :$wavelet_id, Str :$name, Str|Undef :$data ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::WAVELET_DATADOC_SET,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            datadocName  => $name,
            datadocValue => $data,
        },
    );
}

method robot_create_wavelet ( Str :$domain, ArrayRef[Str] :$participants? = [], Str :$message? = '' ) {
    my ($blip_data, $wavelet_data) = $self->_new_wavelet_data(domain => $domain, participant => $participants);

    my $params = {
        waveletData => $wavelet_data,
    };
    $params->{message} = $message if $message and $message ne '';

    $self->new_operation(
        method     => Google::Wave::Robot::Operation::ROBOT_CREATE_WAVELET,
        wave_id    => $wavelet_data->{waveId},
        wavelet_id => $wavelet_data->{waveletId},
        params     => $params,
    );

    return ($blip_data, $wavelet_data);
}

method robot_search ( Str :$query, Int :$index?, Int :$num_results? ) {
    my $params = {
        query => $query,
    };
    $params->{index}      = $index if defined $index;
    $params->{numResults} = $num_results if defined $num_results;

    return $self->new_operation(
        method => Google::Wave::Robot::Operation::ROBOT_SEARCH,
        params => $params,
    );
}

method robot_fetch_wave ( Str :$wave_id, Str :$wavelet_id ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::ROBOT_FETCH_WAVE,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
    );
}

method wavelet_set_title ( Str :$wave_id, Str :$wavelet_id, Str :$title ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::WAVELET_SET_TITLE,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            waveletTitle => $title,
        },
    );
}

method wavelet_modify_participant_role ( Str :$wave_id, Str :$wavelet_id, Str :$participant_id, Str :$role ) {
    # XXX what type should $role have?
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::WAVELET_MODIFY_PARTICIPANT_ROLE,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            participantId   => $participant_id,
            participantRole => $role,
        },
    );
}

method wavelet_modify_tag ( Str :$wave_id, Str :$wavelet_id, Str :$tag, Str :$modify_how = 'add' ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::WAVELET_MODIFY_TAG,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            name      => $tag,
            modifyHow => $modify_how,
        },
    );
}

method blip_continue_thread ( Str :$wave_id, Str :$wavelet_id, Str :$blip_id ) {
    my $blip_data = $self->_new_blip_data(
        wave_id        => $wave_id,
        wavelet_id     => $wavelet_id,
        parent_blip_id => $blip_id,
    );

    $self->new_operation(
        method     => Google::Wave::Robot::Operation::BLIP_CONTINUE_THREAD,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipId   => $blip_id,
            blipData => $blip_data,
        },
    );

    return $blip_data;
}

method blip_create_child ( Str :$wave_id, Str :$wavelet_id, Str :$blip_id ) {
    my $blip_data = $self->_new_blip_data(
        wave_id        => $wave_id,
        wavelet_id     => $wavelet_id,
        parent_blip_id => $blip_id,
    );

    $self->new_operation(
        method     => Google::Wave::Robot::Operation::BLIP_CREATE_CHILD,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipId   => $blip_id,
            blipData => $blip_data,
        },
    );

    return $blip_data;
}

method blip_delete ( Str :$wave_id, Str :$wavelet_id, Str :$blip_id ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::BLIP_DELETE,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipId => $blip_id,
        },
    );
}

method document_append_markup ( Str :$wave_id, Str :$wavelet_id, Str :$blip_id, Str :$content ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::DOCUMENT_APPEND_MARKUP,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipId  => $blip_id,
            content => $content,
        },
    );
}

method document_modify ( Str :$wave_id, Str :$wavelet_id, Str :$blip_id ) {
    return $self->new_operation(
        method     => Google::Wave::Robot::Operation::DOCUMENT_MODIFY,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipId => $blip_id,
        },
    );
}

method document_inline_blip_insert ( Str :$wave_id, Str :$wavelet_id, Str :$blip_id, Int :$position ) {
    my $blip_data = $self->_new_blip_data(
        wave_id        => $wave_id,
        wavelet_id     => $wavelet_id,
        parent_blip_id => $blip_id,
    );

    $self->new_operation(
        method     => Google::Wave::Robot::Operation::DOCUMENT_INLINE_BLIP_INSERT,
        wave_id    => $wave_id,
        wavelet_id => $wavelet_id,
        params     => {
            blipId   => $blip_id,
            index    => $position,
            blipData => $blip_data,
        },
    );

    return $blip_data;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
