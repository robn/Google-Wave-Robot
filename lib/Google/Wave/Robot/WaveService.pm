package Google::Wave::Robot::WaveService;

use 5.010;

use warnings;
use strict;

use Params::Validate qw(validate :types);
use LWP::UserAgent;
use Net::OAuth 0.25;
use JSON qw(encode_json decode_json);
use Carp qw(croak);

use URI::Escape;
use Data::Random qw(rand_chars);
use Carp;

use constant REQUEST_TOKEN_URL => q{https://www.google.com/accounts/OAuthGetRequestToken};
use constant ACCESS_TOKEN_URL  => q{https://www.google.com/accounts/OAuthGetAccessToken};
use constant AUTHORIZATION_URL => q{https://www.google.com/accounts/OAuthAuthorizeToken};

use constant SCOPE             => q{http://wave.googleusercontent.com/api/rpc};

use constant RPC_URL           => q{https://www-opensocial.googleusercontent.com/api/rpc};
use constant SANDBOX_RPC_URL   => q{https://www-opensocial-sandbox.googleusercontent.com/api/rpc};

sub new {
    my $class = shift;

    my %args = validate(@_, {
        use_sandbox     => { type => BOOLEAN, default => 0           },
        server_rpc_base => { type => SCALAR,  default => undef       },
        consumer_key    => { type => SCALAR,  default => "anonymous" },
        consumer_secret => { type => SCALAR,  default => "anonymous" },
        http_post       => { type => CODEREF, default => undef       },
    });

    my $self = {};

    $self->{_server_rpc_base} = $args{server_rpc_base} ? $args{server_rpc_base} :
                                $args{use_sandbox}     ? SANDBOX_RPC_URL        :
                                                         RPC_URL;

    $self->{_consumer_key}    = $args{consumer_key};
    $self->{_consumer_secret} = $args{consumer_secret};

    $self->{_http_post} = $args{http_post} // \&http_post;

    $self->{_ua} = LWP::UserAgent->new;

    return bless $self, $class;
}

sub _make_token {
}

sub set_http_post {
    my $self = shift;

    my %args = validate(@_, {
        http_post => CODEREF,
    });

    $self->{_http_post} = $args{http_post};
}

sub get_token_from_request {
}

sub fetch_request_token {
}

sub generate_authorization_url {
}

sub upgrade_to_access_token {
}

sub set_access_token {
    my $self = shift;

    my %args = validate(@_, {
        token  => "SCALAR",
        secret => "SCALAR",
    });

    $self->{_access_token}        = $args{token};
    $self->{_access_token_secret} = $args{secret};
}

sub http_post {
    my $self = shift;

    my %args = validate(@_, {
        url     => { type => SCALAR },
        data    => { type => SCALAR },
        headers => { type => HASHREF, default => {} },
    });

    my $url = $args{url};
    while (1) {
        my $res = $self->{_ua}->post($url, %{$args{headers}}, Content => $args{data});

        if (! $res->is_redirect) {
            return [ $res->code, $res->content ];
        }

        $url = $res->header("Location");
    }

    # we don't get here
}

sub make_rpc {
    my $self = shift;

    my %args = validate(@_, {
        operations => {
            callbacks => {
                'Operation, list of Operations or Operation::Queue' => sub {
                    my $value = shift;
                    return 0 if !$value;
                    return 1 if ref $value eq q{Google::Wave::Robot::Operation};
                    return 1 if ref $value eq q{Google::Wave::Robot::Operation::Queue};
                    return 0 if ref $value ne "ARRAY";
                    return 0 if grep { ref $_ ne q{Google::Wave::Robot::Operation} } @$value;
                    return 1;
                },
            },
        },
    });

    my $queue;
    given (ref $args{operations}) {
        when (q{Google::Wave::Robot::Operation::Queue}) {
            $queue = $args{operations};
        }
        when (q{Google::Wave::Robot::Operation}) {
            $args{operations} = [$args{operations}];
            continue;
        }
        default {
            $queue = Google::Wave::Robot::Operation::Queue->new;
            $queue->copy_operations($args{operations});
        }
    }

    my $data = encode_json($queue->serialize({ method_prefix => 'wave' }));

    my $oauth_req = Net::OAuth->request("protected resource")->new(
        $self->_default_request_params("POST"),
        request_url  => $self->{_server_rpc_base},
        token        => $self->{_access_token},
        token_secret => $self->{_access_token_secret},
    );
    $oauth_req->sign;

    my $headers = {
        "Content-Type"  => "application/json",
        "Authorization" => $oauth_req->to_authorization_header,
    };

    my ($status, $content) = $self->{_http_post}->($self, {
        url     => $self->{_server_rpc_base},
        data    => $data,
        headers => $headers,
    });

    croak "rpc error: $status\n$content" if $status != 200;   # XXX Error::RpcError

    return decode_json($content);
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
