package Stylus::Controller::Register;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'stylus/register');

=head1 NAME

Stylus::Controller::Contact - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # set initial content for 'landing' page
    $c->stash->{current_view} = 'TT';
	$c->stash->{template}  = 'index.tt';
	$c->stash->{initial}   = 'register.tt';
	$c->stash->{righthalf} = 'registerright.tt';
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
