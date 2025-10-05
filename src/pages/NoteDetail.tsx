import { useParams, useNavigate } from "react-router-dom";
import { useNotes } from "@/hooks/useNotes";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft, Trash2 } from "lucide-react";

export default function NoteDetail() {
  const { noteId } = useParams<{ noteId: string }>();
  const navigate = useNavigate();
  const { notes, deleteNote } = useNotes();
  
  const note = notes.find(n => n.id === noteId);

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
          <Button
            variant="ghost"
            size="icon"
            onClick={handleDelete}
            className="text-destructive hover:text-destructive"
          >
            <Trash2 className="h-5 w-5" />
          </Button>
        </div>
      </header>

      {/* Content */}
      <div className="p-4">
        <Card>
          <CardContent className="p-6 space-y-4">
            {note.pageNumber && (
              <div className="pb-2 border-b border-border">
                <p className="text-sm text-muted-foreground">
                  페이지 {note.pageNumber}
                </p>
              </div>
            )}
            
            {note.summary && (
              <div className="pb-4 border-b border-border">
                <h3 className="text-sm font-semibold text-muted-foreground mb-2">
                  요약
                </h3>
                <p className="text-foreground">
                  {note.summary}
                </p>
              </div>
            )}

            <div>
              <h3 className="text-sm font-semibold text-muted-foreground mb-2">
                전체 내용
              </h3>
              <p className="text-foreground whitespace-pre-wrap leading-relaxed">
                {note.content}
              </p>
            </div>

            {note.memo && (
              <div className="pt-4 border-t border-border">
                <h3 className="text-sm font-semibold text-muted-foreground mb-2">
                  메모
                </h3>
                <p className="text-foreground whitespace-pre-wrap">
                  {note.memo}
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
