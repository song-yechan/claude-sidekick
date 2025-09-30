import { BookOpen, Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useNavigate } from "react-router-dom";
import { useBooks } from "@/hooks/useBooks";
import { useNotes } from "@/hooks/useNotes";
import { cn } from "@/lib/utils";

// GitHub contribution calendar 스타일
const ActivityCalendar = ({ books }: { books: any[] }) => {
  const weeks = 12; // 12주
  const today = new Date();
  
  // 날짜별 활동 맵 생성
  const activityMap = new Map<string, number>();
  books.forEach(book => {
    const date = new Date(book.addedAt).toISOString().split('T')[0];
    activityMap.set(date, (activityMap.get(date) || 0) + 1);
  });

  // 그리드 생성 (12주 x 7일)
  const grid = [];
  for (let week = weeks - 1; week >= 0; week--) {
    const weekDays = [];
    for (let day = 0; day < 7; day++) {
      const date = new Date(today);
      date.setDate(date.getDate() - (week * 7 + (6 - day)));
      const dateStr = date.toISOString().split('T')[0];
      const count = activityMap.get(dateStr) || 0;
      weekDays.push({ date: dateStr, count });
    }
    grid.push(weekDays);
  }

  const getIntensity = (count: number) => {
    if (count === 0) return "bg-muted";
    if (count === 1) return "bg-primary/30";
    if (count === 2) return "bg-primary/60";
    return "bg-primary";
  };

  return (
    <div className="space-y-2">
      <h3 className="text-sm font-medium text-foreground">독서 활동</h3>
      <div className="flex gap-1 overflow-x-auto pb-2">
        {grid.map((week, weekIdx) => (
          <div key={weekIdx} className="flex flex-col gap-1">
            {week.map((day, dayIdx) => (
              <div
                key={`${weekIdx}-${dayIdx}`}
                className={cn(
                  "w-3 h-3 rounded-sm transition-colors",
                  getIntensity(day.count)
                )}
                title={`${day.date}: ${day.count}권`}
              />
            ))}
          </div>
        ))}
      </div>
      <p className="text-xs text-muted-foreground">
        최근 {weeks}주간 독서 활동
      </p>
    </div>
  );
};

export default function Home() {
  const navigate = useNavigate();
  const { books } = useBooks();
  const { notes } = useNotes();

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
        </div>
      </header>

      {/* Content */}
      <div className="p-4 space-y-6">
        {/* Welcome section */}
        <section className="text-center py-8">
          <div className="mb-4">
            <BookOpen className="h-16 w-16 text-primary mx-auto mb-3" />
          </div>
          <h2 className="text-2xl font-bold text-foreground mb-2">
            독서 노트를 시작하세요
          </h2>
          <p className="text-muted-foreground mb-6">
            책을 검색하고 나만의 독서 기록을 남겨보세요
          </p>
          <Button 
            onClick={() => navigate('/search')} 
            size="lg" 
            className="gap-2"
          >
            <Plus className="h-5 w-5" />
            책 추가하기
          </Button>
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
                <Card key={book.id}>
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

        {/* Activity Calendar */}
        <section>
          <Card>
            <CardContent className="p-4">
              <ActivityCalendar books={books} />
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
      </div>
    </div>
  );
}
