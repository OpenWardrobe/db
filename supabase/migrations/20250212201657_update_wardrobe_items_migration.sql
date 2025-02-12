-- 🚨 Drop all dependent views before modifying wardrobe_item
drop view if exists v_recent_usage cascade;
drop view if exists v_user_outfits cascade;
drop view if exists v_user_wardrobe cascade;


-- Drop pic table
drop table if exists pic;

-- Ensure the wardrobe_items bucket exists and is private
insert into storage.buckets (id, name, public) 
values ('wardrobe_items', 'wardrobe_items', false)
on conflict (id) do nothing;

-- Drop the name column from wardrobe_item (if it exists)
alter table wardrobe_item drop column if exists name;

-- Add image_path column to store private file path
alter table wardrobe_item add column if not exists image_path text;

-- Function to automatically insert a wardrobe item when a file is uploaded
create or replace function handle_wardrobe_item_upload()
returns trigger as $$
begin
  if NEW.bucket_id = 'wardrobe_items' then
    insert into wardrobe_item (user_id, image_path, created_at)
    values (
      auth.uid(), 
      NEW.name,  -- Store only the file path (since items are private)
      now()
    );
  end if;
  return NEW;
end;
$$ language plpgsql;

-- Ensure trigger executes when a new file is uploaded to wardrobe_items
create or replace trigger wardrobe_item_upload_trigger
after insert on storage.objects
for each row
when (NEW.bucket_id = 'wardrobe_items')
execute function handle_wardrobe_item_upload();

-- Ensure Row-Level Security (RLS) is enabled for wardrobe_item
alter table wardrobe_item enable row level security;

-- Policy to allow users to insert their own wardrobe items
create policy "Allow users to insert their own wardrobe items"
on wardrobe_item
for insert
with check (auth.uid() = user_id);

-- Policy to allow users to view their own wardrobe items
create policy "Allow users to view their own wardrobe items"
on wardrobe_item
for select
using (auth.uid() = user_id);
