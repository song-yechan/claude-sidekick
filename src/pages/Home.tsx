import { BookOpen, Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useNavigate } from "react-router-dom";
import { useBooks } from "@/hooks/useBooks";
import { useNotes } from "@/hooks/useNotes";
import { useCategories } from "@/hooks/useCategories";

export default function Home() {
  const navigate = useNavigate();
  const { books } = useBooks();
  const { notes } = useNotes();
  const { categories } = useCategories();

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

        {/* Quick stats */}
        <section className="grid grid-cols-3 gap-3">
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
          <Card>
            <CardHeader className="p-4">
              <CardTitle className="text-2xl font-bold text-foreground">
                {categories.length}
              </CardTitle>
            </CardHeader>
            <CardContent className="p-4 pt-0">
              <p className="text-xs text-muted-foreground">카테고리</p>
            </CardContent>
          </Card>
        </section>
      </div>
    </div>
  );
}
