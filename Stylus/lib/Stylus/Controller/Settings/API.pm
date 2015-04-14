package Stylus::Controller::Settings::API;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Scalar::Util qw( looks_like_number);
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }
__PACKAGE__->config(default => 'application/json');

=head2 base method - for 'content_types'

=cut

sub base_ct :Chained('/') PathPart('stylus/settings/content_type') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Settings API - base_ct');

    # remove all non-digits
    $id =~ s/\D//g;

    if ( looks_like_number( $id ) ) {
        # get settings data ...
        my $contenttype = $c->model('DB::ContentType')->find({
            id => $id
        });
        if ( $contenttype ) {
            $c->stash->{contenttype} = $contenttype;
        }
    }
}

=head2 base method - for 'user_domains'

=cut

sub base_ud :Chained('/') PathPart('stylus/settings/user_domain') :CaptureArgs( 1 ) {
    my ( $self, $c, $id) = @_;

    $c->log->debug('in Settings API - base_ud');

    # remove all non-digits
    $id =~ s/\D//g;

    if ( looks_like_number( $id ) ) {
        # get settings data ...
        my $domain = $c->model('DB::Domain')->find({
            id => $id
        });
        if ( $domain ) {
            $c->stash->{domain} = $domain;
        }
    }
}

=head2 base method - for new 'user_domains'

=cut

sub base_ud_new :Chained('/') PathPart('stylus/settings/user_domain') :CaptureArgs( 0 ) {
    my ( $self, $c ) = @_;
}

=head2 content_type

=cut

sub content_type :Chained('base_ct') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 user_domain

=cut

sub user_domain :Chained('base_ud') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;

    $c->log->debug('in Settings API - user_domain');
}

=head2 user_domain_new

=cut

sub user_domain_new :Chained('base_ud_new') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;

    $c->log->debug('in Settings API - user_domain_new');
}

## RESTful methods ##

=head2 content_type_DELETE

=cut

sub content_type_DELETE :Private {
    my ($self, $c) = @_;

    try {
        $c->stash->{contenttypes}->delete();
        $self->status_accepted( $c, entity => { status => "deleted" } );
    }
    catch {
        $self->status_bad_request(
            $c,
            message => "Settings - Content Type : there has been an error deleting data from the Stylus DB !",
        );
    };
}

=head2 content_type_PUT

=cut

sub content_type_PUT :Private {
    my ($self, $c) = @_;
}

=head2 user_domain_DELETE

=cut

sub user_domain_DELETE :Private {
    my ($self, $c) = @_;
}

=head2 user_domain_PUT

=cut

sub user_domain_PUT :Private {
    my ($self, $c) = @_;

    # get user_domain data ..
    my $data = $c->req->data || $c->req->params;

    try {
        $c->stash->{domain}->update(
            { name => $data->{domain} }
        );

        $self->status_created(
            $c,
            location => $c->req->uri,
            entity  => {
            },
        );
    }
    catch {
        $c->log->debug('Settings - user_domains_PUT : error ' . $_);

        $self->status_bad_request(
            $c,
            message => "Settings - User Domains : there has been an error updating the Stylus DB !",
        );
    };
}

=head2 user_domain_new_PUT

=cut

sub user_domain_new_PUT :Private {
    my ($self, $c) = @_;

    # get user_domain data ..
    my $data = $c->req->data || $c->req->params;

    try {
        my $domain = $c->model('DB::Domain')->create(
            { name => $data->{domain} },
        );
        my $userdomain = $c->model('DB::UserDomain')->create(
            { uid => $c->user->id, domain_id => $domain->id }
        );

        $self->status_created(
            $c,
            location => $c->req->uri,
            entity  => {
            },
        );
    }
    catch {
        $c->log->debug('Settings - user_domains_new_PUT : error ' . $_);

        $self->status_bad_request(
            $c,
            message => "Settings - User Domains : there has been an error adding a new entry into the Stylus DB !",
        );
    };
}

1;
