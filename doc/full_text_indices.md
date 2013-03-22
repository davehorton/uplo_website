# Full Text Indices

DO NOT change the default schema format to SQL. These can be manually created in each environment via 'rails db'.

```
create index on galleries using gin(to_tsvector('english', name));
create index on galleries using gin(to_tsvector('english', description));
create index on galleries using gin(to_tsvector('english', keyword));

create index on images using gin(to_tsvector('english', name));
create index on images using gin(to_tsvector('english', description));
create index on images using gin(to_tsvector('english', keyword));

create index on users using gin(to_tsvector('english', first_name));
create index on users using gin(to_tsvector('english', last_name));
create index on users using gin(to_tsvector('english', username));
create index on users using gin(to_tsvector('english', email));
```
