package Stylus::Controller::Settings::API;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }
__PACKAGE__->config(default => 'application/json');

=head2 base method

=cut

sub base :Chained('/') PathPart('stylus/settings') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Settings API - base');

    # remove all non-digits
    $id =~ s/\D//g;

    if ( looks_like_number( $id ) ) {
        # get settings data ...
        my $content = $c->model('DB::Article')->find({
            id => $id
        });
        if ( $content ) {
            $c->stash->{content} = $content;
        }
    }
}

=head2 content_type

=cut

sub content_type :Chained('base') PathPart('content_type') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 domain

=cut

sub domain :Chained('base') PathPart('domain') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 settings

=cut

sub settings :Chained('base') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 settings_GET

=cut

sub settings_GET :Private {
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

=head2 content_type_DELETE

=cut

sub content_type_DELETE :Private {
    my ($self, $c) = @_;
}

=head2 content_type_PUT

=cut

sub content_type_PUT :Private {
    my ($self, $c) = @_;
}

=head2 domain_DELETE

=cut

sub domain_DELETE :Private {
    my ($self, $c) = @_;
}

=head2 content_type_PUT

=cut

sub domain_PUT :Private {
    my ($self, $c) = @_;
}

1;
