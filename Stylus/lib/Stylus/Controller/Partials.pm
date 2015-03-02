package Stylus::Controller::Partials;
use Moose;
use namespace::autoclean;

use DDP;
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
    my $partials_rs = $c->model('DB::Partial')->search(
        { domain => $c->session->{user_domain} },
        { order_by => [ qw/ type / ] }
    );

    my @data;
    if ( $partials_rs->count ) {
        while ( my $partial = $partials_rs->next ) {

            my $row = {
                id           => $partial->id,
                type         => $partial->type,
                description  => $partial->description,
                label        => $partial->name,
            };

            push(@data, $row);
        }
    }
p @data;
    $c->stash->{partials} = \@data;
}

### all general methods come after this ###

=head2 create

create a 'new' partial

=cut

sub create :Path( '/stylus/partials/create' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
    $c->stash->{template}  = 'index.tt';
    $c->stash->{initial}   = 'createpartial.tt';
    $c->stash->{righthalf} = 'createpartialsright.tt';
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

=head2 edit

=cut

sub edit :Chained('base') :PathPart('edit') :Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('Partials - edit process.');

    # edit page
    $c->stash->{current_view} = 'TT';
    $c->stash->{template}  = 'index.tt';
    $c->stash->{initial}   = 'editpartials.tt';
    $c->stash->{righthalf} = 'createpartialsright.tt';
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
