PRAGMA foreign_keys = ON;
CREATE TABLE article (
    id integer primary key,
    title text,
    type  integer,
    content text
);
CREATE TABLE article_type (
    id integer primary key,
    type text
);
CREATE TABLE users (
    id integer primary key,
    name text,
    username text,
    password text,
    email_address text,
    active integer
);
CREATE TABLE role (
    id integer primary key,
    role text
);
CREATE TABLE user_role (
    user_id integer references users(id) on delete cascade on update cascade,    
    role_id integer references users(id) on delete cascade on update cascade,
    primary key (user_id, role_id)
);
CREATE TABLE domains (
    id integer primary key,
    name text
);
CREATE TABLE content (
    id integer primary key,
    title text,
    content text,
    publish text,
    domain_id integer,
    content_date text
);
CREATE TABLE content_type (
    id integer primary key,
    type text
);
CREATE TABLE pages_details (
    id integer primary key,
    uid integer,
    domain_id integer,
    path text
);
CREATE TABLE partials (
    id integer primary key,
    domain_id integer,
    type_id integer,
    name text,
    partial text,
    description text
);
CREATE TABLE partial_type (
    id integer primary key,
    type text
);
CREATE TABLE user_domains (
    id integer primary key,
    uid integer,
    domain_id integer
);


insert into users values (1, 'demo1', 'demo1', 'password1', 'demo1@somewhere.com', 1);
insert into users values (2, 'demo2', 'demo1', 'password1', 'demo2@somewhere.com', 1);
insert into role values (1, 'user');
insert into role values (2, 'admin');
insert into user_role values (1, 2);
insert into user_role values (2, 1);
insert into partial_type values (1, 'Layout');
insert into partial_type values (2, 'Component');
insert into partial_type values (3, 'Partial');
