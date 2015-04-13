package Stylus::Controller::Content;
use Moose;
use namespace::autoclean;

use DDP;
use Text::Markdown 'markdown';

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
            $c->log->debug('Content : session timed out on ajax request');
        	$c->stash->{current_view} = 'JSON_Service';
        	$c->stash->{logged_in}    = 0;
        	$c->detach;
            return;
        }
        else {
            $c->log->debug('Content : get request ...');
            $c->response->redirect($c->uri_for('/stylus/login'));
            $c->detach;
            return;
        }
    }

    return 1;
}

=head2 index

=cut

sub index :Path( '/stylus/content' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'content.tt';
	$c->stash->{righthalf} = 'contentright.tt';

	# get content data - set initial content values
    my $content_rs = $c->model('DB::Content')->search(
        { domain_id => $c->session->{user_domain_id} }
    );

	# trim 'content' and convert to HTML (stored as Markdown)
	my @data;
    if ( $content_rs->count ) {
	    while ( my $content = $content_rs->next ) {
	        # get length of string / position of first line-break
	        my $content_len  = length( $content->content );
	        my $line_end_pos = index($content->content, $/);

	        my $content_text;
	        if ( $line_end_pos > 0 && $line_end_pos < $content_len ) {
	            $content_text = substr( $content->content,0,$line_end_pos);
	        }
	        else {
	            $content_text = $content->content;
	        }

	        my $row = {
	            id           => $content->id,
	            type         => $content->content_type->type,
	            title        => $content->title,
	            content      => markdown( $content_text ),
	            publish      => $content->publish,
	            content_date => $content->content_date,
	        };
p $row;
	        push(@data, $row);
        }
	}

	$c->stash->{content_data} = \@data;
}

### all general methods come after this ###

=head2 create

create 'new' content

=cut

sub create :Path( '/stylus/content/create' ) :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'create content' page
    my $content_type_rs = $c->model('DB::ContentType')->search();
    my @data;
    while ( my $type = $content_type_rs->next ) {
        my $row = {
            id   => $type->id,
            type => $type->type
        };
        p $row;
        push(@data, $row);
    }

    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'createcontent.tt';
	$c->stash->{righthalf} = 'createcontentright.tt';

    $c->stash->{content_type} = \@data;
}

### chained methods ###

=head2 base

=cut

sub base :Chained('/') PathPart('stylus/content') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Content - base');

    # remove all non-digits
    $id =~ s/\D//g;

    # get content ...
    my $content = $c->model('DB::Content')->find({
        id => $id
    });

    if ( $content) {
        $c->stash->{content_data} = $content
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

    $c->log->debug('Content - edit process.');

    # edit page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'editcontent.tt';
	$c->stash->{righthalf} = 'editcontentright.tt';
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
