-- Maak een avatars bucket aan in Supabase Storage
insert into storage.buckets (id, name, public) 
values ('avatars', 'avatars', true)
on conflict (id) do nothing;


-- Functie om automatisch de avatar_url te updaten in de profiles tabel
create or replace function handle_avatar_upload()
returns trigger as $$
begin
  if NEW.bucket_id = 'avatars' then
    update profiles
    set avatar_url = 'https://openwdsupdemo.sug.lol/storage/v1/object/public/avatars/' || NEW.name
    where id = auth.uid();
  end if;
  return NEW;
end;
$$ language plpgsql;

-- Trigger die wordt geactiveerd bij uploads in de avatars bucket
create or replace trigger avatar_upload_trigger
after insert on storage.objects
for each row
when (NEW.bucket_id = 'avatars')
execute function handle_avatar_upload();

-- RLS Policies (optioneel) voor extra beveiliging
alter table user_profiles enable row level security;

create policy "Allow users to update their own avatar"
on user_profiles
for update
using (auth.uid() = id);
