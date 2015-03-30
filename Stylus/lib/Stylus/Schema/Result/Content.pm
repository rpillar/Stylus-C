use utf8;
package Stylus::Schema::Result::Content;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Stylus::Schema::Result::Content

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

=head1 TABLE: C<content>

=cut

__PACKAGE__->table("content");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 type_id

  data_type: 'integer'
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 publish

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 domain_id

  data_type: 'integer'
  is_nullable: 1

=head2 content_date

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "type_id",
  { data_type => "integer", is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "publish",
  { data_type => "char", is_nullable => 1, size => 1 },
  "domain_id",
  { data_type => "integer", is_nullable => 1 },
  "content_date",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-03-30 19:09:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e576Hnp6098FR1NKp9VM/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
