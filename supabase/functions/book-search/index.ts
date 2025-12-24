import "https://deno.land/x/xhr@0.1.0/mod.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  console.log('📚 book-search function called');
  console.log('📚 Method:', req.method);

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Check for apikey (Supabase anon key) - 기본적인 접근 제어
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

    const { query } = await req.json();
    console.log('📚 Search query:', query);
    
    if (!query || !query.trim()) {
      return new Response(
        JSON.stringify({ items: [] }), 
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Query length validation (prevent abuse)
    if (query.length > 200) {
      return new Response(
        JSON.stringify({ error: '검색어가 너무 깁니다. (최대 200자)', items: [] }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const ttbKey = Deno.env.get('ALADIN_TTB_KEY');
    console.log('📚 ALADIN_TTB_KEY present:', !!ttbKey);
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
      pageCount: item.subInfo?.itemPage || null,
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
    return new Response(
      JSON.stringify({ error: '검색 중 오류가 발생했습니다, 재검색해주세요', items: [] }), 
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});
