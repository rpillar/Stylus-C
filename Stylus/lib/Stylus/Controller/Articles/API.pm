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

    $c->log->debug('in Articles API - article');

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

sub article_POST :Private {
    my ($self, $c) = @_;

    # get updated article data ..
    my $data = $c->req->data || $c->req->params;

    $self->status_created(
        $c,
        location => $c->req->uri,
        entity  => {

        },
    );
}

=head2 add

=cut

#sub add :Path( '/stylus/articles/add' ) :Args(0) {
#    my ( $self, $c ) = @_;

#    my $type    = $c->request->params->{type};
#    my $date    = $c->request->params->{date};
#    my $title   = $c->request->params->{title};
#    my $article = $c->request->params->{article};

#    my $stylus_article = $c->model('DB::Article')->create(
#        {
#            type       => $type,
#            event_date => $date,
#            title      => $title,
#            content    => $article,
#        }
#    );

#    $c->stash->{current_view} = 'JSON_Service';
#    if ( $stylus_article ) {
#        $c->log->debug('Create article - worked');
#        $c->stash->{json} = {
#            success => 1,
#        };
#    }
#    else {
#        $c->log->debug('Create article - an error has occurred');
#        $c->stash->{json} = {
#            success => 0,
#        };
#    }
#}



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
