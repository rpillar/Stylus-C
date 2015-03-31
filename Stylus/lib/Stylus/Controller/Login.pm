package Stylus::Controller::Login;
use Moose;
use namespace::autoclean;

use Crypt::PBKDF2;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'stylus/login');

=head1 NAME

Stylus::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

use Data::Dumper;

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'login.tt';
	$c->stash->{righthalf} = 'loginright.tt';

	# initial message
	$c->stash->{message} = 'Login using a valid Username / Password';
}

=head2 auth

=cut

sub auth :Local {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};

    $c->stash->{current_view} = 'JSON_Service';

    # encrypt the password
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
        salt_len => 10,
    );
    my $password_hash = $pbkdf2->generate($password, $username);

    unless ( $c->authenticate({ username => $username, password => $password_hash, })) {
        $c->stash->{json} = {
            success => 0,
        };
    }
    else {
        $c->stash->{json} = {
            success => 1,
        };
    }
}

sub check_domain :Local {
    my ( $self, $c ) = @_;

    my $domain_name = $c->request->params->{domain};

    $c->stash->{current_view} = 'JSON_Service';
    $c->log->debug( 'Logged in user : ' . $c->user->username );

    # check that domain is associated with this user ...
    my $domain = $c->model('DB::Domain')->find({
        name => $domain_name,
    });
    if ( !$domain || $domain->user->uid != $c->user->id ) {
        $c->stash->{json} = {
            success => 0,
            message => 'Stylus - this domain does not belong to user.',
        }
    }
    else {
        $c->session->{user_domain} = $domain;
        $c->stash->{json} =  {
            success => 1
        }
    }
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Richard Pillar,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
