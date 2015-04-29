package Stylus::Controller::Register;
use Moose;
use namespace::autoclean;

use Crypt::PBKDF2;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'stylus/register');

=head1 NAME

Stylus::Controller::Contact - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'register.tt';
	$c->stash->{righthalf} = 'registerright.tt';
}

### all general methods come after this ###

=head2 create

register a 'new' user

=cut

sub process :Local {
    my ( $self, $c ) = @_;

    $c->log->debug('Register - register process ....');

    my $name     = $c->request->params->{name};
    my $email    = $c->request->params->{email};
    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};
    my $domain   = $c->request->params->{domain};

    # set view ...
    $c->stash->{current_view} = 'JSON_Service';

    # check whether username / domain already exist
    my $user_rs = $c->model('DB::User')->search({
        username => $username,
    });
    if ( $user_rs->count ) {
        $c->stash->{json} = {
            success => 0,
            message => 'This Username already exists within Stylus.'
        };
        return;
    }

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

    # add user to the 'users' table
    my $error = 0;
    my ( $user_data, $domain_data, $user_domain_data );
    try {
        $user_data = $c->model('DB::User')->create({
            name          => $name,
            email_address => $email,
            username      => $username,
            password      => $password_hash,
        });
        $domain_data = $c->model('DB::Domain')->create({
            name => $domain,
        });
        $user_domain_data = $c->model('DB::UserDomain')->create({
            uid       => $user_data->id,
            domain_id => $domain_data->id,
        });

    }
    catch {
        $c->log->debug('Register - create of new user data failed : ' . $_);
        $error = 1;
    };
    if ( $error ) {
        $c->stash->{json} = {
            success => 0,
            message => 'Register - create of new user data failed.'
        };

        return;
    }

    # set session variables ...
    $c->session->{user_domain_id} = $domain_data->id;
    $c->session->{user_domain}    = $domain_data->name;

    $c->stash->{json} = {
        success => 1
    };

    return;
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
