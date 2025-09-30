import { useState } from "react";
import { FolderOpen, Plus, Edit2, Trash2, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useNavigate } from "react-router-dom";
import { z } from "zod";

const categorySchema = z.object({
  name: z.string().trim().min(1, "카테고리 이름을 입력하세요").max(50, "카테고리 이름은 50자 이하여야 합니다"),
});
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
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
import { useCategories } from "@/hooks/useCategories";
import { useBooks } from "@/hooks/useBooks";
import { toast } from "sonner";

export default function Categories() {
  const navigate = useNavigate();
  const { categories, addCategory, updateCategory, deleteCategory } = useCategories();
  const { books } = useBooks();
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState("");
  const [editingCategory, setEditingCategory] = useState<{ id: string; name: string } | null>(null);

  const handleAddCategory = () => {
    try {
      const validated = categorySchema.parse({ name: newCategoryName });
      addCategory(validated.name);
      setNewCategoryName("");
      setIsAddDialogOpen(false);
      toast.success("카테고리가 생성되었습니다");
    } catch (error) {
      if (error instanceof z.ZodError) {
        toast.error(error.errors[0].message);
      }
    }
  };

  const handleEditCategory = () => {
    if (!editingCategory) return;
    
    try {
      const validated = categorySchema.parse({ name: editingCategory.name });
      updateCategory(editingCategory.id, { name: validated.name });
      setEditingCategory(null);
      setIsEditDialogOpen(false);
      toast.success("카테고리가 수정되었습니다");
    } catch (error) {
      if (error instanceof z.ZodError) {
        toast.error(error.errors[0].message);
      }
    }
  };

  const handleDeleteCategory = (categoryId: string) => {
    deleteCategory(categoryId);
    toast.success("카테고리가 삭제되었습니다");
  };

  const getCategoryBookCount = (categoryId: string) => {
    return books.filter(book => book.categoryIds.includes(categoryId)).length;
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-foreground">카테고리</h1>
          <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-2">
                <Plus className="h-4 w-4" />
                새 카테고리
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>새 카테고리 만들기</DialogTitle>
                <DialogDescription>
                  책을 분류할 카테고리 이름을 입력하세요
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4 py-4">
                <div className="space-y-2">
                  <Label htmlFor="category-name">카테고리 이름</Label>
                  <Input
                    id="category-name"
                    placeholder="예: 소설, 에세이, 자기계발..."
                    value={newCategoryName}
                    onChange={(e) => setNewCategoryName(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') {
                        handleAddCategory();
                      }
                    }}
                    maxLength={50}
                  />
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
                  취소
                </Button>
                <Button onClick={handleAddCategory}>생성</Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </header>

      {/* Content */}
      <div className="p-4 space-y-3">
        {categories.length === 0 ? (
          <Card>
            <CardContent className="p-8 text-center">
              <FolderOpen className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-muted-foreground mb-2">
                생성된 카테고리가 없습니다
              </p>
              <p className="text-sm text-muted-foreground">
                카테고리를 만들어 책을 정리해보세요
              </p>
            </CardContent>
          </Card>
        ) : (
          categories.map((category) => (
            <Card 
              key={category.id}
              className="cursor-pointer hover:bg-muted/50 transition-colors"
              onClick={() => navigate(`/categories/${category.id}`)}
            >
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div 
                    className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${category.color}20` }}
                  >
                    <FolderOpen 
                      className="h-5 w-5" 
                      style={{ color: category.color }}
                    />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-foreground">
                      {category.name}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {getCategoryBookCount(category.id)}권의 책
                    </p>
                  </div>
                  <ChevronRight className="h-5 w-5 text-muted-foreground flex-shrink-0 mr-2" />
                  <div className="flex gap-1" onClick={(e) => e.stopPropagation()}>
                    <Dialog open={isEditDialogOpen && editingCategory?.id === category.id} onOpenChange={(open) => {
                      setIsEditDialogOpen(open);
                      if (!open) setEditingCategory(null);
                    }}>
                      <DialogTrigger asChild>
                        <Button 
                          variant="ghost" 
                          size="icon"
                          onClick={() => setEditingCategory({ id: category.id, name: category.name })}
                        >
                          <Edit2 className="h-4 w-4" />
                        </Button>
                      </DialogTrigger>
                      <DialogContent>
                        <DialogHeader>
                          <DialogTitle>카테고리 수정</DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4 py-4">
                          <div className="space-y-2">
                            <Label htmlFor="edit-category-name">카테고리 이름</Label>
                            <Input
                              id="edit-category-name"
                              value={editingCategory?.name || ""}
                              onChange={(e) => setEditingCategory(
                                editingCategory ? { ...editingCategory, name: e.target.value } : null
                              )}
                              onKeyDown={(e) => {
                                if (e.key === 'Enter') {
                                  handleEditCategory();
                                }
                              }}
                              maxLength={50}
                            />
                          </div>
                        </div>
                        <DialogFooter>
                          <Button variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                            취소
                          </Button>
                          <Button onClick={handleEditCategory}>수정</Button>
                        </DialogFooter>
                      </DialogContent>
                    </Dialog>

                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button variant="ghost" size="icon">
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>카테고리를 삭제하시겠습니까?</AlertDialogTitle>
                          <AlertDialogDescription>
                            "{category.name}" 카테고리가 삭제됩니다. 
                            카테고리에 속한 책들은 삭제되지 않습니다.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>취소</AlertDialogCancel>
                          <AlertDialogAction onClick={() => handleDeleteCategory(category.id)}>
                            삭제
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
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
