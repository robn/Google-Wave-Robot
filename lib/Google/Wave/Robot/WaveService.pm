package Google::Wave::Robot::WaveService;

use 5.010;

use warnings;
use strict;

use Params::Validate qw(validate :types);
use LWP::UserAgent;
use Net::OAuth 0.25;

use URI::Escape;
use Data::Random qw(rand_chars);
use JSON qw(encode_json decode_json);
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

    $self->{_http_post} = $args{http_post};

    $self->{_connection} = LWP::UserAgent->new;

    return bless $self, $class;
}

sub _make_token {
}

sub _set_http_post {
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
}

sub http_post {
}

sub make_rpc {
}

sub _first_rpc_result {
}

sub _wavelet_from_json {
}

sub search {
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
