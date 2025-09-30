import { BookSearchResult } from "@/types/book";

// Mock data for demonstration
const MOCK_BOOKS: BookSearchResult[] = [
  {
    isbn: "9788936434267",
    title: "작별하지 않는다",
    author: "한강",
    publisher: "문학동네",
    publishDate: "2021-08-25",
    coverImage: "https://image.aladin.co.kr/product/27401/47/cover500/8936434268_1.jpg",
    description: "한강 작가의 소설"
  },
  {
    isbn: "9788936434120",
    title: "흰",
    author: "한강",
    publisher: "문학동네",
    publishDate: "2016-11-04",
    coverImage: "https://image.aladin.co.kr/product/8929/99/cover500/8936434128_1.jpg",
    description: "한강 작가의 산문집"
  },
  {
    isbn: "9788937460449",
    title: "1984",
    author: "조지 오웰",
    publisher: "민음사",
    publishDate: "2003-10-20",
    coverImage: "https://image.aladin.co.kr/product/49/5/cover500/8937460440_1.jpg",
    description: "조지 오웰의 디스토피아 소설"
  },
];

// Simulated API call
export async function searchBooks(query: string): Promise<BookSearchResult[]> {
  // Simulate network delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  if (!query.trim()) {
    return [];
  }

  // Filter mock data based on query
  return MOCK_BOOKS.filter(book => 
    book.title.toLowerCase().includes(query.toLowerCase()) ||
    book.author.toLowerCase().includes(query.toLowerCase()) ||
    book.isbn.includes(query)
  );
}

// Simulated ISBN lookup
export async function getBookByISBN(isbn: string): Promise<BookSearchResult | null> {
  await new Promise(resolve => setTimeout(resolve, 500));
  
  return MOCK_BOOKS.find(book => book.isbn === isbn) || null;
}
