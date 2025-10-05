import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "./contexts/AuthContext";
import { ProtectedRoute } from "./components/ProtectedRoute";
import { MobileLayout } from "./components/layout/MobileLayout";
import Home from "./pages/Home";
import Search from "./pages/Search";
import Categories from "./pages/Categories";
import CategoryDetail from "./pages/CategoryDetail";
import BookDetail from "./pages/BookDetail";
import NoteDetail from "./pages/NoteDetail";
import Auth from "./pages/Auth";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <AuthProvider>
          <Routes>
            <Route path="/auth" element={<Auth />} />
            <Route path="/" element={
              <ProtectedRoute>
                <MobileLayout>
                  <Home />
                </MobileLayout>
              </ProtectedRoute>
            } />
            <Route path="/search" element={
              <ProtectedRoute>
                <MobileLayout>
                  <Search />
                </MobileLayout>
              </ProtectedRoute>
            } />
            <Route path="/categories" element={
              <ProtectedRoute>
                <MobileLayout>
                  <Categories />
                </MobileLayout>
              </ProtectedRoute>
            } />
            <Route path="/categories/:categoryId" element={
              <ProtectedRoute>
                <MobileLayout>
                  <CategoryDetail />
                </MobileLayout>
              </ProtectedRoute>
            } />
            <Route path="/books/:bookId" element={
              <ProtectedRoute>
                <MobileLayout>
                  <BookDetail />
                </MobileLayout>
              </ProtectedRoute>
            } />
            <Route path="/notes/:noteId" element={
              <ProtectedRoute>
                <MobileLayout>
                  <NoteDetail />
                </MobileLayout>
              </ProtectedRoute>
            } />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </AuthProvider>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
