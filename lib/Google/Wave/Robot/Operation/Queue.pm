package Google::Wave::Robot::Operation::Queue;

use 5.010;

use warnings;
use strict;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Operation;

use Clone qw(clone);

my $next_operation_id = 1;

has "capabilities_hash" => (
    is  => "rw",
    isa => "Str"
);

has "_pending" => (
    traits  => ["Array"],
    is      => "rw",
    isa     => "ArrayRef[Google::Wave::Robot::Operation]",
    default => sub { [] },
    handles => {
        push => 'push',
    },
);

has "_proxy_for_id" => (
    is  => "rw",
    isa => "Str",
);

method _new_blipdata ( Str :$wave_id,
                       Str :$wavelet_id, 
                       Str :$initial_content? = '', 
                       Str :$parent_blip_id? ) {
    
    my $blip_id = sprintf q{TBD_%s_0x%08x}, $wavelet_id, int rand 2**32;

    return {
        waveId       => $wave_id,
        wavletId     => $wavelet_id,
        blipId       => $blip_id,
        content      => $initial_content,
        parentBlipId => $parent_blip_id,
    };
}

method _new_waveletdata ( Str :$domain, ArrayRef :$participants ) {
    my $wave_id = sprintf q{%s!TBD_0x%08x}, $domain, int rand 2**32;
    my $wavelet_id = "$domain!conv+root";

    my $blip_data = $self->_new_blipdata(
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
    my $notify = Google::Wave::Robot::Operation->new(
        method => Google::Wave::Robot::Operation::ROBOT_NOTIFY,
        id     => Google::Wave::Robot::Operation::NOTIFY_OP_ID,
        params => {
            capabilitiesHash => $self->capabilities_hash,
            protocolVersion  => Google::Wave::Robot::Operation::PROTOCOL_VERSION,
        },
    );

    return [map { $_->serialize } ($notify, @{$self->_pending})];
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

method wavelet_append_blip () {
}

method wavelet_add_participant () {
}

method wavelet_datadoc_set () {
}

method robot_create_wavelet () {
}

method robot_search () {
}

method robot_fetch_wave () {
}

method wavelet_set_title () {
}

method wavelet_modify_participant_role () {
}

method wavelet_modify_tag () {
}

method blip_create_child () {
}

method blip_delete () {
}

method document_append_markup () {
}

method document_modify () {
}

method document_inline_blip_insert () {
}

__PACKAGE__->meta->make_immutable;

1;

__END__
