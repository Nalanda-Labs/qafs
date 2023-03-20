create table users(id bigserial primary key, reputation bigint default 0, display_name varchar(64), website_url varchar(128), 
				   location varchar(128), about_me text, views bigint, upvotes int, downvotes int, profile_image_url varchar(512),
				   email varchar(256) not null, password_hash varchar(128) not null, salt varchar(256) not null,
				   creation_date timestamp default now(), last_access_date timestamp default now(), title varchar(8),
				   designation varchar(64), git varchar(256), twitter varchar(256), email_verified boolean default false);

-- Class
-- 1 = Gold
-- 2 = Silver
-- 3 = Bronze
-- tag_based it true if badge is based on a tag or false
create table badges(id bigserial primary key, user_id bigserial not null, name varchar(64), date timestamp default now(),
					class smallint not null, tag_based boolean default false);

create table post_types(id smallint primary key, name varchar(128));

insert into post_types(id, name) values(1, 'question'), (2, 'answer'), (3, 'orphaned tag wiki'),
	(4, 'tag wiki excerpt'), (5, 'tag wiki'), (6, 'moderator nomination'), (7, 'wiki placeholder'),
	(8, 'privilege wiki');

delete from post_types;