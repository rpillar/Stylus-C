package Stylus::Controller::Articles::API;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Text::Markdown 'markdown';
use Scalar::Util qw( looks_like_number);
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }
__PACKAGE__->config(default => 'application/json');

=head2 base method

=cut

sub base :Chained('/') PathPart('stylus/article') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Articles API - article_base');

    # remove all non-digits
    $id =~ s/\D//g;

    if ( looks_like_number( $id ) ) {
        # get article ...
        my $article = $c->model('DB::Article')->find({
            id => $id
        });
        if ( $article ) {
            $c->stash->{article} = $article;
        }
    }
}

=head2 article_new - 'base' method for 'new' articles

=cut

sub base_new :Chained('/') PathPart('stylus/article') :CaptureArgs( 0 ) {
    my ( $self, $c ) = @_;

    $c->log->debug('in Articles API - article_new');
}

=head2 article_new

=cut

sub article_new :Chained('base_new') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 article

=cut

sub article :Chained('base') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 publish

=cut

sub publish :Chained('base') PathPart('publish') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 article_GET

=cut

sub article_GET :Private {
    my ($self, $c) = @_;

    my $article = $c->stash->{article};

    my $date = 0;
    if ( $article->type eq 'Event' ) {
        $date = $article->event_date->ymd;
    }

    # convert markdown content
    my $content = markdown( $article->content );

    $self->status_ok(
        $c,
        entity => {
            id      => $article->id,
            title   => $article->title,
            type    => $article->type,
            content => $content,
            publish => $article->publish,
            date    => $date,
        },
    );
}

=head2 article_DELETE

=cut

sub article_DELETE :Private {
    my ($self, $c) = @_;

    try {
        $c->stash->{article}->delete();
        $self->status_accepted( $c, entity => { status => "deleted" } );
    }
    catch {
        $self->status_bad_request(
            $c,
            message => "Articles : there has been an error deleting data from the stylus db !",
        );
    };
}

=head2 article_new_POST

=cut

sub article_new_POST :Private {
    my ($self, $c) = @_;

    # get updated article data ..
    my $data = $c->req->data || $c->req->params;

    my $stylus_article = $c->model('DB::Article')->create(
        {
            type         => $data->{type},
            article_date => $data->{date},
            title        => $data->{title},
            content      => $data->{article},
        }
    );

    if ( $stylus_article ) {
        $self->status_created(
            $c,
            location => $c->req->uri,
            entity  => {
            },
        );
    }
    else {
        $self->status_bad_request(
            $c,
            message => "Articles : there has been an error creating an article !",
        );
    }
}

=head2 publish_POST

=cut

sub publish_PUT :Private {
    my ( $self, $c, ) = @_;

    my $article = $c->stash->{article};

    # get value of 'publish' to set ..
    my $data = $c->req->data || $c->req->params;

    my $flag = $data->{flag};
    try {
        $c->stash->{article}->update(
            { publish => $flag }
        );

        $self->status_created(
            $c,
            location => $c->req->uri,
            entity  => {
            },
        );
    }
    catch {
        $self->status_bad_request(
            $c,
            message => "Articles : there has been an error updating the 'publish' flag !",
        );
    };
}

1;
