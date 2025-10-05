import { useParams, useNavigate } from "react-router-dom";
import { useBooks } from "@/hooks/useBooks";
import { useNotes } from "@/hooks/useNotes";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft, Plus, Camera, Trash2, Edit } from "lucide-react";
import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Skeleton } from "@/components/ui/skeleton";

export default function BookDetail() {
  const { bookId } = useParams<{ bookId: string }>();
  const navigate = useNavigate();
  const { getBookById } = useBooks();
  const { getNotesByBook, addNote, deleteNote } = useNotes();
  
  const book = getBookById(bookId || '');
  const notes = getNotesByBook(bookId || '');

  const [isAddingNote, setIsAddingNote] = useState(false);
  const [isProcessingImage, setIsProcessingImage] = useState(false);
  const [extractedText, setExtractedText] = useState('');
  const [pageNumber, setPageNumber] = useState('');

  if (!book) {
    return (
      <div className="min-h-screen bg-background p-4">
        <p className="text-center text-muted-foreground">책을 찾을 수 없습니다</p>
      </div>
    );
  }

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsProcessingImage(true);
    try {
      // Convert image to base64
      const reader = new FileReader();
      reader.onloadend = async () => {
        const base64 = reader.result as string;
        
        // Call OCR edge function
        const { data, error } = await supabase.functions.invoke('ocr-image', {
          body: { imageBase64: base64 },
        });

        if (error) {
          console.error('OCR error:', error);
          toast.error('이미지 처리 중 오류가 발생했습니다');
          return;
        }

        setExtractedText(data.text || '');
        toast.success('텍스트가 추출되었습니다');
      };
      reader.readAsDataURL(file);
    } catch (error) {
      console.error('Image upload error:', error);
      toast.error('이미지 업로드 실패');
    } finally {
      setIsProcessingImage(false);
    }
  };

  const handleSaveNote = async () => {
    if (!extractedText.trim()) {
      toast.error('내용을 입력해주세요');
      return;
    }

    try {
      await addNote({
        bookId: book.id,
        content: extractedText,
        pageNumber: pageNumber ? parseInt(pageNumber) : undefined,
        tags: [],
      });
      
      setIsAddingNote(false);
      setExtractedText('');
      setPageNumber('');
      toast.success('문장이 저장되었습니다');
    } catch (error) {
      console.error('Save note error:', error);
      toast.error('저장 실패');
    }
  };

  const handleDeleteNote = (noteId: string) => {
    deleteNote(noteId);
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
                <Card key={note.id}>
                  <CardContent className="p-4">
                    <div className="space-y-2">
                      {note.pageNumber && (
                        <p className="text-xs text-muted-foreground">
                          p. {note.pageNumber}
                        </p>
                      )}
                      <p className="text-sm text-foreground whitespace-pre-wrap">
                        {note.content}
                      </p>
                      <div className="flex justify-end gap-2 pt-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDeleteNote(note.id)}
                          className="gap-1 text-destructive hover:text-destructive"
                        >
                          <Trash2 className="h-3 w-3" />
                          삭제
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
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
              <Label htmlFor="image-upload" className="cursor-pointer">
                <div className="border-2 border-dashed border-border rounded-lg p-6 text-center hover:border-primary transition-colors">
                  <Camera className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                  <p className="text-sm text-muted-foreground">
                    {isProcessingImage ? 'OCR 처리 중...' : '이미지를 선택하거나 촬영하세요'}
                  </p>
                </div>
              </Label>
              <input
                id="image-upload"
                type="file"
                accept="image/*"
                capture="environment"
                className="hidden"
                onChange={handleImageUpload}
                disabled={isProcessingImage}
              />
              
              {isProcessingImage && (
                <div className="space-y-3">
                  <div className="space-y-2">
                    <Skeleton className="h-4 w-full" />
                    <Skeleton className="h-4 w-3/4" />
                    <Skeleton className="h-4 w-5/6" />
                  </div>
                  <p className="text-xs text-center text-muted-foreground animate-pulse">
                    텍스트를 추출하고 있습니다...
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
              />
            </div>

            <div>
              <Label htmlFor="extracted-text">추출된 텍스트</Label>
              <Textarea
                id="extracted-text"
                placeholder="이미지를 업로드하면 텍스트가 자동으로 추출됩니다"
                value={extractedText}
                onChange={(e) => setExtractedText(e.target.value)}
                className="min-h-[150px]"
              />
            </div>

            <div className="flex gap-2">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => {
                  setIsAddingNote(false);
                  setExtractedText('');
                  setPageNumber('');
                }}
              >
                취소
              </Button>
              <Button
                className="flex-1"
                onClick={handleSaveNote}
                disabled={!extractedText.trim()}
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
