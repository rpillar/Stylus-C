package Stylus::Controller::Process::API;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use File::Slurp;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller::REST' }
__PACKAGE__->config(default => 'application/json');

=head2 base method

=cut

sub base :Chained('/') PathPart('stylus/process') :CaptureArgs( 0 ) {
    my ( $self, $c, ) = @_;

    $c->log->debug('in Process API - base');
}

=head2 check_filename

=cut

sub check_filename :Chained('base') PathPart('check_filename') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 settings

=cut

sub settings :Chained('base') PathPart('settings') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

=head2 check_filename_GET

=cut

sub check_filename_GET :Private {
    my ($self, $c) = @_;

    # get filename data ..
    my $data = $c->req->data || $c->req->params;

    $c->log->debug('Process - check_filename - location : ' . $data->{path});
    if ( -e $data->{path} ) {
        $self->status_ok(
            $c,
            entity => {
            },
        );
    }
    else {
        $self->status_bad_request(
            $c,
            message => "Process : there has been an error when checking the supplied location - please check.",
        );
    }
}

=head2 settings_GET

=cut

sub settings_GET :Private {
    my ($self, $c) = @_;

    # get domain name data ..
    my $data = $c->req->data || $c->req->params;

    $c->log->debug('Process - settings - domain : ' . $data->{domain});

    # get settings data for this domain
    my $settings = $c->model('DB::PagesDetail')->search(
        { domain_id => $data->{domain} },
    )->first;
use DDP;
    # if I find a 'path' then get all the file names contained here ...
    if ( $settings->path ) {
        # check that 'path' is a directory
        my $status = 0;

        if ( -d $settings->path ) {
            my @files = read_dir( $settings->path );
p @files;
        }
        eilse {
            return $self->status_bad_request(
                $c,
                message => "Process : the Settings path location is incorrect - please check.",
            );
        }
p $settings->path
    }

    $self->status_ok(
        $c,
        entity => {
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
