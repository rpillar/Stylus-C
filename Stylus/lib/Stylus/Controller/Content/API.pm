package Stylus::Controller::Content::API;
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

sub base :Chained('/') PathPart('stylus/content') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Content API - base');

    # remove all non-digits
    $id =~ s/\D//g;

    if ( looks_like_number( $id ) ) {
        # get article ...
        my $content = $c->model('DB::Article')->find({
            id => $id
        });
        if ( $content ) {
            $c->stash->{content} = $content;
        }
    }
}

=head2 base_new - 'base' method for 'new' content

=cut

sub base_new :Chained('/') PathPart('stylus/content') :CaptureArgs( 0 ) {
    my ( $self, $c ) = @_;

    $c->log->debug('in Content API - base_new');
}

=head2 article_new

=cut

sub content_new :Chained('base_new') PathPart('create-process') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 content

=cut

sub content :Chained('base') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 publish

=cut

sub publish :Chained('base') PathPart('publish') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 content_GET

=cut

sub content_GET :Private {
    my ($self, $c) = @_;

    my $content = $c->stash->{content};

    # convert markdown content
    my $content_item = markdown( $content->content );

    $self->status_ok(
        $c,
        entity => {
            id      => $content->id,
            title   => $content->title,
            type    => $content->type,
            content => $content_item,
            publish => $content->publish,
            date    => $content->article_date,
        },
    );
}

=head2 content_DELETE

=cut

sub content_DELETE :Private {
    my ($self, $c) = @_;

    try {
        $c->stash->{content}->delete();
        $self->status_accepted( $c, entity => { status => "deleted" } );
    }
    catch {
        $self->status_bad_request(
            $c,
            message => "Content : there has been an error deleting data from the Stylus DB !",
        );
    };
}

=head2 content_PUT

=cut

sub content_PUT :Private {
    my ($self, $c) = @_;

    # get content data ..
    my $data = $c->req->data || $c->req->params;

    try {
        $c->stash->{content}->update(
            {
                article_date => $data->{date},
                title        => $data->{title},
                content      => $data->{article},
            }
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
            message => "Content : there has been an error updating the 'publish' flag !",
        );
    };
}

=head2 content_new_POST

=cut

sub content_new_POST :Private {
    my ($self, $c) = @_;

    # get content data ..
    my $data = $c->req->data || $c->req->params;

    # need to get the type_id value (not sure it is possible to set / get this)
    my $content_type = $c->model('DB::ContentType')->search({
        type => $data->{type}
    })->first();

    my $stylus_content = $c->model('DB::Content')->create(
        {
            type_id      => $content_type->id,
            content_date => $data->{date},
            title        => $data->{title},
            content      => $data->{article},
            domain_id    => $c->session->{user_domain_id},
        }
    );

    if ( $stylus_content ) {
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
            message => "Content : there has been an error creating content !",
        );
    }
}

=head2 publish_POST

=cut

sub publish_PUT :Private {
    my ( $self, $c, ) = @_;

    my $content = $c->stash->{content};

    # get value of 'publish' to set ..
    my $data = $c->req->data || $c->req->params;

    my $flag = $data->{flag};
    try {
        $c->stash->{content}->update(
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
            message => "Content : there has been an error updating the 'publish' flag !",
        );
    };
}

1;
