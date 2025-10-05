import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { query } = await req.json();
    
    if (!query || !query.trim()) {
      return new Response(
        JSON.stringify({ items: [] }), 
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const ttbKey = Deno.env.get('ALADIN_TTB_KEY');
    if (!ttbKey) {
      console.error('ALADIN_TTB_KEY is not set');
      throw new Error('API key is not configured');
    }

    // Aladin API 요청
    const url = new URL('http://www.aladin.co.kr/ttb/api/ItemSearch.aspx');
    url.searchParams.set('ttbkey', ttbKey);
    url.searchParams.set('Query', query);
    url.searchParams.set('QueryType', 'Title');
    url.searchParams.set('MaxResults', '20');
    url.searchParams.set('start', '1');
    url.searchParams.set('SearchTarget', 'Book');
    url.searchParams.set('output', 'js');
    url.searchParams.set('Version', '20131101');
    url.searchParams.set('Cover', 'Big');

    console.log('Fetching from Aladin API:', url.toString());

    const response = await fetch(url.toString());
    
    if (!response.ok) {
      console.error('Aladin API error:', response.status, response.statusText);
      throw new Error(`Aladin API returned ${response.status}`);
    }

    const data = await response.json();
    console.log('Aladin API response received, items:', data.item?.length || 0);

    // BookSearchResult 형식으로 변환
    const items = (data.item || []).map((item: any) => ({
      isbn: item.isbn13 || item.isbn || '',
      title: item.title || '',
      author: item.author || '',
      publisher: item.publisher || '',
      publishDate: item.pubDate || '',
      coverImage: item.cover || '',
      description: item.description || '',
    }));

    return new Response(
      JSON.stringify({ items }), 
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );
  } catch (error) {
    console.error('Error in book-search function:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(
      JSON.stringify({ error: errorMessage, items: [] }), 
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});
