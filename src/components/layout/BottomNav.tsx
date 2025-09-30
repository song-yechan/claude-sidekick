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
      <div className="flex items-center justify-around h-16 px-2">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              cn(
                "flex flex-col items-center justify-center gap-1 px-4 py-2 rounded-lg transition-colors min-w-[60px]",
                isActive
                  ? "text-primary bg-primary/10"
                  : "text-muted-foreground hover:text-foreground hover:bg-muted"
              )
            }
          >
            {({ isActive }) => (
              <>
                <item.icon className={cn("h-5 w-5", isActive && "stroke-[2.5]")} />
                <span className="text-xs font-medium">{item.label}</span>
              </>
            )}
          </NavLink>
        ))}
        
        {/* Center Add Button */}
        <button
          onClick={() => navigate('/search')}
          className="flex items-center justify-center -mt-8"
        >
          <div className="bg-primary text-primary-foreground rounded-full p-4 shadow-lg hover:scale-105 transition-transform">
            <Plus className="h-6 w-6" />
          </div>
        </button>
      </div>
    </nav>
  );
};
