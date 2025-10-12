import { useParams, useNavigate } from "react-router-dom";
import { useNotes } from "@/hooks/useNotes";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft, Trash2, Edit, Save, X, Sparkles, Loader2 } from "lucide-react";
import { useState } from "react";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";

export default function NoteDetail() {
  const { noteId } = useParams<{ noteId: string }>();
  const navigate = useNavigate();
  const { notes, deleteNote, updateNote } = useNotes();
  
  const note = notes.find(n => n.id === noteId);
  
  const [isEditing, setIsEditing] = useState(false);
  const [isGeneratingSummary, setIsGeneratingSummary] = useState(false);
  const [editedContent, setEditedContent] = useState(note?.content || '');
  const [editedMemo, setEditedMemo] = useState(note?.memo || '');
  const [editedPageNumber, setEditedPageNumber] = useState(note?.pageNumber?.toString() || '');
  const [editedSummary, setEditedSummary] = useState(note?.summary || '');

  if (!note) {
    return (
      <div className="min-h-screen bg-background p-4">
        <p className="text-center text-muted-foreground">문장을 찾을 수 없습니다</p>
      </div>
    );
  }

  const handleDelete = () => {
    deleteNote(note.id);
    navigate(-1);
  };

  const handleGenerateSummary = async () => {
    if (!editedContent.trim()) {
      toast.error('요약할 내용이 없습니다');
      return;
    }

    setIsGeneratingSummary(true);
    try {
      const { data: summaryData, error: summaryError } = await supabase.functions.invoke('summarize-text', {
        body: { text: editedContent },
      });

      if (summaryError) {
        console.error('Summarize error:', summaryError);
        toast.error('요약 생성 중 오류가 발생했습니다');
        setIsGeneratingSummary(false);
        return;
      }

      const summary = summaryData.summary || '';
      setEditedSummary(summary);
      setIsGeneratingSummary(false);
      toast.success('AI 요약이 생성되었습니다');
    } catch (error) {
      console.error('Generate summary error:', error);
      toast.error('요약 생성 중 오류가 발생했습니다');
      setIsGeneratingSummary(false);
    }
  };

  const handleSave = () => {
    updateNote(note.id, {
      content: editedContent,
      memo: editedMemo,
      pageNumber: editedPageNumber ? parseInt(editedPageNumber) : undefined,
      summary: editedSummary,
    });
    setIsEditing(false);
    toast.success('수정되었습니다');
  };

  const handleCancelEdit = () => {
    setEditedContent(note?.content || '');
    setEditedMemo(note?.memo || '');
    setEditedPageNumber(note?.pageNumber?.toString() || '');
    setEditedSummary(note?.summary || '');
    setIsEditing(false);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-card border-b border-border px-4 py-4">
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate(-1)}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div className="flex-1">
            <h1 className="text-lg font-bold text-foreground">문장 상세</h1>
          </div>
          {!isEditing ? (
            <>
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setIsEditing(true)}
              >
                <Edit className="h-5 w-5" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                onClick={handleDelete}
                className="text-destructive hover:text-destructive"
              >
                <Trash2 className="h-5 w-5" />
              </Button>
            </>
          ) : (
            <>
              <Button
                variant="ghost"
                size="icon"
                onClick={handleCancelEdit}
              >
                <X className="h-5 w-5" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                onClick={handleSave}
                className="text-primary"
              >
                <Save className="h-5 w-5" />
              </Button>
            </>
          )}
        </div>
      </header>

      {/* Content */}
      <div className="p-4">
        <Card>
          <CardContent className="p-6 space-y-4">
            {isEditing ? (
              <>
                <div>
                  <Label htmlFor="page-number">페이지 번호 (선택)</Label>
                  <Input
                    id="page-number"
                    type="number"
                    placeholder="예: 42"
                    value={editedPageNumber}
                    onChange={(e) => setEditedPageNumber(e.target.value)}
                    className="mt-1"
                  />
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <Label htmlFor="summary">AI 요약</Label>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={handleGenerateSummary}
                      disabled={isGeneratingSummary || !editedContent.trim()}
                      className="gap-1"
                    >
                      {isGeneratingSummary ? (
                        <>
                          <Loader2 className="h-3 w-3 animate-spin" />
                          생성 중...
                        </>
                      ) : (
                        <>
                          <Sparkles className="h-3 w-3" />
                          AI 요약 생성
                        </>
                      )}
                    </Button>
                  </div>
                  <Textarea
                    id="summary"
                    placeholder="AI 요약 생성 버튼을 눌러 요약을 생성하세요"
                    value={editedSummary}
                    onChange={(e) => setEditedSummary(e.target.value)}
                    className="min-h-[80px] mt-1"
                  />
                </div>

                <div>
                  <Label htmlFor="content">전체 내용</Label>
                  <Textarea
                    id="content"
                    value={editedContent}
                    onChange={(e) => setEditedContent(e.target.value)}
                    className="min-h-[150px] mt-1"
                  />
                </div>

                <div>
                  <div className="flex items-center justify-between">
                    <Label htmlFor="memo">생각 메모</Label>
                    <span className="text-xs text-muted-foreground">
                      {editedMemo.length}/300
                    </span>
                  </div>
                  <Textarea
                    id="memo"
                    placeholder="이 문장에 대한 생각을 기록해보세요"
                    value={editedMemo}
                    onChange={(e) => {
                      if (e.target.value.length <= 300) {
                        setEditedMemo(e.target.value);
                      }
                    }}
                    className="min-h-[100px] mt-1"
                  />
                </div>
              </>
            ) : (
              <>
                {note.pageNumber && (
                  <div className="pb-3 border-b border-border">
                    <p className="text-sm font-medium text-muted-foreground">
                      페이지 {note.pageNumber}
                    </p>
                  </div>
                )}
                
                {note.summary && (
                  <div className="pb-4 border-b border-border">
                    <h3 className="text-xs font-semibold text-muted-foreground mb-2 uppercase tracking-wide">
                      요약
                    </h3>
                    <p className="text-base leading-relaxed text-foreground font-medium">
                      {note.summary}
                    </p>
                  </div>
                )}

                <div>
                  <h3 className="text-xs font-semibold text-muted-foreground mb-2 uppercase tracking-wide">
                    전체 내용
                  </h3>
                  <p className="text-base text-foreground whitespace-pre-wrap leading-relaxed">
                    {note.content}
                  </p>
                </div>

                {note.memo && (
                  <div className="pt-4 border-t border-border bg-primary-light/30 -mx-6 -mb-6 px-6 py-4 rounded-b-lg">
                    <h3 className="text-xs font-semibold text-muted-foreground mb-2 uppercase tracking-wide">
                      생각 메모
                    </h3>
                    <p className="text-base text-foreground whitespace-pre-wrap leading-relaxed">
                      {note.memo}
                    </p>
                  </div>
                )}
              </>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
