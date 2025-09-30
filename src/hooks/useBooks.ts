import { Book } from "@/types/book";
import { useLocalStorage } from "./useLocalStorage";

export function useBooks() {
  const [books, setBooks] = useLocalStorage<Book[]>("books", []);

  const addBook = (book: Omit<Book, "id" | "addedAt">) => {
    const newBook: Book = {
      ...book,
      id: crypto.randomUUID(),
      addedAt: new Date().toISOString(),
    };
    setBooks([...books, newBook]);
    return newBook;
  };

  const updateBook = (id: string, updates: Partial<Book>) => {
    setBooks(books.map(book => 
      book.id === id ? { ...book, ...updates } : book
    ));
  };

  const deleteBook = (id: string) => {
    setBooks(books.filter(book => book.id !== id));
  };

  const getBookById = (id: string) => {
    return books.find(book => book.id === id);
  };

  const getBooksByCategory = (categoryId: string) => {
    return books.filter(book => book.categoryIds.includes(categoryId));
  };

  return {
    books,
    addBook,
    updateBook,
    deleteBook,
    getBookById,
    getBooksByCategory,
  };
}
