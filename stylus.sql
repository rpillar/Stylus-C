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
    username text,
    password text,
    email_address text,
    first_name text,
    last_name text,
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

insert into users values (1, 'rpillar', 'zsawq21q', 'rpillar@somewhere.com', 'Richard', 'Pillar', 1);
insert into users values (2, 'demo', 'demo', 'demo@somewhere.com', 'demo', 'demo', 1);
insert into role values (1, 'user');
insert into role values (2, 'admin');
insert into user_role values (1, 2);
insert into user_role values (2, 1);
