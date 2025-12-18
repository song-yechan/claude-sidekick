import { ReactNode } from "react";
import { BottomNav } from "./BottomNav";

interface MobileLayoutProps {
  children: ReactNode;
}

export const MobileLayout = ({ children }: MobileLayoutProps) => {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Mobile container - 모바일 최대 너비 제한 */}
      <div className="flex-1 w-full max-w-md mx-auto bg-background shadow-lg">
        {/* Content area with bottom nav spacing */}
        <main className="pb-20 min-h-screen">
          {children}
        </main>
        
        {/* Fixed bottom navigation */}
        <BottomNav />
      </div>
    </div>
  );
};
