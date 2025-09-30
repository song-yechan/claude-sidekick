import { Home, Plus, BookOpen } from "lucide-react";
import { NavLink, useNavigate } from "react-router-dom";
import { cn } from "@/lib/utils";

const navItems = [
  { to: "/", icon: Home, label: "홈" },
  { to: "/categories", icon: BookOpen, label: "서재" },
];

export const BottomNav = () => {
  const navigate = useNavigate();

  return (
    <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md bg-card border-t border-border shadow-lg z-50">
      <div className="grid grid-cols-3 h-16 px-2">
        {/* Left - 홈 */}
        <NavLink
          to="/"
          className={({ isActive }) =>
            cn(
              "flex flex-col items-center justify-center gap-1 py-2 rounded-lg transition-colors",
              isActive
                ? "text-primary bg-primary/10"
                : "text-muted-foreground hover:text-foreground hover:bg-muted"
            )
          }
        >
          {({ isActive }) => (
            <>
              <Home className={cn("h-5 w-5", isActive && "stroke-[2.5]")} />
              <span className="text-xs font-medium">홈</span>
            </>
          )}
        </NavLink>

        {/* Center - + 버튼 */}
        <div className="flex items-center justify-center">
          <button
            onClick={() => navigate('/search')}
            className="flex items-center justify-center -mt-8"
          >
            <div className="bg-primary text-primary-foreground rounded-full p-4 shadow-lg hover:scale-105 transition-transform">
              <Plus className="h-6 w-6" />
            </div>
          </button>
        </div>

        {/* Right - 서재 */}
        <NavLink
          to="/categories"
          className={({ isActive }) =>
            cn(
              "flex flex-col items-center justify-center gap-1 py-2 rounded-lg transition-colors",
              isActive
                ? "text-primary bg-primary/10"
                : "text-muted-foreground hover:text-foreground hover:bg-muted"
            )
          }
        >
          {({ isActive }) => (
            <>
              <BookOpen className={cn("h-5 w-5", isActive && "stroke-[2.5]")} />
              <span className="text-xs font-medium">서재</span>
            </>
          )}
        </NavLink>
      </div>
    </nav>
  );
};
