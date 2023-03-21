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
create table badges(id bigserial primary key, user_id bigserial references users(id), name varchar(64), date timestamp default now(),
					class smallint not null, tag_based boolean default false);


create table post_types(id smallint primary key, name varchar(128));

insert into post_types(id, name) values(1, 'question'), (2, 'answer'), (3, 'orphaned tag wiki'),
	(4, 'tag wiki excerpt'), (5, 'tag wiki'), (6, 'moderator nomination'), (7, 'wiki placeholder'),
	(8, 'privilege wiki');


-- post_type_id
-- 1 = question
-- 2 = answer
-- 3 = Orphaned tag wiki
-- 4 = Tag wiki excerpt
-- 5 = Tag wiki
-- 6 = Moderator nomination
-- 7 = "Wiki placeholder" (seems to only be the election description)
-- 8 = Privilege wiki
-- we are fixing body to 100KB
create table posts(id bigserial primary key, post_type_id smallint references post_types(id), accepted_answer_id bigint references posts(id),
	parent_id bigint references posts(id), creation_date timestamp default now(),
	deletion_date timestamp default null, score bigint, view_count bigint, body varchar(102400),
	owner_user_id bigint references users(id), owner_display_name varchar(64), last_editor_user_id bigint references users(id),
	last_editor_display_name varchar(64), last_edit_date timestamp default null, last_activity_date timestamp default now(),
	title varchar(512), tags varchar(256), answer_count int default 0, comment_count int default 0,
	favorite_count int default 0, closed_date timestamp, community_owned_date timestamp, content_license varchar(128));

-- we are fixing body to 100KB
create table posts_with_deleted(id bigserial primary key, post_type_id smallint references post_types(id),
	accepted_answer_id bigint references posts_with_deleted(id), parent_id bigint references posts_with_deleted(id),
	creation_date timestamp default now(), deletion_date timestamp default null, score bigint, view_count bigint,
	body varchar(102400), owner_user_id bigint references users(id), owner_display_name varchar(64), last_editor_user_id bigint
	references users(id), last_editor_display_name varchar(64), last_edit_date timestamp default null, last_activity_date
	timestamp default now(), title varchar(512), tags varchar(256), answer_count int default 0, comment_count int default 0,
	favorite_count int default 0, closed_date timestamp, community_owned_date timestamp, content_license varchar(128));

create table comments(id bigserial primary key, post_id bigint, score int, text varchar(1024), creation_date timestamp default now(),
	user_display_name varchar(64), user_id bigint);


create table post_notices(id bigserial primary key, post_id bigint references posts(id), post_notice_type_id bigint
	references post_history_types(id), creation_date timestamp default now(), deletion_date timestamp, expiry_date timestamp,
	body varchar(1024), owner_user_id bigint references users(id), deletion_user_id bigint references users(id));

-- post notice type id
-- 1 citation needed
-- 2 current event
-- 3 insufficient explantion
-- 10 current answers are outdated
-- 11 draw attention
-- 12 improve details
-- 13 authoritative reference needed
-- 14 canonical answer required
-- 15 reward existing answer
-- 20 content dispute
-- 21 offtopic comments
-- 22 historical significance
-- 23 wiki answer
-- 24 policy lock
-- 25 recommended answer
-- 26 Posted by Recognized Member/Admin
-- 27 Endorsed edit
-- 28 Obsolete
-- class_id
-- 1 Historical lock
-- 2 bounty
-- 4 moderator notice
-- post_notice_duration_id
-- -1 No duration specified
-- 1 7 days(bounty)
create table post_notice_types(id bigserial primary key, class_id int, name varchar(128),
	body varchar(1024), is_hidden boolean default false, predefined boolean default false, post_notice_duration_id int);


create table tags(id bigserial primary key, tag_name varchar(64) unique, count bigint default 0, excerpt_post_id bigint references posts(id),
	wiki_post_id bigint references posts(id), is_moderator_only boolean default false, is_required boolean default false);

create table post_tags(post_id bigint primary key references posts(id), tag_id bigint references tags(id));


create table tag_synonyms(id bigserial primary key, source_tag_name varchar(64) references tags(tag_name),
	target_tag_name varchar(64) references tags(tag_name), creation_date timestamp default now(), owner_user_id bigint references users(id),
	auto_rename_count int default 0, last_auto_rename timestamp, score int, approved_by_user_id bigint references users(id),
	approval_date timestamp);

-- post_id source post id
-- related_post_id target/related post id
-- 1 = Linked (PostId contains a link to RelatedPostId)
-- 3 = Duplicate (PostId is a duplicate of RelatedPostId)
create table post_links(id bigserial primary key, creation_date timestamp, post_id bigint references posts(id),
	related_post_id bigint references posts(id), link_type_id int);

create table post_history_types(id serial primary key, name varchar(128));

