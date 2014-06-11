package Stylus::Controller::Create;
use Moose;
use namespace::autoclean;

use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'stylus/create');

=head1 NAME

Stylus::Controller::Create - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    
    if ( $c->controller && $c->controller eq 'Login' ) {
        return 1;    
    }
    
    unless ( $c->user_exists ) {
        $c->log->debug( " User does not exist - redirect to login page ...");
        $c->response->redirect($c->uri_for('/stylus/login'));
        return 0;
    }
    
    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';	
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'create.tt';
	$c->stash->{righthalf} = 'createright.tt';
}

=head2 add

=cut

sub add :Local {
    my ( $self, $c ) = @_;

    my $type    = $c->request->params->{type};
    my $date    = $c->request->params->{date};
    my $title   = $c->request->params->{title};
    my $article = $c->request->params->{article};
    
    my $stylus_article = $c->model('DB::Article')->create(
        {
            type       => $type,
            event_date => $date,
            title      => $title,
            content    => $article,
        }
    );
    
    $c->stash->{current_view} = 'JSON_Service';
    if ( $stylus_article ) {
        $c->log->debug('Create article - worked');
        $c->stash->{json} = {
            success => 1,
        };
    }
    else {
        $c->log->debug('Create article - an error has occurred');
        $c->stash->{json} = {
            success => 0,
        };
    }
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
