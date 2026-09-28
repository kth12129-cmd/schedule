-- 업무 일정 앱 : Supabase 초기 설정
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 Run 하세요. 한 번만 실행하면 됩니다.

create table if not exists public.app_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

-- 각자 자기 행만 읽고 쓸 수 있게 한다
drop policy if exists "own row select" on public.app_state;
create policy "own row select" on public.app_state
  for select using (auth.uid() = user_id);

drop policy if exists "own row insert" on public.app_state;
create policy "own row insert" on public.app_state
  for insert with check (auth.uid() = user_id);

drop policy if exists "own row update" on public.app_state;
create policy "own row update" on public.app_state
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own row delete" on public.app_state;
create policy "own row delete" on public.app_state
  for delete using (auth.uid() = user_id);

-- 다른 기기의 변경을 실시간으로 받기 위해 Realtime 에 등록
alter publication supabase_realtime add table public.app_state;
alter table public.app_state replica identity full;
