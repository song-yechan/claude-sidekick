import { Note } from "@/types/book";
import { useLocalStorage } from "./useLocalStorage";

export function useNotes() {
  const [notes, setNotes] = useLocalStorage<Note[]>("notes", []);

  const addNote = (note: Omit<Note, "id" | "createdAt" | "updatedAt">) => {
    const newNote: Note = {
      ...note,
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    setNotes([...notes, newNote]);
    return newNote;
  };

  const updateNote = (id: string, updates: Partial<Note>) => {
    setNotes(notes.map(note => 
      note.id === id 
        ? { ...note, ...updates, updatedAt: new Date().toISOString() } 
        : note
    ));
  };

  const deleteNote = (id: string) => {
    setNotes(notes.filter(note => note.id !== id));
  };

  const getNotesByBook = (bookId: string) => {
    return notes.filter(note => note.bookId === bookId);
  };

  return {
    notes,
    addNote,
    updateNote,
    deleteNote,
    getNotesByBook,
  };
}
