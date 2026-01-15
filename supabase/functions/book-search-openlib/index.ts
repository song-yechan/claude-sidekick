import "https://deno.land/x/xhr@0.1.0/mod.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  console.log('book-search-openlib function called');
  console.log('Method:', req.method);

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Check for apikey (Supabase anon key)
    const apiKey = req.headers.get('apikey');
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: 'API key required', items: [] }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401
        }
      );
    }

    const { query, searchType } = await req.json();
    console.log('Search query:', query, 'type:', searchType);

    if (!query || !query.trim()) {
      return new Response(
        JSON.stringify({ items: [] }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Query length validation
    if (query.length > 200) {
      return new Response(
        JSON.stringify({ error: 'Query too long (max 200 characters)', items: [] }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    let items: any[] = [];

    // ISBN search - use ISBN API directly
    if (searchType === 'isbn') {
      const cleanIsbn = query.replace(/[-\s]/g, '');
      const isbnUrl = `https://openlibrary.org/isbn/${cleanIsbn}.json`;

      console.log('Fetching from Open Library ISBN API:', isbnUrl);
      const response = await fetch(isbnUrl);

      if (response.ok) {
        const data = await response.json();

        // Get additional details from works API if available
        let authors: string[] = [];
        if (data.authors && data.authors.length > 0) {
          const authorPromises = data.authors.map(async (author: any) => {
            try {
              const authorResponse = await fetch(`https://openlibrary.org${author.key}.json`);
              if (authorResponse.ok) {
                const authorData = await authorResponse.json();
                return authorData.name || '';
              }
            } catch {
              return '';
            }
            return '';
          });
          authors = await Promise.all(authorPromises);
        }

        // Get cover image
        let coverImage = '';
        if (data.covers && data.covers.length > 0) {
          coverImage = `https://covers.openlibrary.org/b/id/${data.covers[0]}-L.jpg`;
        }

        items = [{
          isbn: cleanIsbn,
          title: data.title || '',
          author: authors.filter(a => a).join(', '),
          publisher: data.publishers ? data.publishers[0] : '',
          publishDate: data.publish_date || '',
          coverImage: coverImage,
          description: data.description?.value || data.description || '',
          pageCount: data.number_of_pages || null,
        }];
      }
    } else {
      // General search using Search API
      const url = new URL('https://openlibrary.org/search.json');

      if (searchType === 'author') {
        url.searchParams.set('author', query);
      } else if (searchType === 'title') {
        url.searchParams.set('title', query);
      } else {
        url.searchParams.set('q', query);
      }

      url.searchParams.set('limit', '20');
      url.searchParams.set('fields', 'key,title,author_name,publisher,first_publish_year,cover_i,isbn,number_of_pages_median');

      console.log('Fetching from Open Library Search API');
      const response = await fetch(url.toString());

      if (!response.ok) {
        console.error('Open Library API error:', response.status, response.statusText);
        throw new Error(`Open Library API returned ${response.status}`);
      }

      const data = await response.json();
      console.log('Open Library API response received, docs:', data.docs?.length || 0);

      // Transform to BookSearchResult format
      items = (data.docs || []).map((doc: any) => {
        // Get best ISBN (prefer ISBN-13)
        let isbn = '';
        if (doc.isbn && doc.isbn.length > 0) {
          const isbn13 = doc.isbn.find((i: string) => i.length === 13);
          isbn = isbn13 || doc.isbn[0];
        }

        // Get cover image using cover_i
        let coverImage = '';
        if (doc.cover_i) {
          coverImage = `https://covers.openlibrary.org/b/id/${doc.cover_i}-L.jpg`;
        }

        return {
          isbn: isbn,
          title: doc.title || '',
          author: doc.author_name ? doc.author_name.join(', ') : '',
          publisher: doc.publisher ? doc.publisher[0] : '',
          publishDate: doc.first_publish_year ? String(doc.first_publish_year) : '',
          coverImage: coverImage,
          description: '',  // Search API doesn't return description
          pageCount: doc.number_of_pages_median || null,
        };
      });
    }

    return new Response(
      JSON.stringify({ items }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    );
  } catch (error) {
    console.error('Error in book-search-openlib function:', error);
    return new Response(
      JSON.stringify({ error: 'Search error occurred, please try again', items: [] }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    );
  }
});
