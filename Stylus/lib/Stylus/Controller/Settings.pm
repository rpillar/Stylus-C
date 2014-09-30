package Stylus::Controller::Settings;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Stylus::Controller::Settings - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    
    unless ( $c->user_exists ) {
        $c->log->debug( " User does not exist - redirect to login page ...");
        if ( $c->req->method eq 'POST' ) {
            $c->log->debug('Settings : session timed out on ajax request');	        
        	$c->stash->{current_view} = 'JSON_Service';
        	$c->stash->{logged_in}    = 0;
        	$c->detach;
            return;
        }
        else {
            $c->log->debug('Settings : get request ...');	    
            $c->response->redirect($c->uri_for('/stylus/login'));
            $c->detach;
            return;
        }
    }
    
    return 1;
}

=head2 index

=cut

sub index :Path( '/stylus/settings' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';	
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'settings.tt';
	$c->stash->{righthalf} = 'settingsright.tt';
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}


=encoding utf8

=head1 AUTHOR

Richard Pillar,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
