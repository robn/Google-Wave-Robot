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
        when (m{/_wave/verify_token$}) {
            return $class->verify_token_handler($robot, $env);
        }
    }

    return $class->unknown_handler;
}

method capabilities_handler ( ClassName $class: Robot $robot, HashRef $env ) {
    return [ 200, [ 'Content-type' => 'text/xml', Pragma => 'no-cache' ], [ $robot->capabilities_xml ] ];
}

method profile_handler ( ClassName $class: Robot $robot, HashRef $env ) {
    return [ 200, [ 'Content-type' => 'application/json', Pragma => 'no-cache' ], [ $robot->profile_json ] ];
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
}

method unknown_handler ( ClassName $class: ) {
    my $status = 404;
    my $headers = [
        'Content-Type' => 'text/plain',
    ];
    my $body = [ 'not found' ];

    return [ $status, $headers, $body ];
}

__PACKAGE__->meta->make_immutable;

1;

__END__
