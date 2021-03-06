package Stylus::Controller::Process;
use Moose;
use namespace::autoclean;

use DDP;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Stylus::Controller::Content - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;

    unless ( $c->user_exists && $c->session->{user_domain_id} ) {
        $c->log->debug( " User does not exist - redirect to login page ...");
        if ( $c->req->method eq 'POST' ) {
            $c->log->debug('Process : session timed out on ajax request');
        	$c->stash->{current_view} = 'JSON_Service';
        	$c->stash->{logged_in}    = 0;
        	$c->detach;
            return;
        }
        else {
            $c->log->debug('Process : get request ...');
            $c->response->redirect($c->uri_for('/stylus/login'));
            $c->detach;
            return;
        }
    }

    return 1;
}

=head2 index

=cut

sub index :Path( '/stylus/process' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	  $c->stash->{template}  = 'index.tt';
	  $c->stash->{initial}   = 'process.tt';
	  $c->stash->{righthalf} = 'processright.tt';

    # get settings data - domains
    my $userdomains_rs = $c->model('DB::UserDomain')->search(
        { uid => $c->user->id },
    );

    my @ud_data;
    if ( $userdomains_rs->count ) {
        while ( my $userdomain = $userdomains_rs->next ) {
            my $row = {
                id     => $userdomain->domain_id,
                domain => $userdomain->domain->name,
            };

            push(@ud_data, $row);
        }
    }
    $c->stash->{domains}       = \@ud_data;
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
