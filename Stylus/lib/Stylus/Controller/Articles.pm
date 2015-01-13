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
	        id         => $_->id,
	        type       => $_->type,
	        title      => $_->title,
	        content    => markdown( $content ),
	        publish    => $_->publish,
	    };
	    if ( $_->type eq 'Event' ) {
	        $row->{event_date} = $_->event_date->ymd;
	    }
	    else {
	        $row->{event_date} = 0;
	    }
	    push(@data, $row);
	}

    $c->stash->{init}->{id}         = $data[0]->{id};
    $c->stash->{init}->{type}       = $data[0]->{type};
    $c->stash->{init}->{event_date} = $data[0]->{event_date};
    $c->stash->{init}->{title}      = $data[0]->{title};
    $c->stash->{init}->{content}    = $data[0]->{content};
    $c->stash->{init}->{publish}    = $data[0]->{publish};

	$c->stash->{articles} = \@data;
}

### all general methods come after this ###

### create a 'new' article ###

sub create_start :Path( '/stylus/articles/create' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'create.tt';
	$c->stash->{righthalf} = 'createright.tt';
}

=head2 add

=cut

sub add :Path( '/stylus/articles/add' ) :Args(0) {
    my ( $self, $c ) = @_;

    my $type    = $c->request->params->{type};
    my $date    = $c->request->params->{date};
    my $title   = $c->request->params->{title};
    my $article = $c->request->params->{article};

    my $stylus_article = $c->model('DB::Article')->create(
        {
            type       => $type,
            event_date => $date,
            title      => $title,
            content    => $article,
        }
    );

    $c->stash->{current_view} = 'JSON_Service';
    if ( $stylus_article ) {
        $c->log->debug('Create article - worked');
        $c->stash->{json} = {
            success => 1,
        };
    }
    else {
        $c->log->debug('Create article - an error has occurred');
        $c->stash->{json} = {
            success => 0,
        };
    }
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

=head2 delete

=cut

sub delete :Chained('base') :PathPart('delete') :Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('Article - delete process.');

	$c->stash->{current_view} = 'JSON_Service';

	# delete
	try {
	    $c->stash->{article}->delete;
        $c->stash->{article} = undef;
    }
    catch {
        $c->stash->{article} = undef;
        return 0;
    };

    return 1;
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

=head2 publish

=cut

sub publish :Chained('base') :PathPart('publish') :Args(1) {
    my ( $self, $c, $flag ) = @_;

    $c->log->debug('In Articles - publish - about to update data for - id : ' . $c->stash->{article}->id . ' with flag : ' . $flag);

    $c->stash->{current_view} = 'JSON_Service';
	  try {
	    $c->stash->{article}->update(
	        { publish => $flag }
	    );
        $c->stash->{article} = undef;
    }
    catch {
        $c->stash->{article} = undef;
        return 0;
    };
}

=head2 retrieve

=cut

sub retrieve :Chained('base') :PathPart('retrieve') :Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('In Articles - retrieve');

	$c->stash->{current_view} = 'JSON_Service';
	$c->stash->{article_id}      = $c->stash->{article}->id;
	$c->stash->{article_title}   = $c->stash->{article}->title;
	$c->stash->{article_type}    = $c->stash->{article}->type;

	# only 'inflate' if I need to ...
	if ( $c->stash->{article}->type eq 'Event' ) {
	    $c->stash->{event_date}  = $c->stash->{article}->event_date->ymd;
	}
	$c->stash->{article_content} = markdown( $c->stash->{article}->content );
	$c->stash->{article_publish} = $c->stash->{article}->publish;

    # set stash 'article' to undef - not required for the response
    $c->stash->{article} = undef;
}

=head2 update

=cut

sub update :Chained('base') :PathPart('update') :Args(0) {
    my ( $self, $c ) = @_;

    my $date    = $c->request->params->{date};
    my $title   = $c->request->params->{title};
    my $article = $c->request->params->{article};

    $c->log->debug('Article - update process.');

	$c->stash->{current_view} = 'JSON_Service';
	try {
	    $c->stash->{article}->update(
	        { event_date => $date, title => $title, content => $article }
	    );
        $c->stash->{article} = undef;
        return 1;
    }
    catch {
        $c->stash->{article} = undef;
        return 0;
    };

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
