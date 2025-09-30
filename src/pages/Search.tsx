import { useState } from "react";
import { Search as SearchIcon, Loader2, Plus } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useBooks } from "@/hooks/useBooks";
import { searchBooks } from "@/services/bookApi";
import { BookSearchResult } from "@/types/book";
import { toast } from "sonner";

export default function Search() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<BookSearchResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const { addBook, books } = useBooks();

  const handleSearch = async (searchQuery: string) => {
    if (!searchQuery.trim()) {
      setResults([]);
      return;
    }

    setIsSearching(true);
    try {
      const searchResults = await searchBooks(searchQuery);
      setResults(searchResults);
    } catch (error) {
      console.error("Search error:", error);
      toast.error("검색 중 오류가 발생했습니다");
    } finally {
      setIsSearching(false);
    }
  };

  const handleAddBook = (result: BookSearchResult) => {
    // Check if book already exists
    const existingBook = books.find(b => b.isbn === result.isbn);
    if (existingBook) {
      toast.error("이미 추가된 책입니다");
      return;
    }

    addBook({
      isbn: result.isbn,
      title: result.title,
      author: result.author,
      publisher: result.publisher,
      publishDate: result.publishDate,
      coverImage: result.coverImage,
      description: result.description,
      categoryIds: [],
    });

    toast.success(`"${result.title}"이(가) 추가되었습니다`);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <h1 className="text-xl font-bold text-foreground">책 검색</h1>
      </header>

      {/* Search input */}
      <div className="p-4">
        <div className="relative">
          <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="책 제목, 저자, ISBN으로 검색..."
            className="pl-9"
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              handleSearch(e.target.value);
            }}
          />
        </div>
      </div>

      {/* Search results */}
      <div className="px-4 pb-4 space-y-3">
        {isSearching && (
          <Card>
            <CardContent className="p-6 flex items-center justify-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" />
              <span className="text-sm text-muted-foreground">검색 중...</span>
            </CardContent>
          </Card>
        )}

        {!isSearching && results.length === 0 && query && (
          <Card>
            <CardContent className="p-6 text-center">
              <p className="text-muted-foreground">검색 결과가 없습니다</p>
            </CardContent>
          </Card>
        )}

        {!isSearching && results.length === 0 && !query && (
          <Card>
            <CardContent className="p-8 text-center">
              <SearchIcon className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-muted-foreground">책을 검색해보세요</p>
            </CardContent>
          </Card>
        )}

        {!isSearching && results.map((result) => (
          <Card key={result.isbn}>
            <CardContent className="p-4">
              <div className="flex gap-3">
                {result.coverImage && (
                  <img 
                    src={result.coverImage} 
                    alt={result.title}
                    className="w-16 h-24 object-cover rounded"
                  />
                )}
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-foreground line-clamp-2 mb-1">
                    {result.title}
                  </h3>
                  <p className="text-sm text-muted-foreground mb-1">
                    {result.author}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {result.publisher} · {result.publishDate}
                  </p>
                  <Button 
                    size="sm" 
                    className="mt-3 gap-1"
                    onClick={() => handleAddBook(result)}
                  >
                    <Plus className="h-3 w-3" />
                    추가
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
