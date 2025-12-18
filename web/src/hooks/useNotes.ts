import { Note } from "@/types/book";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useToast } from "./use-toast";

export function useNotes() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const { data: notes = [] } = useQuery({
    queryKey: ["notes", user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      const { data, error } = await supabase
        .from("notes")
        .select("*")
        .eq("user_id", user.id)
        .order("created_at", { ascending: false });

      if (error) throw error;
      
      return data.map(note => ({
        id: note.id,
        bookId: note.book_id,
        content: note.content,
        summary: note.summary,
        pageNumber: note.page_number,
        tags: note.tags,
        memo: note.memo,
        createdAt: note.created_at,
        updatedAt: note.updated_at,
      })) as Note[];
    },
    enabled: !!user,
  });

  const addNoteMutation = useMutation({
    mutationFn: async (note: Omit<Note, "id" | "createdAt" | "updatedAt">) => {
      if (!user) throw new Error("User not authenticated");

      const { data, error } = await supabase
        .from("notes")
        .insert({
          user_id: user.id,
          book_id: note.bookId,
          content: note.content,
          summary: note.summary,
          page_number: note.pageNumber,
          tags: note.tags,
          memo: note.memo,
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notes", user?.id] });
      toast({ title: "노트가 추가되었습니다" });
    },
  });

  const updateNoteMutation = useMutation({
    mutationFn: async ({ id, updates }: { id: string; updates: Partial<Note> }) => {
      const { error } = await supabase
        .from("notes")
        .update({
          content: updates.content,
          summary: updates.summary,
          page_number: updates.pageNumber,
          tags: updates.tags,
          memo: updates.memo,
        })
        .eq("id", id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notes", user?.id] });
    },
  });

  const deleteNoteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from("notes")
        .delete()
        .eq("id", id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notes", user?.id] });
      toast({ title: "노트가 삭제되었습니다" });
    },
  });

  const getNotesByBook = (bookId: string) => {
    return notes.filter(note => note.bookId === bookId);
  };

  return {
    notes,
    addNote: addNoteMutation.mutateAsync,
    updateNote: (id: string, updates: Partial<Note>) => 
      updateNoteMutation.mutate({ id, updates }),
    deleteNote: deleteNoteMutation.mutate,
    getNotesByBook,
  };
}
