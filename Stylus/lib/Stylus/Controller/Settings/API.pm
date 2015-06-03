package Stylus::Controller::Settings::API;
use Moose;
use namespace::autoclean;

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

=head2 base method - for 'pages_path'

=cut

sub base_pp :Chained('/') PathPart('stylus/settings/pages_path') :CaptureArgs( 1 ) {
    my ( $self, $c, $domain_id) = @_;

    $c->log->debug('in Settings API - base_pp');

    # get settings data ...
    if ( $domain_id ) {
        my $pages_detail = $c->model('DB::PagesDetail')->find({
            domain_id => $domain_id
        });
        if ( $pages_detail ) {
            $c->log->debug('Settings - I have found a pages_detail record ...');
            $c->stash->{pagesdetail} = $pages_detail;
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

=head2 base method - for new 'content_types'

=cut

sub base_ct_new :Chained('/') PathPart('stylus/settings/content_type') :CaptureArgs( 0 ) {
    my ( $self, $c ) = @_;
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

=head2 content_type_new

=cut

sub content_type_new :Chained('base_ct_new') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;

    $c->log->debug('in Settings API - content_type_new');
}

=head2 pages_path

=cut

sub pages_path :Chained('base_pp') PathPart('') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;

    $c->log->debug('in Settings API - pages_path');
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
        $c->stash->{contenttype}->delete();
        $self->status_accepted( $c, entity => { status => "deleted" } );
    }
    catch {
        $self->status_ok(
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

=head2 content_type_new_PUT

=cut

sub content_type_new_PUT :Private {
    my ($self, $c) = @_;

    # get user_domain data ..
    my $data = $c->req->data || $c->req->params;

    # check to see if a content_type with this 'type' already exists.
    my $contenttype_rs = $c->model('DB::ContentType')->search({
        type => $data->{type},
    });

    if ( $contenttype_rs->count ) {
        return
            $self->status_ok(
                $c,
                entity => {
                    message => "Settings - Content Type : a type with this name already exists !",
                }
            );
    }

    try {
        my $domain = $c->model('DB::ContentType')->create(
            { type => $data->{type} },
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
            message => "Settings - Content Types : there has been an error adding a new entry into the Stylus DB !",
        );
    };
}

=head2 pages_path_PUT

=cut

sub pages_path_PUT :Private {
    my ($self, $c) = @_;

    # get data parameters ...
    my $data        = $c->req->data || $c->req->params;

    # update the Pages Details entry ...
    try {
        $c->stash->{pagesdetail}->update(
            { path => $data->{path} }
        );

        $self->status_created(
            $c,
            location => $c->req->uri,
            entity  => {
            },
        );
    }
    catch {
        $c->log->debug('Settings - pages_path_PUT : error ' . $_);

        $self->status_bad_request(
            $c,
            message => "Settings - Pages Path : there has been an error updating the Stylus DB !",
        );
    };
}

=head2 user_domain_DELETE

=cut

sub user_domain_DELETE :Private {
    my ($self, $c) = @_;

    $c->log->debug('Settings - in user_domains DELETE method.');

    # check that there is more than one domain 'left'
    my $ud_rs = $c->model('DB::UserDomain')->search({
        uid => $c->user->id
    });
    if ( $ud_rs->count < 2 ) {
        return
            $self->status_ok(
                $c,
                entity => {
                    message => "Settings : there is only one domain remaining for the current user - unable to delete as this would prevent login and processing. !",
                }
            );
    }

    # remove data from the user_domains table
    my $error = 0;
    try {
        my $ud_data = $c->model('DB::UserDomain')-> find({
            domain_id => $c->stash->{domain}->id
        });
        if ( $ud_data ) {
            $ud_data->delete();
        }
    }
    catch {
        $c->log->debug('Settings : ud delete - ' . $_);
        $error = 1;
    };

    if ( $error ) {
        return
            $self->status_bad_request(
                $c,
                message => "Settings : there has been an error deleting user-domain data from the Stylus DB !",
            );
    }

    # remove data from the content table
    try {
        my $content_rs = $c->model('DB::Content')->search({
            domain_id => $c->stash->{domain}->id
        });
        $content_rs->delete();
    }
    catch {
        $c->log->debug('Settings : content delete - ' . $_);
        $error = 1;
    };

    if ( $error ) {
        return
            $self->status_bad_request(
                $c,
                message => "Settings : there has been an error deleting content data from the Stylus DB !",
            );
    }

    # remove data from the partials table
    try {
        my $partials_rs = $c->model('DB::Partial')->search({
            domain_id => $c->stash->{domain}->id
        });
        $partials_rs->delete();
    }
    catch {
        $c->log->debug('Settings : partials delete - ' . $_);
        $error = 1;
    };

    if ( $error ) {
        return
            $self->status_bad_request(
                $c,
                message => "Settings : there has been an error deleting partials data from the Stylus DB !",
            );
    }

    # remove data from the domains table
    try {
        $c->stash->{domain}->delete();
    }
    catch {
        $error = 1;
    };

    if ( $error ) {
        return
            $self->status_bad_request(
                $c,
                message => "Settings : there has been an error deleting domain data from the Stylus DB !",
            );
    }
    else {
        $self->status_accepted( $c, entity => { status => "deleted" } );
    }
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

    # check to see if a domain with this 'name' / 'user' already exists.
    my $domain_rs = $c->model('DB::Domain')->search({
        name => $data->{domain},
    });

    if ( $domain_rs->count ) {
        while ( my $domain = $domain_rs->next ) {
            my $userdomain_check = $c->model('DB::UserDomain')->find({
                domain_id => $domain->id,
                uid       => $c->user->id,
            });

            if ( $userdomain_check ) {
                return
                    $self->status_ok(
                        $c,
                        entity => {
                            message => "Settings - User Domains : a domain with this name already exists for the current user !",
                        }
                    );
            }
        }
    }

    try {
        my $domain = $c->model('DB::Domain')->create(
            { name => $data->{domain} },
        );
        my $pagesdetail = $c->model('DB::PagesDetail')->create(
            {
                uid       => $c->user->id,
                domain_id => $domain->id,
                path      => '',
            },
        );
        my $userdomain = $c->model('DB::UserDomain')->create(
            {
                uid       => $c->user->id,
                domain_id => $domain->id
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
        $c->log->debug('Settings - user_domains_new_PUT : error ' . $_);

        $self->status_bad_request(
            $c,
            message => "Settings - User Domains : there has been an error adding a new entry into the Stylus DB !",
        );
    };
}

1;
