package Stylus::Schema::ResultSet::Partial;
use utf8;

use parent 'DBIx::Class::ResultSet';

sub layouts {
    my $self = shift;

    my $me = $self->current_source_alias;
    return $self->search({
        "$me.type_id" => { '=' => 2 }
    });
}

__PACKAGE__;
