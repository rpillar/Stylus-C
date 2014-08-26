package Stylus::Controller::GetArticles;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Text::Markdown 'markdown';

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

Stylus::Controller::Articles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 get

=cut

sub articles_list : Path('/stylus/articles/articles_list') :Args(0) : ActionClass('REST') { }

sub articles_list_GET {
    my ( $self, $c ) = @_;
    
 	# get articles data
	my @articles = $c->model('DB::Article')->all;
    
    $c->stash->{articles} = \@articles;
}

1;
