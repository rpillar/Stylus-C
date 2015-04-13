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

    unless ( $c->user_exists && $c->session->{user_domain_id} ) {
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

    # get settings data - domains
    my $userdomains_rs = $c->model('DB::UserDomain')->search(
        { uid => $c->user->id },
    );

    my @ud_data;
    if ( $userdomains_rs->count ) {
        while ( my $userdomain = $userdomains_rs->next ) {

            my $row = {
                id     => $userdomain->domains->id,
                domain => $userdomain->domains->name,
            };

            push(@ud_data, $row);
        }
    }

    # get settings data - content_types
    my $contenttypes_rs = $c->model('DB::ContentType')->search();

    my @ct_data;
    if ( $contenttypes_rs->count ) {
        while ( my $contenttype = $contenttypes_rs->next ) {

            my $row = {
                id   => $contenttype->id,
                type => $contenttype->type,
            };

            push(@ct_data, $row);
        }
    }

    $c->stash->{domains}       = \@ud_data;
    $c->stash->{content_types} = \@ct_data;
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
