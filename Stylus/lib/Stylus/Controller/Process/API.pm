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

=head2 build_site

=cut

sub build_site :Chained('base') PathPart('build-site') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;
}

sub build_site_GET :Private {
    my ($self, $c) = @_;
}

=head2 validate

=cut

sub validate :Chained('base') PathPart('validate') Args(0) : ActionClass('REST') {
    my ($self, $c) = @_;   
}

sub validate_GET :Private {
    my ($self, $c) = @_;

    # check if the location supplied actually exists ...
    unless ( check_filename( $c->req->params ) ) {
        $c->log->debug('Process - check_filename - location : ' . $c->req->params->{path});
        return $self->status_bad_request(
            $c,
            message => "Process : the file name / path supplied is incorrect - please check.",
        );
    }

    # check for files / layouts ...

    $self->status_ok(
        $c,
        entity => {
            message => 'Process : Validate - complete.'
        },
    );
}

# validation methods

sub check_filename {
    my ( $params ) = @_;

    if ( -e $params->{path} ) {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 layout

=cut

sub layout {
    my ($self, $c, $layout) = @_;

    # get filename data ..
    my $data = $c->req->data || $c->req->params;

    $c->log->debug('Process - layout : ' . $data->{layout});

    my $status = $self->parse_layout( $c, $data );

    if ( $status eq 'success' ) {
        $self->status_ok(
            $c,
            entity => {
                success => 1,
            }
        );
    }
    else {

    }
}

=head2 settings

=cut

sub settings {
    my ($self, $c) = @_;

    # get domain name data ..
    my $data = $c->req->data || $c->req->params;

    $c->log->debug('Process - settings - domain : ' . $data->{domain});

    # get settings data for this domain
    my $settings = $c->model('DB::PagesDetail')->search(
        { domain_id => $data->{domain} },
    )->first;

    # if I find a 'path' then get all the file names contained here ...
    if ( $settings->path ) {
        $c->log->debug('Process - settings - path : ' . $settings->path);
        # check that 'path' is a directory
        my $status = 0;

        if ( -d $settings->path ) {
            my @files = read_dir( $settings->path );

            return $self->status_ok(
                $c,
                entity => {
                    files => \@files,
                },
            );
        }
        else {
            return $self->status_bad_request(
                $c,
                message => "Process : the Settings path location is incorrect - please check.",
            );
        }
    }
    else { # get names of 'layouts' ...
        $c->log->debug('Process - settings - layouts.');
        my $user_domain = $c->model('DB::UserDomain')->search(
            { domain_id => $data->{domain} }
        )->first;
        my @layouts = $user_domain->domain->partials->layouts->all;

        my @layout_names;
        foreach( @layouts ) {
            push(@layout_names, $_->name);
        }

        return $self->status_ok(
            $c,
            entity => {
                layouts => \@layout_names,
            }
        );
    }
}

# utility methods ...

=head2 parse_layout

=cut

sub parse_layout {
    my ($self, $c, $data ) = @_;

    $c->log->debug('Process - parse_layout : ' . $data->{layout});    

    my $layout = $c->model('DB::Partial')->search(
        { name => $data->{layout} }
    )->first;
}

=head2 write_web_file

=cut

sub write_web_file {

}

__PACKAGE__->meta->make_immutable;

1;
