import { useNavigate } from "react-router-dom";
import { useBooks } from "@/hooks/useBooks";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft } from "lucide-react";
import { format } from "date-fns";
import { ko } from "date-fns/locale";

export default function AllBooks() {
  const navigate = useNavigate();
  const { books } = useBooks();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate('/')}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-xl font-bold text-foreground">전체 책</h1>
            <p className="text-xs text-muted-foreground">
              총 {books.length}권
            </p>
          </div>
        </div>
      </header>

      {/* Books List */}
      <div className="p-4">
        {books.length === 0 ? (
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-muted-foreground text-sm">
                아직 추가된 책이 없습니다
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-2">
            {books.map((book) => (
              <Card 
                key={book.id}
                className="cursor-pointer hover:bg-accent/10 transition-colors"
                onClick={() => navigate(`/books/${book.id}`)}
              >
                <CardContent className="p-3">
                  <div className="flex gap-3 items-center">
                    {book.coverImage && (
                      <img 
                        src={book.coverImage} 
                        alt={book.title}
                        className="w-12 h-16 object-cover rounded"
                      />
                    )}
                    <div className="flex-1 min-w-0">
                      <h4 className="font-medium text-sm text-foreground line-clamp-1">
                        {book.title}
                      </h4>
                      <p className="text-xs text-muted-foreground line-clamp-1">
                        {book.author}
                      </p>
                      {book.publisher && (
                        <p className="text-xs text-muted-foreground line-clamp-1">
                          {book.publisher}
                        </p>
                      )}
                      <p className="text-xs text-muted-foreground mt-1">
                        등록일: {format(new Date(book.addedAt), 'yyyy.MM.dd', { locale: ko })}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
