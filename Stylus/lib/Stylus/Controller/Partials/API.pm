package Stylus::Controller::Partials::API;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use HTML::Entities;
use Scalar::Util qw( looks_like_number);
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }
__PACKAGE__->config(default => 'application/json');

=head2 base method

=cut

sub base :Chained('/') PathPart('stylus/partials') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Partials API - base');

    # remove all non-digits
    $id =~ s/\D//g;

    if ( looks_like_number( $id ) ) {
        # get partial ...
        my $partial = $c->model('DB::Partial')->find({
            id => $id
        });
        if ( $partial ) {
            $c->stash->{partial} = $partial;
        }
    }
}

=head2 base_new - 'base' method for 'new' partials

=cut

sub base_new :Chained('/') PathPart('stylus/partials') :CaptureArgs( 0 ) {
    my ( $self, $c ) = @_;

    $c->log->debug('in Partials API - base_new');
}

=head2 partial_new

=cut

sub partial_new :Chained('base_new') PathPart('create-process') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 partial

=cut

sub partial :Chained('base') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 partial_GET

=cut

sub partial_GET :Private {
    my ($self, $c) = @_;

    my $partial = $c->stash->{partial};

    $self->status_ok(
        $c,
        entity => {
            id          => $partial->id,
            type        => $partial->partial_type->type,
            label       => $partial->name,
            description => $partial->description,
            partial     => $partial->partial,
        },
    );
}

=head2 partial_DELETE

=cut

sub partial_DELETE :Private {
    my ($self, $c) = @_;

    try {
        $c->stash->{partial}->delete();
        $self->status_accepted( $c, entity => { status => "deleted" } );
    }
    catch {
        $self->status_bad_request(
            $c,
            message => "Partials : there has been an error deleting data from the Stylus DB !",
        );
    };
}

=head2 partial_PUT

=cut

sub partial_PUT :Private {
    my ($self, $c) = @_;

    # get partial data ..
    my $data = $c->req->data || $c->req->params;

    try {
        $c->stash->{partial}->update(
            {
                name        => encode_entities( $data->{label} ),
                description => encode_entities( $data->{description} ),
                partial     => ( $data->{partial} ),
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
            message => "Partials : there has been an error updating the Stylus DB !",
        );
    };
}

=head2 partial_new_POST

=cut

sub partial_new_POST :Private {
    my ($self, $c) = @_;

    # get partial data ..
    my $data = $c->req->data || $c->req->params;

    # need to get the type_id value (not sure it is possible to set / get this)
    my $partial_type = $c->model('DB::PartialType')->search({
        type => $data->{type}
    })->first();

    my $stylus_partial = $c->model('DB::Partial')->create(
        {
            type_id     => $partial_type->id,
            name        => encode_entities( $data->{label} ),
            description => encode_entities( $data->{description} ),
            partial     => ( $data->{partial} ),
            domain_id   => $c->session->{user_domain_id},
        }
    );

    if ( $stylus_partial ) {
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
            message => "Partials : there has been an error creating a partial !",
        );
    }
}

1;
