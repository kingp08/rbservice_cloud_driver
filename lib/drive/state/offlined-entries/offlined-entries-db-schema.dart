const OFFLINED_ENTRIES_DB_SCHEMA = '''
create table entries ( 
  id integer primary key,
  name text not null,
  description text,
  file_name text not null,
  mime text,
  file_size integer,
  parent_id integer,
  password text,
  created_at text,
  updated_at text,
  deleted_at text,
  path text,
  disk_prefix text,
  type text,
  extension text,
  public tinyint unsigned,
  thumbnail tinyint unsigned,
  workspace_id int unsigned,
  hash text not null,
  url text,
  users text,
  tags text,
  permissions text,
  download_fingerprint text
)
''';