-- 1 = Initial Title - initial title (questions only)
-- 2 = Initial Body - initial post raw body text
-- 3 = Initial Tags - initial list of tags (questions only)
-- 4 = Edit Title - modified title (questions only)
-- 5 = Edit Body - modified post body (raw markdown)
-- 6 = Edit Tags - modified list of tags (questions only)
-- 7 = Rollback Title - reverted title (questions only)
-- 8 = Rollback Body - reverted body (raw markdown)
-- 9 = Rollback Tags - reverted list of tags (questions only)
-- 10 = Post Closed - post voted to be closed
-- 11 = Post Reopened - post voted to be reopened
-- 12 = Post Deleted - post voted to be removed
-- 13 = Post Undeleted - post voted to be restored
-- 14 = Post Locked - post locked by moderator
-- 15 = Post Unlocked - post unlocked by moderator
-- 16 = Community Owned - post now community owned
-- 17 = Post Migrated - post migrated - now replaced by 35/36 (away/here)
-- 18 = Question Merged - question merged with deleted question
-- 19 = Question Protected - question was protected by a moderator.
-- 20 = Question Unprotected - question was unprotected by a moderator.
-- 21 = Post Disassociated - OwnerUserId removed from post by admin
-- 22 = Question Unmerged - answers/votes restored to previously merged question
-- 24 = Suggested Edit Applied
-- 25 = Post Tweeted
-- 31 = Comment discussion moved to chat
-- 33 = Post notice added - comment contains foreign key to PostNotices
-- 34 = Post notice removed - comment contains foreign key to PostNotices
-- 35 = Post migrated away - replaces id 17
-- 36 = Post migrated here - replaces id 17
-- 37 = Post merge source
-- 38 = Post merge destination
-- 50 = Bumped by Community User
-- 52 = Question became hot network question (main) / Hot Meta question (meta)
-- 53 = Question removed from hot network/meta questions by a moderator


insert into post_history_types(id, name) values(1, 'Initial Title'), (2, 'Initial Body'), (3, 'Initial Tags'),
	(4, 'Edit title'), (5, 'Edit Body'), (6, 'Edit Tags'), (7, 'Rollback Title'), (8, 'Rollback Body'),
	(9, 'Roolback Tags'), (10, 'Post Closed'), (11, 'Post Reopened'), (12, 'Post Deleted'), (13, 'Post Undeleted'),
	(14, 'Post Locked'), (15, 'Post Unlocked'), (16, 'Community Owned'), (18, 'Question Merged'), (19, 'Question Protected'),
	(20, 'Question Unprotected'), (21, 'Post Disassociated'), (22, 'Question Unmerged'), (23, 'Suggested Edit Applied'),
	(24, 'Post Tweeted'), ('31', 'Comment discussion moved to chat'), (33, 'Post notice added'),
	(34, 'Post notice removed'), (35, 'Post migrated away'), (36, 'Post migrated here'), (37, 'Post merge source'),
	(38, 'Post merge destination'), (50, 'Bumped by community user');

-- At times more than one type of history record can be recorded by a single action. All of these will
-- be grouped using the same RevisionGUID
-- if post_history_type_id = 10 then comment will contain close reason
-- text -> A raw version of the new value for a given revision
-- - If PostHistoryTypeId in (10,11,12,13,14,15,19,20,35) text column will contain a JSON encoded string with all users who have voted for the PostHistoryTypeId
-- If it is a duplicate close vote, the JSON string will contain an array of original questions as OriginalQuestionIds
-- If PostHistoryTypeId = 17 text column will contain migration details of either from <url> or to <url>
-- user_display_name is populated if a user has been removed and no longer referenced by user Id
create table post_history(id bigserial primary key, post_history_type_id bigint references post_history_types(id),
	post_id bigint references posts(id), revision_guid uuid, creation_date timestamp default now(), user_id bigint
	references users(id), user_display_name varchar(64), comment varchar(512),
	text text, content_license varchar(128));


-- 1 = AcceptedByOriginator
-- 2 = UpMod (AKA upvote)
-- 3 = DownMod (AKA downvote)
-- 4 = Offensive
-- 5 = Favorite (AKA bookmark; UserId will also be populated) feature removed after October 2022 / replaced by Saves
-- 6 = Close (effective 2013-06-25: Close votes are only stored in table: PostHistory)
-- 7 = Reopen
-- 8 = BountyStart (UserId and BountyAmount will also be populated)
-- 9 = BountyClose (BountyAmount will also be populated)
-- 10 = Deletion
-- 11 = Undeletion
-- 12 = Spam
-- 15 = ModeratorReview (i.e., a moderator looking at a flagged post)
-- 16 = ApproveEditSuggestion
create table vote_types(id serial primary key, name varchar(128));

insert into vote_types(id, name) values(1, 'AcceptedByOriginator'), (2, 'UpVote'), (3, 'DownVote'),
	(4, 'Offensive'), (5, 'Favorite'), (7, 'Reopen'), (8, 'BountyStart'), (9, 'BountyClose'), (10, 'Deletion'),
	(11, 'Undeletion'), (12, 'Spam'), (15, 'ModeratorReview'), (16, 'ApprovedEditSuggestion');

-- user_id: (present only if VoteTypeId in (5,8); -1 if user is deleted)
-- bounty_amount (present only if VoteTypeId in (8,9))
create table votes(id bigserial primary key, post_id bigint references posts(id), vote_type_id int references
	vote_types(id), user_id bigint references users(id), creation_date date, bounty_amount int);