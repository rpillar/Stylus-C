package Stylus::Controller::Articles;
use Moose;
use namespace::autoclean;

use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

#__PACKAGE__->config(namespace => 'stylus/articles');

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
	        $c->response->redirect($c->uri_for('/stylus/login'));
            $c->detach;
        }    
        
        $c->response->redirect($c->uri_for('/stylus/login'));
        return 0;
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
    $c->stash->{init} = $articles[0];
    
	$c->stash->{articles} = \@articles;
}

### all general methods come after this ###

=head2 base 

=cut

sub base :Chained('/') PathPart('stylus/articles/id') CaptureArgs( $id ) {
    my ( $self, $c, $id) = @_;
    
    $c->log->debug('in Articles - base');
    
    # remove all non-digits
    #$id =~ s/\D//g;
    
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

sub delete :Chained('base') :PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;
    
    $c->log->debug('Article - delete process.');
	
	$c->stash->{current_view} = 'JSON_Service';
		
	# delete
	try {
	    $c->stash->{article}->delete;
    }
    catch {
        return 0;
    };
    return 1;	
}

=head2 edit 

=cut

sub edit :Chained('base') :PathPart('edit') Args(0) {
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

sub publish :Local {
    my ( $self, $c ) = @_;
    
    my $id   = $c->request->params->{id};
    my $flag = $c->request->params->{flag};
    $c->log->debug('In Articles->publish - about to update data for - id : ' . $id);
    
    # get article data
	my $article = $c->model('DB::Article')->find({
	    id => $id
	});
	
	$c->stash->{current_view} = 'JSON_Service';
	try {
	    $article->update(
	        { publish => $flag }
	    );
    }
    catch {
        return 0;
    };   
}

=head2 retrieve

=cut

sub retrieve :Chained('base') :PathPart('retrieve') Args(0) {
    my ( $self, $c ) = @_;
    
    $c->log->debug('In Articles->retrieve');
	
	$c->stash->{current_view} = 'JSON_Service';
	$c->stash->{article_id}      = $c->stash->{article}->id;
	$c->stash->{article_title}   = $c->stash->{article}->title;	
	$c->stash->{article_type}    = $c->stash->{article}->type;
	 
	# only 'inflate' if I need to ...
	if ( $c->stash->{article}->type eq 'Event' ) {
	    $c->stash->{event_date}  = $c->stash->{article}->event_date->ymd; 
	}
	$c->stash->{article_content} = $c->stash->{article}->content;
	$c->stash->{article_publish} = $c->stash->{article}->publish;    
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
