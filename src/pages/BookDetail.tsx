import { useParams, useNavigate } from "react-router-dom";
import { useBooks } from "@/hooks/useBooks";
import { useCategories } from "@/hooks/useCategories";
import { useNotes } from "@/hooks/useNotes";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft, Plus, Camera, Trash2, Edit, FolderPlus, Loader2 } from "lucide-react";
import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
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
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Skeleton } from "@/components/ui/skeleton";
import { Checkbox } from "@/components/ui/checkbox";
import { format } from "date-fns";
import { ko } from "date-fns/locale";

export default function BookDetail() {
  const { bookId } = useParams<{ bookId: string }>();
  const navigate = useNavigate();
  const { getBookById, updateBook, deleteBook } = useBooks();
  const { categories } = useCategories();
  const { getNotesByBook, addNote, deleteNote } = useNotes();
  
  const book = getBookById(bookId || '');
  const notes = getNotesByBook(bookId || '');

  const [isAddingNote, setIsAddingNote] = useState(false);
  const [isAddingCategory, setIsAddingCategory] = useState(false);
  const [isProcessingImage, setIsProcessingImage] = useState(false);
  const [isSavingNote, setIsSavingNote] = useState(false);
  const [extractedText, setExtractedText] = useState('');
  const [memo, setMemo] = useState('');
  const [pageNumber, setPageNumber] = useState('');
  const [selectedCategories, setSelectedCategories] = useState<string[]>([]);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);

  if (!book) {
    return (
      <div className="min-h-screen bg-background p-4">
        <p className="text-center text-muted-foreground">책을 찾을 수 없습니다</p>
      </div>
    );
  }

  const compressImage = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = new Image();
        img.onload = () => {
          const canvas = document.createElement('canvas');
          const ctx = canvas.getContext('2d');
          if (!ctx) {
            reject(new Error('Canvas context not available'));
            return;
          }

          // OCR이 가능한 정도로만 압축 (최대 1024px)
          const maxDimension = 1024;
          let width = img.width;
          let height = img.height;

          if (width > maxDimension || height > maxDimension) {
            if (width > height) {
              height = (height / width) * maxDimension;
              width = maxDimension;
            } else {
              width = (width / height) * maxDimension;
              height = maxDimension;
            }
          }

          canvas.width = width;
          canvas.height = height;
          ctx.drawImage(img, 0, 0, width, height);

          // JPEG 품질 0.85로 압축 (OCR에 충분한 품질)
          resolve(canvas.toDataURL('image/jpeg', 0.85));
        };
        img.onerror = () => reject(new Error('Image load failed'));
        img.src = e.target?.result as string;
      };
      reader.onerror = () => reject(new Error('File read failed'));
      reader.readAsDataURL(file);
    });
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsProcessingImage(true);
    try {
      // 이미지 압축
      const compressedBase64 = await compressImage(file);
      
      // Call OCR edge function
      const { data: ocrData, error: ocrError } = await supabase.functions.invoke('ocr-image', {
        body: { imageBase64: compressedBase64 },
      });

      if (ocrError) {
        console.error('OCR error:', ocrError);
        toast.error('이미지 처리 중 오류가 발생했습니다');
        setIsProcessingImage(false);
        return;
      }

      const extractedContent = ocrData.text || '';
      setExtractedText(extractedContent);
      setIsProcessingImage(false);
      toast.success('텍스트가 추출되었습니다. 내용을 확인하고 저장해주세요.');
    } catch (error) {
      console.error('Image upload error:', error);
      toast.error('이미지 업로드 실패');
      setIsProcessingImage(false);
    }
  };

  const handleSaveNote = async () => {
    if (!extractedText.trim()) {
      toast.error('내용을 입력해주세요');
      return;
    }

    setIsSavingNote(true);
    try {
      // Save note without auto-summary
      await addNote({
        bookId: book.id,
        content: extractedText,
        pageNumber: pageNumber ? parseInt(pageNumber) : undefined,
        memo: memo,
        tags: [],
      });

      setIsAddingNote(false);
      setExtractedText('');
      setMemo('');
      setPageNumber('');
      setIsSavingNote(false);
      toast.success('문장이 저장되었습니다');
    } catch (error) {
      console.error('Save note error:', error);
      toast.error('저장 중 오류가 발생했습니다');
      setIsSavingNote(false);
    }
  };

  const handleDeleteNote = (noteId: string) => {
    deleteNote(noteId);
  };

  const handleOpenCategoryDialog = () => {
    setSelectedCategories(book.categoryIds || []);
    setIsAddingCategory(true);
  };

  const handleToggleCategory = (categoryId: string) => {
    setSelectedCategories(prev => 
      prev.includes(categoryId)
        ? prev.filter(id => id !== categoryId)
        : [...prev, categoryId]
    );
  };

  const handleSaveCategories = () => {
    updateBook(book.id, { categoryIds: selectedCategories });
    setIsAddingCategory(false);
    toast.success('카테고리가 업데이트되었습니다');
  };

  const handleDeleteBook = () => {
    deleteBook(book.id);
    navigate('/');
    toast.success('책이 삭제되었습니다');
  };

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
          <div className="flex-1 min-w-0">
            <h1 className="text-lg font-bold text-foreground line-clamp-1">
              {book.title}
            </h1>
            <p className="text-xs text-muted-foreground">{book.author}</p>
          </div>
        </div>
      </header>

      {/* Content */}
      <div className="p-4 space-y-4">
        {/* Category section */}
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <h3 className="text-sm font-semibold text-foreground mb-2">카테고리</h3>
                {book.categoryIds.length === 0 ? (
                  <p className="text-xs text-muted-foreground">카테고리 없음</p>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {book.categoryIds.map(catId => {
                      const category = categories.find(c => c.id === catId);
                      return category ? (
                        <span 
                          key={catId}
                          className="text-xs px-2 py-1 rounded"
                          style={{ backgroundColor: `${category.color}20`, color: category.color }}
                        >
                          {category.name}
                        </span>
                      ) : null;
                    })}
                  </div>
                )}
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={handleOpenCategoryDialog}
                className="gap-1"
              >
                <FolderPlus className="h-4 w-4" />
                편집
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Book Info Card */}
        <Card>
          <CardContent className="p-4">
            <div className="flex gap-3">
              {book.coverImage && (
                <img 
                  src={book.coverImage} 
                  alt={book.title}
                  className="w-20 h-28 object-cover rounded"
                />
              )}
              <div className="flex-1 min-w-0">
                <h2 className="font-semibold text-foreground mb-1">
                  {book.title}
                </h2>
                <p className="text-sm text-muted-foreground mb-1">
                  {book.author}
                </p>
                {book.publisher && (
                  <p className="text-xs text-muted-foreground">
                    {book.publisher}
                  </p>
                )}
                <p className="text-xs text-muted-foreground mt-2">
                  등록일: {format(new Date(book.addedAt), 'yyyy년 MM월 dd일', { locale: ko })}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Notes Section */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-foreground">
              문장 수집 ({notes.length})
            </h3>
            <Button
              onClick={() => setIsAddingNote(true)}
              size="sm"
              className="gap-1"
            >
              <Plus className="h-4 w-4" />
              추가
            </Button>
          </div>

          {notes.length === 0 ? (
            <Card>
              <CardContent className="p-8 text-center space-y-3">
                <Camera className="h-12 w-12 text-muted-foreground mx-auto" />
                <p className="text-muted-foreground">
                  아직 수집한 문장이 없습니다
                </p>
                <p className="text-sm text-muted-foreground">
                  책의 문장을 사진으로 찍어 저장해보세요
                </p>
                <Button
                  onClick={() => setIsAddingNote(true)}
                  className="gap-2"
                >
                  <Camera className="h-4 w-4" />
                  문장 수집 시작하기
                </Button>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-2">
              {notes.map((note) => (
                <Card 
                  key={note.id}
                  className="cursor-pointer hover:bg-accent transition-colors"
                  onClick={() => navigate(`/notes/${note.id}`)}
                >
                  <CardContent className="p-4">
                    <div className="space-y-2">
                      {note.pageNumber && (
                        <p className="text-xs font-medium text-muted-foreground">
                          p. {note.pageNumber}
                        </p>
                      )}
                      <p className="text-sm text-foreground font-medium leading-relaxed line-clamp-2">
                        {note.summary || note.content}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>

        {/* Delete Book Section */}
        <div className="mt-8 pt-6 border-t border-border">
          <AlertDialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
            <AlertDialogTrigger asChild>
              <Button
                variant="ghost"
                className="w-full text-destructive hover:text-destructive hover:bg-destructive/10"
              >
                <Trash2 className="h-4 w-4 mr-2" />
                책 삭제하기
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>책을 서재에서 제거하시겠어요?</AlertDialogTitle>
                <AlertDialogDescription>
                  책에 기록한 모든 문장도 함께 삭제됩니다.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>취소</AlertDialogCancel>
                <AlertDialogAction
                  onClick={handleDeleteBook}
                  className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                >
                  삭제
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      </div>

      {/* Add Note Dialog */}
      <Dialog open={isAddingNote} onOpenChange={setIsAddingNote}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>문장 수집</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-3">
              <Label className="text-sm font-semibold">이미지 등록 방법</Label>
              
              <div className="grid grid-cols-2 gap-3">
                {/* 앨범에서 추가 */}
                <Label htmlFor="gallery-upload" className="cursor-pointer">
                  <div className="border-2 border-border rounded-lg p-4 text-center hover:border-primary hover:bg-primary-light/20 transition-all active:scale-[0.98]">
                    <Camera className="h-8 w-8 text-primary mx-auto mb-2" />
                    <p className="text-sm font-semibold text-foreground">
                      앨범에서 추가
                    </p>
                  </div>
                </Label>
                <input
                  id="gallery-upload"
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleImageUpload}
                  disabled={isProcessingImage}
                />

                {/* 사진 촬영 */}
                <Label htmlFor="camera-upload" className="cursor-pointer">
                  <div className="border-2 border-border rounded-lg p-4 text-center hover:border-primary hover:bg-primary-light/20 transition-all active:scale-[0.98]">
                    <Camera className="h-8 w-8 text-primary mx-auto mb-2" />
                    <p className="text-sm font-semibold text-foreground">
                      사진 촬영
                    </p>
                  </div>
                </Label>
                <input
                  id="camera-upload"
                  type="file"
                  accept="image/*"
                  capture="environment"
                  className="hidden"
                  onChange={handleImageUpload}
                  disabled={isProcessingImage}
                />
              </div>
              
              {isProcessingImage && (
                <div className="space-y-3 p-4 bg-primary-light/20 rounded-lg">
                  <div className="space-y-2">
                    <Skeleton className="h-4 w-full" />
                    <Skeleton className="h-4 w-3/4" />
                    <Skeleton className="h-4 w-5/6" />
                  </div>
                 <p className="text-xs text-center text-muted-foreground font-medium animate-pulse">
                    텍스트 추출 중...
                  </p>
                </div>
              )}
            </div>

            <div>
              <Label htmlFor="page-number">페이지 번호 (선택)</Label>
              <Input
                id="page-number"
                type="number"
                placeholder="예: 42"
                value={pageNumber}
                onChange={(e) => setPageNumber(e.target.value)}
                disabled={isProcessingImage || isSavingNote}
              />
            </div>

            <div>
              <Label htmlFor="extracted-text">추출된 텍스트</Label>
              <Textarea
                id="extracted-text"
                placeholder="이미지를 업로드하면 텍스트가 자동으로 추출됩니다"
                value={extractedText}
                onChange={(e) => setExtractedText(e.target.value)}
                className="min-h-[120px]"
                disabled={isProcessingImage || isSavingNote}
              />
            </div>

            <div>
              <div className="flex items-center justify-between mb-1">
                <Label htmlFor="memo">생각 메모 (선택)</Label>
                <span className="text-xs text-muted-foreground">
                  {memo.length}/300
                </span>
              </div>
              <Textarea
                id="memo"
                placeholder="이 문장에 대한 생각을 기록해보세요"
                value={memo}
                onChange={(e) => {
                  if (e.target.value.length <= 300) {
                    setMemo(e.target.value);
                  }
                }}
                className="min-h-[80px]"
                disabled={isProcessingImage || isSavingNote}
              />
            </div>

            <div className="flex gap-2">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => {
                  setIsAddingNote(false);
                  setExtractedText('');
                  setMemo('');
                  setPageNumber('');
                }}
                disabled={isProcessingImage || isSavingNote}
              >
                취소
              </Button>
              <Button
                className="flex-1"
                onClick={handleSaveNote}
                disabled={!extractedText.trim() || isProcessingImage || isSavingNote}
              >
                {isSavingNote ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    저장 중...
                  </>
                ) : (
                  '저장'
                )}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Category Dialog */}
      <Dialog open={isAddingCategory} onOpenChange={setIsAddingCategory}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>카테고리 편집</DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            {categories.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-4">
                생성된 카테고리가 없습니다
              </p>
            ) : (
              <div className="space-y-2">
                {categories.map(category => (
                  <label
                    key={category.id}
                    className="flex items-center gap-3 p-3 rounded-lg border border-border cursor-pointer hover:bg-accent transition-colors"
                  >
                    <Checkbox
                      checked={selectedCategories.includes(category.id)}
                      onCheckedChange={() => handleToggleCategory(category.id)}
                    />
                    <div className="flex-1">
                      <span className="text-sm font-medium">{category.name}</span>
                    </div>
                    <div
                      className="w-4 h-4 rounded-full"
                      style={{ backgroundColor: category.color }}
                    />
                  </label>
                ))}
              </div>
            )}
            <div className="flex gap-2">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => setIsAddingCategory(false)}
              >
                취소
              </Button>
              <Button
                className="flex-1"
                onClick={handleSaveCategories}
              >
                저장
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
