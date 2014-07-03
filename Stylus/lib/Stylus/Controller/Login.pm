package Stylus::Controller::Login;
use Moose;
use namespace::autoclean;

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

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('Login controller - process - status : ' . $c->res->status);

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

    unless ( $c->authenticate({ username => $username, password => $password, })) {
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
