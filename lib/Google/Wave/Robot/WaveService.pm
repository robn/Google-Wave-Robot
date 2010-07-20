package Google::Wave::Robot::WaveService;

use 5.010;

use namespace::autoclean;

use Moose;
use MooseX::Method::Signatures;

use MooseX::Types::LWP::UserAgent qw(UserAgent);
use Google::Wave::Robot::Types;

use LWP::UserAgent;
use Net::OAuth 0.25;
use Clone qw(clone);
use JSON qw(encode_json decode_json);
use Data::Random qw(rand_chars);

use Carp;

use constant {
    REQUEST_TOKEN_URL => q{https://www.google.com/accounts/OAuthGetRequestToken},
    ACCESS_TOKEN_URL  => q{https://www.google.com/accounts/OAuthGetAccessToken},
    AUTHORIZATION_URL => q{https://www.google.com/accounts/OAuthAuthorizeToken},

    SCOPE             => q{http://wave.googleusercontent.com/api/rpc},

    RPC_URL           => q{https://www-opensocial.googleusercontent.com/api/rpc},
    SANDBOX_RPC_URL   => q{https://www-opensocial-sandbox.googleusercontent.com/api/rpc},
};

has "ua" => (
    is     => "rw",
    isa    => UserAgent,
    coerce => 1,
);

has "_server_rpc_base" => (
    is  => "rw",
    isa => "Str",
);

has "_consumer_key" => (
    is  => "rw",
    isa => "Str",
);

has "_consumer_secret" => (
    is  => "rw",
    isa => "Str",
);

has "_access_token" => (
    is  => "rw",
    isa => "Str",
);

has "_access_token_secret" => (
    is  => "rw",
    isa => "Str",
);

method BUILDARGS ( ClassName $class:
                   Bool      :$use_sandbox?, 
                   Str       :$server_rpc_base?, 
                   Str       :$consumer_key? = "anonymous", 
                   Str       :$consumer_secret? = "anonymous",
                   UserAgent :$ua? ) {

    return {
        _server_rpc_base => $server_rpc_base ? $server_rpc_base :
                            $use_sandbox     ? SANDBOX_RPC_URL  :
                                               RPC_URL,

        _consumer_key    => $consumer_key,
        _consumer_secret => $consumer_secret,

        ua               => $ua // [],
    };
}

method post_operation_queue ( Google::Wave::Robot::Operation::Queue $queue ) {
    my $data = encode_json($queue->serialize(method_prefix => 'wave'));

    my $oauth_req;
    if ($self->_access_token) {
        $oauth_req = Net::OAuth->request("protected resource")->new(
            $self->_default_request_params("POST"),
            request_url  => $self->_server_rpc_base,
            token        => $self->_access_token,
            token_secret => $self->_access_token_secret,
        );
    }
    else {
        $oauth_req = Net::OAuth->request("consumer")->new(
            $self->_default_request_params("POST"),
            request_url     => $self->_server_rpc_base,
        );
    }
    $oauth_req->sign;

    my $headers = {
        "Content-Type"  => "application/json",
        "Authorization" => $oauth_req->to_authorization_header,
    };

    my $url = $self->_server_rpc_base;
    my $res;
    while (!$res) {
        $res = $self->ua->post($url, %{$headers}, Content => $data);

        if ($res->is_redirect) {
            $url = $res->header("Location");
            next;
        }
    }

    my $status = $res->code;
    croak "rpc error: ".$res->status_line."\n".$res->content if $status != 200;

    return ($status, decode_json($res->content), $res);
}

method _default_request_params ( Str $method? = 'GET' ) {
    return (
        protocol_version => $Net::OAuth::PROTOCOL_VERSION_1_0A,
        consumer_key     => $self->_consumer_key,
        consumer_secret  => $self->_consumer_secret,
        request_method   => $method,
        signature_method => "HMAC-SHA1",
        timestamp        => time,
        nonce            => join('', rand_chars(size => 16, set => "alphanumeric"))
    );
}

1;

__END__

=pod
sub _make_token {
}

sub get_token_from_request {
}

sub fetch_request_token {
}

sub generate_authorization_url {
}

sub upgrade_to_access_token {
}
=cut

method do_http_post ( Str :$url, Str :$data, HashRef :$headers? = {} ) {
    while (1) {
        my $res = $self->{_ua}->post($url, %{$headers}, Content => $data);

        if (! $res->is_redirect) {
            return ($res->code, $res->content);
        }

        $url = $res->header("Location");
    }

    # we don't get here
}

method make_rpc ( Google::Wave::Robot::Operation::Queue :$queue )
{
}

around "make_rpc" => sub {
    my $orig = shift;
    my $self = shift;
    my %args = @_;

    if ($args{queue}) {
        if (ref $args{queue} eq "Google::Wave::Robot::Operation") {
            $args{queue} = [$args{queue}];
        }

        if (ref $args{queue} eq "ARRAY") {
            confess
    }

    return $self->$orig(%args);
};

1;

__END__

sub _first_rpc_result {
    my ($self, $result) = @_;

    my ($first) = grep { $_->{id} ne Google::Wave::Operation::NOTIFY_OP_ID } values %$result;
    croak "rpc error: no results found" if ! $first;    # XXX Error::RpcError

    my $error = $first->{error};
    croak "rpc error: $error->{code}: $error->{message}" if $error;     # XXX Error::RpcError

    croak "rpc error: no data record" if ! $first->{data};

    return $first->{data};
}

sub _wavelet_from_json {
}

sub search {
    my $self = shift;

    my %args = validate(@_, {
        query       => "SCALAR",
        index       => { type => "SCALAR", default => undef },
        num_results => { type => "SCALAR", default => undef },
    });

    my $queue = Google::Wave::Operation::Queue->new;
    $queue->robot_search(\%args);
    my $result = $self->_first_rpc_result($self->make_rpc($queue));
    return Google::Wave::Search::Results($result);
}

sub new_wave {
}

sub fetch_wavelet {
}

sub blind_wavelet {
}

sub submit {
}

1;

__END__

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(consumer_key consumer_secret use_sandbox));

my $oa_scope = q{http://wave.googleusercontent.com/api/rpc};

my $oa_req_uri    = q{https://www.google.com/accounts/OAuthGetRequestToken?scope=}.uri_escape($oa_scope);
my $oa_auth_uri   = q{https://www.google.com/accounts/OAuthAuthorizeToken};
my $oa_access_uri = q{https://www.google.com/accounts/OAuthGetAccessToken};

my $wave_rpc_uri         = q{https://www-opensocial.googleusercontent.com/api/rpc};
my $wave_sandbox_rpc_uri = q{https://www-opensocial-sandbox.googleusercontent.com/api/rpc};

sub get_login_uri {
    my ($self, $callback) = @_;

    my $oa_req = Net::OAuth->request("request token")->new(
        $self->_default_request_params,
        request_url  => $oa_req_uri,
        callback     => $callback,
        extra_params => {
            scope => $oa_scope,
        },
    );
    $oa_req->sign;

    my $ua = LWP::UserAgent->new;
    my $res = $ua->get($oa_req->to_url);
    if (!$res->is_success) {
        croak "could not get request token: ".$res->status_line."\n".$res->content;
    }

    my $oa_res = Net::OAuth->response("request token")->from_post_body($res->content);

    $oa_req = Net::OAuth->request("user auth")->new(
        token    => $oa_res->token,
    );

    return ($oa_req->to_url($oa_auth_uri), $oa_res->token_secret);
}

sub handle_callback {
    my ($self, $token_secret, $callback_args) = @_;

    my $oa_res = Net::OAuth->response("user auth")->from_hash($callback_args);

    my $oa_req = Net::OAuth->request("access token")->new(
        $self->_default_request_params(),
        request_url  => $oa_access_uri,
        verifier     => $oa_res->verifier,
        token        => $oa_res->token,
        token_secret => $token_secret,
    );
    $oa_req->sign;

    my $ua = LWP::UserAgent->new;
    my $res = $ua->get($oa_req->to_url);
    if (!$res->is_success) {
        croak "could not get request token: ".$res->status_line."\n".$res->content;
    }

    $oa_res = Net::OAuth->response("access_token")->from_post_body($res->content);

    return ($oa_res->token, $oa_res->token_secret);
}

sub rpc_call {
    my ($self, $token, $token_secret, $rpc) = @_;

    my $oa_req = Net::OAuth->request("protected resource")->new(
        $self->_default_request_params("POST"),
        request_url  => $self->use_sandbox ? $wave_sandbox_rpc_uri : $wave_rpc_uri,
        token        => $token,
        token_secret => $token_secret,
    );
    $oa_req->sign;  
    
    my $ua = LWP::UserAgent->new;
    $ua->default_header(Authorization => $oa_req->to_authorization_header);
    my $res = $ua->post($oa_req->request_url, Content_type => "application/json", Content => encode_json($rpc));

    if (!$res->is_success) {
        croak "could not do rpc call: ".$res->status_line."\n".$res->content;
    }
    
    my $data = decode_json($res->content);
        
    return $data;
}
        
sub _default_request_params {
    my ($self, $method) = @_;
    $method //= "GET";

    return (
        protocol_version => $Net::OAuth::PROTOCOL_VERSION_1_0A,
        consumer_key     => $self->consumer_key,
        consumer_secret  => $self->consumer_secret,
        request_method   => $method,
        signature_method => "HMAC-SHA1",
        timestamp        => time,
        nonce            => join('', rand_chars(size => 16, set => "alphanumeric"))
    );
}

1;
