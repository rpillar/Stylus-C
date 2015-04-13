package Stylus::Controller::Logout;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'stylus/logout');

=head1 NAME

Stylus::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Clear the user's state
    $c->logout;

    # set session 'user_domain_id' to '0'
    $c->session->{user_domain_id} = 0;

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/stylus'));
}


=head1 AUTHOR

Richard Pillar,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
