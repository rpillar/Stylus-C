use utf8;
package Stylus::Schema::Result::Partial;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Stylus::Schema::Result::Partial

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<partials>

=cut

__PACKAGE__->table("partials");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 domain_id

  data_type: 'integer'
  is_nullable: 1

=head2 type_id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'char'
  is_nullable: 1
  size: 20

=head2 partial

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'char'
  is_nullable: 1
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "domain_id",
  { data_type => "integer", is_nullable => 1 },
  "type_id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "char", is_nullable => 1, size => 20 },
  "partial",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "char", is_nullable => 1, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-03-30 19:09:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:whh0a830yZag0Gz4s6A4cA

__PACKAGE__->belongs_to(
    domain => 'Stylus::Schema::Result::Domain',
    { 'foreign.id' => 'self.domain_id' },
);

__PACKAGE__->belongs_to(
    partial_type => 'Stylus::Schema::Result::PartialType',
    { 'foreign.id' => 'self.type_id' },
);

sub is_component {
    my $self = shift;

    return ( $self->partial_type->type eq 'Component' ) ? 1 : 0;
}

sub is_layout {
    my $self = shift;

    return ( $self->partial_type->type eq 'Layout' ) ? 1 : 0;
}

sub is_partial {
    my $self = shift;

    return ( $self->partial_type->type eq 'Partial' ) ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;
1;
