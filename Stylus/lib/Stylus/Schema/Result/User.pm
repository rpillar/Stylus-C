use utf8;
package Stylus::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Stylus::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'text'
  is_nullable: 1

=head2 first_name

  data_type: 'text'
  is_nullable: 1

=head2 last_name

  data_type: 'text'
  is_nullable: 1

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 domain

  data_type: 'char'
  is_nullable: 1
  size: 25

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "text", is_nullable => 1 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "email_address",
  { data_type => "text", is_nullable => 1 },
  "first_name",
  { data_type => "text", is_nullable => 1 },
  "last_name",
  { data_type => "text", is_nullable => 1 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "domain",
  { data_type => "char", is_nullable => 1, size => 25 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_role_roles

Type: has_many

Related object: L<Stylus::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_role_roles",
  "Stylus::Schema::Result::UserRole",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_role_users

Type: has_many

Related object: L<Stylus::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_role_users",
  "Stylus::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_role_users> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_role_users", "role");

=head2 users

Type: many_to_many

Composing rels: L</user_role_roles> -> user

=cut

__PACKAGE__->many_to_many("users", "user_role_roles", "user");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-09-22 15:09:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6zlZU5GDmtPXRN1FcJg0LQ

__PACKAGE__->many_to_many(roles => 'user_roles', 'role');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
