import { Category } from "@/types/book";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/contexts/AuthContext";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useToast } from "./use-toast";

const CATEGORY_COLORS = [
  "#ef4444", // red
  "#f97316", // orange
  "#f59e0b", // amber
  "#84cc16", // lime
  "#10b981", // emerald
  "#06b6d4", // cyan
  "#3b82f6", // blue
  "#8b5cf6", // violet
  "#ec4899", // pink
];

export function useCategories() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const { data: categories = [] } = useQuery({
    queryKey: ["categories", user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      const { data, error } = await supabase
        .from("categories")
        .select("*")
        .eq("user_id", user.id)
        .order("created_at", { ascending: false });

      if (error) throw error;
      return data.map(cat => ({
        id: cat.id,
        name: cat.name,
        color: cat.color,
        createdAt: cat.created_at,
      })) as Category[];
    },
    enabled: !!user,
  });

  const addCategoryMutation = useMutation({
    mutationFn: async (name: string) => {
      if (!user) throw new Error("User not authenticated");

      const { data, error } = await supabase
        .from("categories")
        .insert({
          user_id: user.id,
          name,
          color: CATEGORY_COLORS[categories.length % CATEGORY_COLORS.length],
        })
        .select()
        .single();

      if (error) throw error;
      return {
        id: data.id,
        name: data.name,
        color: data.color,
        createdAt: data.created_at,
      } as Category;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["categories", user?.id] });
      toast({ title: "카테고리가 추가되었습니다" });
    },
    onError: () => {
      toast({ title: "카테고리 추가 실패", variant: "destructive" });
    },
  });

  const updateCategoryMutation = useMutation({
    mutationFn: async ({ id, updates }: { id: string; updates: Partial<Category> }) => {
      const { error } = await supabase
        .from("categories")
        .update(updates)
        .eq("id", id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["categories", user?.id] });
    },
  });

  const deleteCategoryMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from("categories")
        .delete()
        .eq("id", id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["categories", user?.id] });
      toast({ title: "카테고리가 삭제되었습니다" });
    },
  });

  const getCategoryById = (id: string) => {
    return categories.find(cat => cat.id === id);
  };

  return {
    categories,
    addCategory: addCategoryMutation.mutateAsync,
    updateCategory: (id: string, updates: Partial<Category>) => 
      updateCategoryMutation.mutate({ id, updates }),
    deleteCategory: deleteCategoryMutation.mutate,
    getCategoryById,
  };
}
