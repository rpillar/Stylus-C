package Stylus::Controller::Register;
use Moose;
use namespace::autoclean;

use Crypt::PBKDF2;

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

    # encrypt the password
    my $pbkdf2 = Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
        salt_len => 10,
    );
    my $password_hash = $pbkdf2->generate($password);

    $c->stash->{current_view} = 'JSON_Service';

    # add user to the 'users' table
    my $error = 0;
    my $user_data;
    try {
        $user_data = $c->model('DB::Users')->create({
            name          => $name,
            email_address => $email,
            username      => $username,
            password      => $password_hash,
        });
    }
    catch {
        $c->log->debug('Register - create of new user data failed : ' . $_);
        $error = 1;
    };
    if ( $error ) {
        $c->stash->{json} = {
            success => 0,
            message => 'Register - create of new user data failed'
        };

        return;
    }

    # add the domain to the 'domain' table and to the 'user_domains' table
    my $domain_data;
    try {
        $domain_data = $c->model('DB::Domain')->create({
            domain => $domain
        });
    }
    catch {
        $c->log->debug('Register - create of new domain data failed : ' . $_);
        $error = 1;
    };
    if ( $error ) {
        $c->stash->{json} = {
            success => 0,
            message => 'Register - create of new domain data failed'
        };

        return;
    }

    my $user_domain_data;
    try {
        $user_domain_data = $c->model('DB::UserDomain')->create({
            uid       => $user_data->id,
            domain_id => $domain_data->id
        });
    }
    catch {
        $c->log->debug('Register - create of new user_domain data failed : ' . $_);
        $error = 1;
    };
    if ( $error ) {
        $c->stash->{json} = {
            success => 0,
            message => 'Register - create of new user_domain data failed'
        };

        return;
    }

    $c->stash->{json} = {
        success => 1,
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
