-- Create categories table
CREATE TABLE public.categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create books table
CREATE TABLE public.books (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  isbn TEXT,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  publisher TEXT,
  publish_date TEXT,
  cover_image TEXT,
  description TEXT,
  added_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create book_categories junction table for many-to-many relationship
CREATE TABLE public.book_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(book_id, category_id)
);

-- Create notes table
CREATE TABLE public.notes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  page_number INTEGER,
  tags TEXT[] DEFAULT '{}',
  memo TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for categories
CREATE POLICY "Users can view their own categories"
  ON public.categories FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own categories"
  ON public.categories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own categories"
  ON public.categories FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own categories"
  ON public.categories FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for books
CREATE POLICY "Users can view their own books"
  ON public.books FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own books"
  ON public.books FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own books"
  ON public.books FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own books"
  ON public.books FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for book_categories
CREATE POLICY "Users can view their own book categories"
  ON public.book_categories FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.books
      WHERE books.id = book_categories.book_id
      AND books.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create their own book categories"
  ON public.book_categories FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.books
      WHERE books.id = book_categories.book_id
      AND books.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own book categories"
  ON public.book_categories FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.books
      WHERE books.id = book_categories.book_id
      AND books.user_id = auth.uid()
    )
  );

-- RLS Policies for notes
CREATE POLICY "Users can view their own notes"
  ON public.notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own notes"
  ON public.notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notes"
  ON public.notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notes"
  ON public.notes FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Create trigger for notes updated_at
CREATE TRIGGER set_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Create indexes for better performance
CREATE INDEX idx_categories_user_id ON public.categories(user_id);
CREATE INDEX idx_books_user_id ON public.books(user_id);
CREATE INDEX idx_book_categories_book_id ON public.book_categories(book_id);
CREATE INDEX idx_book_categories_category_id ON public.book_categories(category_id);
CREATE INDEX idx_notes_user_id ON public.notes(user_id);
CREATE INDEX idx_notes_book_id ON public.notes(book_id);