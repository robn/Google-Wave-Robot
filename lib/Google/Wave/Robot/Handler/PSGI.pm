package Google::Wave::Robot::Handler::PSGI;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;
use Google::Wave::Robot::Types qw(Robot);

method run ( ClassName $class: Robot $robot, HashRef $env ) {
    given ($env->{REQUEST_URI}) {
        when (m{/_wave/capabilities.xml$}) {
            return $class->capabilities_handler($robot, $env);
        }
        when (m{/_wave/robot/profile$}) {
            return $class->profile_handler($robot, $env);
        }
        when (m{/_wave/robot/jsonrpc$}) {
            return $class->rpc_handler($robot, $env);
        }
        when (m{/_wave/verify_token(?:\?st=\d+)?$}) {
            return $class->verify_token_handler($robot, $env);
        }
    }

    return $class->unknown_handler;
}

method capabilities_handler ( ClassName $class: Robot $robot, HashRef $env ) {
    return $class->_output(200, 'text/xml', $robot->capabilities_xml);
}

method profile_handler ( ClassName $class: Robot $robot, HashRef $env ) {
    return $class->_output(200, 'application/json', $robot->profile_json);
}

method rpc_handler ( ClassName $class: Robot $robot, HashRef $env ) {
    my $json = '';
    while ($env->{'psgi.input'}->read(my $buf, 4096)) {
        $json .= $buf;
    };

    $robot->process_events($json);

    # XXX send the response
}

method verify_token_handler ( ClassName $class: Robot $robot, HashRef $env ) {
    my ($st) = $env->{QUERY_STRING} =~ m/st=(\d+)/;
    if ($st && $robot->security_token && $robot->security_token ne $st) {
        return $class->_output(401, 'text/plain', q{security token doesn't match});
    }

    if (!($robot->verification_token)) {
        return $class->_output(404, 'text/plain', q{verification token not available});
    }

    return $class->_output(200, 'text/plain', $robot->verification_token);
}

method unknown_handler ( ClassName $class: ) {
    return $class->_output(404, 'text/plain', q{not found});
}

method _output ( ClassName $class: Int $status, Str $content_type, Str $content ) {
    return [
        $status,
        [
            'Content-type' => $content_type,
            Pragma         => 'no-cache',
        ],
        [ $content ],
    ];
}

__PACKAGE__->meta->make_immutable;

1;

__END__
