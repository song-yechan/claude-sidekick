-- Reading Nudge System: 알림 설정 및 스트릭 추적 기능 추가
-- user_preferences 테이블 확장 + reading_streaks 테이블 생성

-- 1. user_preferences 테이블에 알림 관련 필드 추가
ALTER TABLE public.user_preferences
ADD COLUMN IF NOT EXISTS notification_enabled BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS notification_time TIME DEFAULT '21:00:00',
ADD COLUMN IF NOT EXISTS smart_nudge_enabled BOOLEAN NOT NULL DEFAULT true;

-- 2. 스트릭 데이터 테이블 생성
CREATE TABLE IF NOT EXISTS public.reading_streaks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  last_active_date DATE,
  streak_start_date DATE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 3. RLS 활성화
ALTER TABLE public.reading_streaks ENABLE ROW LEVEL SECURITY;

-- 4. RLS 정책 설정
CREATE POLICY "Users can view their own streaks"
  ON public.reading_streaks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own streaks"
  ON public.reading_streaks FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own streaks"
  ON public.reading_streaks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 5. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_reading_streaks_user_id
  ON public.reading_streaks(user_id);
CREATE INDEX IF NOT EXISTS idx_reading_streaks_last_active_date
  ON public.reading_streaks(last_active_date);

-- 6. updated_at 자동 갱신 트리거
CREATE TRIGGER set_reading_streaks_updated_at
  BEFORE UPDATE ON public.reading_streaks
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
