package Stylus::Controller::Articles;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Text::Markdown 'markdown';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Stylus::Controller::Articles - Catalyst Controller

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
            $c->log->debug('Articles : session timed out on ajax request');
        	$c->stash->{current_view} = 'JSON_Service';
        	$c->stash->{logged_in}    = 0;
        	$c->detach;
            return;
        }
        else {
            $c->log->debug('Articles : get request ...');
            $c->response->redirect($c->uri_for('/stylus/login'));
            $c->detach;
            return;
        }
    }

    return 1;
}

=head2 index

=cut

sub index :Path( '/stylus/articles' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'articles.tt';
	$c->stash->{righthalf} = 'articlesright.tt';

	# get articles data - set initial article values
	my @articles = $c->model('DB::Article')->all;

	# trim 'content' and convert to HTML (stored as Markdown)
	my @data;
	foreach ( @articles) {
	    # get length of string / position of first line-break
	    my $content_len  = length( $_->content );
	    my $line_end_pos = index($_->content, $/);

	    my $content;
	    if ( $line_end_pos > 0 && $line_end_pos < $content_len ) {
	        $content = substr( $_->content,0,$line_end_pos);
	    }
	    else {
	        $content = $_->content;
	    }

	    my $row = {
	        id           => $_->id,
	        type         => $_->type,
	        title        => $_->title,
	        content      => markdown( $content ),
	        publish      => $_->publish,
	        article_date => $_->article_date,
	    };

	    push(@data, $row);
	}

	$c->stash->{articles} = \@data;
}

### all general methods come after this ###

=head2 create

create a 'new' article

=cut

sub create :Path( '/stylus/articles/create' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'create.tt';
	$c->stash->{righthalf} = 'createright.tt';
}

### chained methods ###

=head2 base

=cut

sub base :Chained('/') PathPart('stylus/articles') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Articles - base');

    # remove all non-digits
    $id =~ s/\D//g;

    # get article ...
    my $article = $c->model('DB::Article')->find({
        id => $id
    });

    if ( $article) {
        $c->stash->{article} = $article
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

    $c->log->debug('Article - edit process.');

    # edit page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'edit.tt';
	$c->stash->{righthalf} = 'editright.tt';
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
