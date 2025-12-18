import { BookSearchResult } from "@/types/book";
import { supabase } from "@/integrations/supabase/client";

export async function searchBooks(query: string): Promise<BookSearchResult[]> {
  if (!query.trim()) {
    return [];
  }

  try {
    const { data, error } = await supabase.functions.invoke('book-search', {
      body: { query },
    });

    if (error) {
      console.error('Book search error:', error);
      throw error;
    }

    return data?.items || [];
  } catch (error) {
    console.error('Failed to search books:', error);
    throw error;
  }
}

export async function getBookByISBN(isbn: string): Promise<BookSearchResult | null> {
  try {
    const { data, error } = await supabase.functions.invoke('book-search', {
      body: { query: isbn },
    });

    if (error) {
      console.error('Book lookup error:', error);
      return null;
    }

    const items = data?.items || [];
    return items.find((book: BookSearchResult) => book.isbn === isbn) || null;
  } catch (error) {
    console.error('Failed to get book by ISBN:', error);
    return null;
  }
}
