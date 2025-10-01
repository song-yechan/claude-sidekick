import { Book } from "@/types/book";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useToast } from "./use-toast";

export function useBooks() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const { data: books = [] } = useQuery({
    queryKey: ["books", user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      const { data, error } = await supabase
        .from("books")
        .select(`
          *,
          book_categories(category_id)
        `)
        .eq("user_id", user.id)
        .order("added_at", { ascending: false });

      if (error) throw error;
      
      return data.map(book => ({
        id: book.id,
        isbn: book.isbn,
        title: book.title,
        author: book.author,
        publisher: book.publisher,
        publishDate: book.publish_date,
        coverImage: book.cover_image,
        description: book.description,
        categoryIds: book.book_categories.map((bc: any) => bc.category_id),
        addedAt: book.added_at,
      })) as Book[];
    },
    enabled: !!user,
  });

  const addBookMutation = useMutation({
    mutationFn: async (book: Omit<Book, "id" | "addedAt">) => {
      if (!user) throw new Error("User not authenticated");

      const { data: bookData, error: bookError } = await supabase
        .from("books")
        .insert({
          user_id: user.id,
          isbn: book.isbn,
          title: book.title,
          author: book.author,
          publisher: book.publisher,
          publish_date: book.publishDate,
          cover_image: book.coverImage,
          description: book.description,
        })
        .select()
        .single();

      if (bookError) throw bookError;

      if (book.categoryIds.length > 0) {
        const { error: categoryError } = await supabase
          .from("book_categories")
          .insert(
            book.categoryIds.map(categoryId => ({
              book_id: bookData.id,
              category_id: categoryId,
            }))
          );

        if (categoryError) throw categoryError;
      }

      return bookData;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["books", user?.id] });
      toast({ title: "책이 추가되었습니다" });
    },
    onError: () => {
      toast({ title: "책 추가 실패", variant: "destructive" });
    },
  });

  const updateBookMutation = useMutation({
    mutationFn: async ({ id, updates }: { id: string; updates: Partial<Book> }) => {
      const { error } = await supabase
        .from("books")
        .update({
          isbn: updates.isbn,
          title: updates.title,
          author: updates.author,
          publisher: updates.publisher,
          publish_date: updates.publishDate,
          cover_image: updates.coverImage,
          description: updates.description,
        })
        .eq("id", id);

      if (error) throw error;

      if (updates.categoryIds) {
        await supabase.from("book_categories").delete().eq("book_id", id);
        
        if (updates.categoryIds.length > 0) {
          const { error: categoryError } = await supabase
            .from("book_categories")
            .insert(
              updates.categoryIds.map(categoryId => ({
                book_id: id,
                category_id: categoryId,
              }))
            );

          if (categoryError) throw categoryError;
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["books", user?.id] });
    },
  });

  const deleteBookMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from("books")
        .delete()
        .eq("id", id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["books", user?.id] });
      toast({ title: "책이 삭제되었습니다" });
    },
  });

  const getBookById = (id: string) => {
    return books.find(book => book.id === id);
  };

  const getBooksByCategory = (categoryId: string) => {
    return books.filter(book => book.categoryIds.includes(categoryId));
  };

  return {
    books,
    addBook: addBookMutation.mutateAsync,
    updateBook: (id: string, updates: Partial<Book>) => 
      updateBookMutation.mutate({ id, updates }),
    deleteBook: deleteBookMutation.mutate,
    getBookById,
    getBooksByCategory,
  };
}
