package Stylus::Controller::Articles;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'stylus/articles');

=head1 NAME

Stylus::Controller::Articles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    
    if ( $c->controller && $c->controller eq 'Articles' ) {
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
	$c->stash->{initial}   = 'articles.tt';
	$c->stash->{righthalf} = 'articlesright.tt';
}


=head1 AUTHOR

Richard Pillar,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
