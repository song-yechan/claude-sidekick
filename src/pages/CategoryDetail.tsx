import { useParams, useNavigate } from "react-router-dom";
import { useCategories } from "@/hooks/useCategories";
import { useBooks } from "@/hooks/useBooks";
import { ArrowLeft, Plus, Trash2, BookOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { toast } from "sonner";

export default function CategoryDetail() {
  const { categoryId } = useParams<{ categoryId: string }>();
  const navigate = useNavigate();
  const { getCategoryById } = useCategories();
  const { getBooksByCategory, deleteBook, updateBook } = useBooks();

  const category = categoryId ? getCategoryById(categoryId) : null;
  const books = categoryId ? getBooksByCategory(categoryId) : [];

  if (!category) {
    return (
      <div className="min-h-screen bg-background">
        <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate("/categories")}
            >
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <h1 className="text-xl font-bold text-foreground">카테고리를 찾을 수 없습니다</h1>
          </div>
        </header>
      </div>
    );
  }

  const handleRemoveBookFromCategory = (bookId: string, bookTitle: string) => {
    const book = books.find(b => b.id === bookId);
    if (!book) return;

    const updatedCategoryIds = book.categoryIds.filter(id => id !== categoryId);
    updateBook(bookId, { categoryIds: updatedCategoryIds });
    toast.success(`"${bookTitle}"이(가) 카테고리에서 제거되었습니다`);
  };

  const handleDeleteBook = (bookId: string, bookTitle: string) => {
    deleteBook(bookId);
    toast.success(`"${bookTitle}"이(가) 삭제되었습니다`);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <div className="flex items-center gap-3 mb-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate("/categories")}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div className="flex items-center gap-2 flex-1">
            <div 
              className="w-4 h-4 rounded-full" 
              style={{ backgroundColor: category.color }}
            />
            <h1 className="text-xl font-bold text-foreground">{category.name}</h1>
          </div>
        </div>
        <div className="flex items-center justify-between pl-12">
          <span className="text-sm text-muted-foreground">
            {books.length}권
          </span>
          <Button 
            size="sm"
            onClick={() => navigate('/search', { state: { categoryId } })}
            className="gap-2"
          >
            <Plus className="h-4 w-4" />
            책 추가
          </Button>
        </div>
      </header>

      {/* Content */}
      <div className="p-4 space-y-3">
        {books.length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center">
              <BookOpen className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-muted-foreground mb-2">
                아직 등록된 책이 없습니다
              </p>
              <p className="text-sm text-muted-foreground">
                책을 추가해보세요
              </p>
            </CardContent>
          </Card>
        ) : (
          books.map((book) => (
            <Card key={book.id}>
              <CardContent className="p-4">
                <div className="flex gap-3">
                  {book.coverImage && (
                    <img 
                      src={book.coverImage} 
                      alt={book.title}
                      className="w-16 h-24 object-cover rounded"
                    />
                  )}
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-foreground line-clamp-2 mb-1">
                      {book.title}
                    </h3>
                    <p className="text-sm text-muted-foreground mb-2">
                      {book.author}
                    </p>
                    <div className="flex gap-2 mt-2">
                      <Button 
                        variant="ghost" 
                        size="sm" 
                        className="gap-1"
                        onClick={() => handleRemoveBookFromCategory(book.id, book.title)}
                      >
                        제거
                      </Button>
                      <AlertDialog>
                        <AlertDialogTrigger asChild>
                          <Button variant="ghost" size="sm" className="gap-1 text-destructive hover:text-destructive">
                            <Trash2 className="h-3 w-3" />
                            삭제
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>책을 삭제하시겠습니까?</AlertDialogTitle>
                            <AlertDialogDescription>
                              "{book.title}"과 관련된 모든 노트도 함께 삭제됩니다.
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>취소</AlertDialogCancel>
                            <AlertDialogAction onClick={() => handleDeleteBook(book.id, book.title)}>
                              삭제
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
