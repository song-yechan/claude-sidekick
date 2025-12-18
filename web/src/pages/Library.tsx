import { BookOpen, Trash2 } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useBooks } from "@/hooks/useBooks";
import { useCategories } from "@/hooks/useCategories";
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

export default function Library() {
  const { books, deleteBook } = useBooks();
  const { categories } = useCategories();

  const handleDeleteBook = (bookId: string, bookTitle: string) => {
    deleteBook(bookId);
    toast.success(`"${bookTitle}"이(가) 삭제되었습니다`);
  };

  // 카테고리 미등록 책들
  const uncategorizedBooks = books.filter(book => book.categoryIds.length === 0);
  
  // 카테고리별 책들
  const categorizedBooks = categories.map(category => ({
    category,
    books: books.filter(book => book.categoryIds.includes(category.id))
  })).filter(item => item.books.length > 0);

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-foreground">내 서재</h1>
          <span className="text-sm text-muted-foreground">
            {books.length}권
          </span>
        </div>
      </header>

      {/* Content */}
      <div className="p-4 space-y-6">
        {books.length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center">
              <BookOpen className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-muted-foreground mb-2">
                아직 등록된 책이 없습니다
              </p>
              <p className="text-sm text-muted-foreground">
                검색 탭에서 책을 추가해보세요
              </p>
            </CardContent>
          </Card>
        ) : (
          <>
            {/* 카테고리 미등록 섹션 */}
            {uncategorizedBooks.length > 0 && (
              <section>
                <h2 className="text-sm font-semibold text-muted-foreground mb-3">
                  카테고리 미분류 ({uncategorizedBooks.length})
                </h2>
                <div className="space-y-2">
                  {uncategorizedBooks.map((book) => (
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
                              <AlertDialog>
                                <AlertDialogTrigger asChild>
                                  <Button variant="ghost" size="sm" className="gap-1">
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
                  ))}
                </div>
              </section>
            )}

            {/* 카테고리별 섹션 */}
            {categorizedBooks.map(({ category, books: categoryBooks }) => (
              <section key={category.id}>
                <div className="flex items-center gap-2 mb-3">
                  <div
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: category.color }}
                  />
                  <h2 className="text-sm font-semibold text-foreground">
                    {category.name} ({categoryBooks.length})
                  </h2>
                </div>
                <div className="space-y-2">
                  {categoryBooks.map((book) => (
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
                              <AlertDialog>
                                <AlertDialogTrigger asChild>
                                  <Button variant="ghost" size="sm" className="gap-1">
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
                  ))}
                </div>
              </section>
            ))}
          </>
        )}
      </div>
    </div>
  );
}
