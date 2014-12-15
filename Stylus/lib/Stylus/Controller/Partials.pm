package Stylus::Controller::Partials;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Text::Markdown 'markdown';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Stylus::Controller::Partials - Catalyst Controller

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
            $c->log->debug('Partials : session timed out on ajax request');
            $c->stash->{current_view} = 'JSON_Service';
            $c->stash->{logged_in}    = 0;
            $c->detach;
            return;
        }
        else {
            $c->log->debug('Partials : get request ...');
            $c->response->redirect($c->uri_for('/stylus/login'));
            $c->detach;
            return;
        }
    }

    return 1;
}

=head2 index

=cut

sub index :Path( '/stylus/partials' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
    $c->stash->{template}  = 'index.tt';
    $c->stash->{initial}   = 'partials.tt';
    $c->stash->{righthalf} = 'partialsright.tt';

    # get partials data - set initial partial values
    my @partials = $c->model('DB::Partial')->all;

    my @data;
    $c->stash->{articles} = \@data;
}

### all general methods come after this ###

### create a 'new' partial ###

sub create_start :Path( '/stylus/partials/create' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
    $c->stash->{template}  = 'index.tt';
    $c->stash->{initial}   = 'createpartial.tt';
}

### chained methods ###

=head2 base

=cut

sub base :Chained('/') PathPart('stylus/partials/') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Partials - base');

    # remove all non-digits
    $id =~ s/\D//g;

    # get partial ...
    my $partial = $c->model('DB::Partial')->find({
        id => $id
    });

    if ( $partial) {
        $c->stash->{partial} = $partial
    }
    else {
        $c->stash->{curent_view} = 'TT';
        $c->stash->{template} = '404.tt';
        $c->detach;
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
