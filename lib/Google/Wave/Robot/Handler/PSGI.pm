package Google::Wave::Robot::Handler::PSGI;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use Google::Wave::Robot::Types;

method run ( ClassName $class: Google::Wave::Robot $robot, HashRef $env ) {
    given ($env->{REQUEST_URI}) {
        when (m{/_wave/capabilities.xml$}) {
            return $class->capabilities_handler($robot);
        }
        when (m{/_wave/robot/profile$}) {
            return $class->profiles_handler($robot);
        }
        when (m{/_wave/robot/jsonrpc$}) {
            return $class->rpc_handler($robot);
        }
        when (m{/_wave/verify_token$}) {
            return $class->verify_token_handler($robot);
        }
    }

    return $class->unknown_handler;
}

method capabilities_handler ( ClassName $class: Google::Wave::Robot $robot ) {
}

method profiles_handler ( ClassName $class: Google::Wave::Robot $robot ) {
}

method rpc_handler ( ClassName $class: Google::Wave::Robot $robot ) {
}

method verify_token_handler ( ClassName $class: Google::Wave::Robot $robot ) {
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
