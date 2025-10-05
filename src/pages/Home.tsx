import { BookOpen, Plus, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useNavigate } from "react-router-dom";
import { useBooks } from "@/hooks/useBooks";
import { useNotes } from "@/hooks/useNotes";
import { useAuth } from "@/contexts/AuthContext";
import { cn } from "@/lib/utils";
import { useEffect, useRef } from "react";

// GitHub contribution calendar 스타일의 연간 활동 히트맵
const ActivityCalendar = ({ notes }: { notes: any[] }) => {
  const scrollRef = useRef<HTMLDivElement>(null);
  const currentYear = new Date().getFullYear();
  const startDate = new Date(currentYear, 0, 1); // 1월 1일
  const endDate = new Date(currentYear, 11, 31); // 12월 31일
  const today = new Date();
  
  // 날짜별 노트 개수 맵 생성
  const activityMap = new Map<string, number>();
  notes.forEach(note => {
    const noteDate = new Date(note.createdAt);
    if (noteDate.getFullYear() === currentYear) {
      const dateStr = noteDate.toISOString().split('T')[0];
      activityMap.set(dateStr, (activityMap.get(dateStr) || 0) + 1);
    }
  });

  // 연도 시작일의 요일 계산 (0 = 일요일)
  const startDay = startDate.getDay();
  
  // 전체 주 수 계산
  const totalDays = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;
  const totalWeeks = Math.ceil((totalDays + startDay) / 7);

  // 그리드 생성
  const grid: { date: string; count: number; isEmpty: boolean }[][] = [];
  
  for (let week = 0; week < totalWeeks; week++) {
    const weekDays: { date: string; count: number; isEmpty: boolean }[] = [];
    
    for (let day = 0; day < 7; day++) {
      const dayOffset = week * 7 + day - startDay;
      
      if (dayOffset < 0 || dayOffset >= totalDays) {
        // 빈 셀
        weekDays.push({ date: '', count: 0, isEmpty: true });
      } else {
        const date = new Date(startDate);
        date.setDate(startDate.getDate() + dayOffset);
        const dateStr = date.toISOString().split('T')[0];
        const count = activityMap.get(dateStr) || 0;
        weekDays.push({ date: dateStr, count, isEmpty: false });
      }
    }
    
    grid.push(weekDays);
  }

  // 5단계 색상 (연한 주황부터 진한 주황)
  const getIntensity = (count: number) => {
    if (count === 0) return "bg-muted";
    if (count <= 3) return "bg-orange-200 dark:bg-orange-900/40";
    if (count <= 8) return "bg-orange-300 dark:bg-orange-800/60";
    if (count <= 15) return "bg-orange-400 dark:bg-orange-700/80";
    if (count <= 30) return "bg-orange-500 dark:bg-orange-600";
    return "bg-orange-600 dark:bg-orange-500";
  };

  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  
  // 각 월의 시작 주 인덱스 계산
  const monthPositions = months.map((_, idx) => {
    const monthStart = new Date(currentYear, idx, 1);
    const daysSinceStart = Math.floor((monthStart.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));
    return Math.floor((daysSinceStart + startDay) / 7);
  });

  // 오늘 날짜의 주 인덱스 계산
  useEffect(() => {
    if (scrollRef.current && today.getFullYear() === currentYear) {
      const daysSinceStart = Math.floor((today.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));
      const todayWeek = Math.floor((daysSinceStart + startDay) / 7);
      
      // 오늘 날짜가 중앙에 오도록 스크롤
      const cellWidth = 12; // w-[10px] + gap-[2px]
      const containerWidth = scrollRef.current.clientWidth;
      const scrollPosition = (todayWeek * cellWidth) - (containerWidth / 2) + (cellWidth / 2);
      
      scrollRef.current.scrollLeft = Math.max(0, scrollPosition);
    }
  }, []);

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-foreground">
          {currentYear}년 독서 활동
        </h3>
        <p className="text-xs text-muted-foreground">
          총 {notes.filter(n => new Date(n.createdAt).getFullYear() === currentYear).length}개 문장 수집
        </p>
      </div>
      
      <div ref={scrollRef} className="overflow-x-auto scrollbar-thin">
        <div className="inline-block min-w-full">
          {/* 월 레이블 */}
          <div className="flex gap-[2px] mb-2 pl-8">
            {grid.map((week, weekIdx) => {
              const monthIdx = monthPositions.findIndex((pos, idx) => {
                const nextPos = monthPositions[idx + 1];
                return pos === weekIdx && (!nextPos || nextPos > weekIdx);
              });
              
              return (
                <div key={weekIdx} className="w-[10px] flex-shrink-0">
                  {monthIdx !== -1 && (
                    <span className="text-[10px] text-muted-foreground whitespace-nowrap">
                      {months[monthIdx]}
                    </span>
                  )}
                </div>
              );
            })}
          </div>

          <div className="flex gap-[2px]">
            {/* 요일 레이블 (월요일, 일요일만) */}
            <div className="flex flex-col gap-[2px] mr-1 flex-shrink-0">
              <div className="h-[10px]"></div>
              <div className="h-[10px] text-[10px] text-muted-foreground flex items-center">Mon</div>
              <div className="h-[10px]"></div>
              <div className="h-[10px]"></div>
              <div className="h-[10px]"></div>
              <div className="h-[10px]"></div>
              <div className="h-[10px] text-[10px] text-muted-foreground flex items-center">Sun</div>
            </div>

            {/* 히트맵 그리드 */}
            {grid.map((week, weekIdx) => (
              <div key={weekIdx} className="flex flex-col gap-[2px] flex-shrink-0">
                {week.map((day, dayIdx) => (
                  <div
                    key={`${weekIdx}-${dayIdx}`}
                    className={cn(
                      "w-[10px] h-[10px] rounded-sm transition-colors",
                      day.isEmpty ? "bg-transparent" : getIntensity(day.count)
                    )}
                    title={day.isEmpty ? "" : `${day.date}: ${day.count}개 수집`}
                  />
                ))}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 범례 */}
      <div className="flex items-center gap-2 text-xs">
        <span className="text-muted-foreground">Less</span>
        <div className="flex gap-1">
          <div className="w-3 h-3 rounded-sm bg-muted" />
          <div className="w-3 h-3 rounded-sm bg-orange-200 dark:bg-orange-900/40" />
          <div className="w-3 h-3 rounded-sm bg-orange-300 dark:bg-orange-800/60" />
          <div className="w-3 h-3 rounded-sm bg-orange-400 dark:bg-orange-700/80" />
          <div className="w-3 h-3 rounded-sm bg-orange-500 dark:bg-orange-600" />
          <div className="w-3 h-3 rounded-sm bg-orange-600 dark:bg-orange-500" />
        </div>
        <span className="text-muted-foreground">More</span>
      </div>
    </div>
  );
};

export default function Home() {
  const navigate = useNavigate();
  const { books } = useBooks();
  const { notes } = useNotes();
  const { signOut } = useAuth();

  const recentBooks = books.slice(-3).reverse();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <BookOpen className="h-6 w-6 text-primary" />
            <h1 className="text-xl font-bold text-foreground">BookScan</h1>
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={signOut}
            className="text-muted-foreground hover:text-foreground"
          >
            <LogOut className="h-5 w-5" />
          </Button>
        </div>
      </header>

      {/* Content */}
      <div className="p-4 space-y-6">
        {/* Activity Calendar */}
        <section>
          <Card>
            <CardContent className="p-4">
              <ActivityCalendar notes={notes} />
            </CardContent>
          </Card>
        </section>

        {/* Quick stats */}
        <section className="grid grid-cols-2 gap-3">
          <Card>
            <CardHeader className="p-4">
              <CardTitle className="text-2xl font-bold text-primary">
                {books.length}
              </CardTitle>
            </CardHeader>
            <CardContent className="p-4 pt-0">
              <p className="text-xs text-muted-foreground">등록한 책</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="p-4">
              <CardTitle className="text-2xl font-bold text-accent">
                {notes.length}
              </CardTitle>
            </CardHeader>
            <CardContent className="p-4 pt-0">
              <p className="text-xs text-muted-foreground">작성한 노트</p>
            </CardContent>
          </Card>
        </section>

        {/* Recent books section */}
        <section>
          <h3 className="text-lg font-semibold text-foreground mb-3">
            최근 추가한 책
          </h3>
          {recentBooks.length === 0 ? (
            <Card>
              <CardContent className="p-6 text-center">
                <p className="text-muted-foreground text-sm">
                  아직 추가된 책이 없습니다
                </p>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-2">
              {recentBooks.map((book) => (
                <Card 
                  key={book.id}
                  className="cursor-pointer hover:bg-accent/10 transition-colors"
                  onClick={() => navigate(`/books/${book.id}`)}
                >
                  <CardContent className="p-3">
                    <div className="flex gap-2 items-center">
                      {book.coverImage && (
                        <img 
                          src={book.coverImage} 
                          alt={book.title}
                          className="w-10 h-14 object-cover rounded"
                        />
                      )}
                      <div className="flex-1 min-w-0">
                        <h4 className="font-medium text-sm text-foreground line-clamp-1">
                          {book.title}
                        </h4>
                        <p className="text-xs text-muted-foreground">
                          {book.author}
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
