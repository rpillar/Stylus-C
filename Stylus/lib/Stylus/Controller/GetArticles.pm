package Stylus::Controller::GetArticles;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Text::Markdown 'markdown';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Stylus::Controller::Articles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

__PACKAGE__->config(
    namespace => 'stylus/get',
    action => {
        '*' => {
            # Attributes common to all actions
            # in this controller
            Consumes => 'JSON',
            Path => '',
        }
    }
);
 
# end action is always called at the end of the route
sub end :Private {
    my ( $self, $c ) = @_;
    # Render the stash using our JSON view
    $c->forward($c->view('JSON_Service'));
}
 
# We use the error action to handle errors
sub error :Private {
    my ( $self, $c, $code, $reason ) = @_;
    $reason ||= 'Unknown Error';
    $code ||= 500;
 
    $c->res->status($code);
    # Error text is rendered as JSON as well
    $c->stash->{data} = { error => $reason };
}

=head2 get

=cut

sub articles_list :GET :Args(0) {
    my ( $self, $c ) = @_;
    
 	# get articles data
	$c->stash->{articles} = [ map { id => $_->id, type => $_->type, title => $_->title  }, $c->model('DB::Article')->all ];
}

1;
