export interface Book {
  id: string;
  isbn?: string;
  title: string;
  author: string;
  publisher?: string;
  publishDate?: string;
  coverImage?: string;
  description?: string;
  categoryIds: string[];
  addedAt: string;
}

export interface Category {
  id: string;
  name: string;
  color: string;
  createdAt: string;
}

export interface Note {
  id: string;
  bookId: string;
  content: string;
  pageNumber?: number;
  tags: string[];
  memo?: string;
  createdAt: string;
  updatedAt: string;
}

export interface BookSearchResult {
  isbn: string;
  title: string;
  author: string;
  publisher: string;
  publishDate: string;
  coverImage: string;
  description: string;
}
