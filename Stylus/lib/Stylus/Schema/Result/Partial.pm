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

=head2 domain

  data_type: 'char'
  is_nullable: 1
  size: 25

=head2 type

  data_type: 'char'
  is_nullable: 1
  size: 10

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
  "domain",
  { data_type => "char", is_nullable => 1, size => 25 },
  "type",
  { data_type => "char", is_nullable => 1, size => 10 },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-02-05 09:01:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+PxZjwRZkRhrZzxUjRWXRw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
