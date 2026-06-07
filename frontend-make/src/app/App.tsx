import { Routes, Route, Navigate, useLocation } from "react-router";
import { Sidebar } from "./components/Sidebar";
import { TopBar } from "./components/TopBar";
import Overview from "./pages/Overview";
import Performance from "./pages/Performance";
import Heroes from "./pages/Heroes";
import Rankings from "./pages/Rankings";
import Replays from "./pages/Replays";
import Grenades from "./pages/cs2/Grenades";
import Training from "./pages/cs2/Training";
import Auth from "./pages/Auth";
import Profile from "./pages/Profile";
import Subscription from "./pages/Subscription";
import Explorer from "./pages/Explorer";
import ApiProbe from "./pages/ApiProbe";
import Landing from "./pages/Landing";
import Coach from "./pages/Coach";

export default function App() {
  const loc = useLocation();

  // Landing is the entry page (full-screen, no dashboard chrome).
  if (loc.pathname === "/") {
    return <Landing />;
  }
  // Auth screens render full-screen, outside the dashboard chrome.
  if (loc.pathname === "/login" || loc.pathname === "/register") {
    return <Auth />;
  }

  const game = loc.pathname.startsWith("/cs2") ? "cs2" : "dota";

  return (
    <div className="flex h-screen w-screen overflow-hidden"
      style={{ background: "#050608", fontFamily: "Manrope, sans-serif" }}>
      <Sidebar game={game} />
      <div className="flex flex-col flex-1 min-w-0 overflow-hidden">
        <TopBar />
        <main className="flex-1 overflow-y-auto overflow-x-hidden"
          style={{ scrollbarWidth: "thin", scrollbarColor: "#1B2430 transparent" }}>
          <div className="p-4 sm:p-5 flex flex-col gap-4 w-full max-w-[1600px] mx-auto">
            <Routes>
              <Route path="/overview" element={<Overview />} />
              <Route path="/performance" element={<Performance />} />
              <Route path="/heroes" element={<Heroes />} />
              <Route path="/rankings" element={<Rankings />} />
              <Route path="/replays" element={<Replays />} />
              <Route path="/cs2/grenades" element={<Grenades />} />
              <Route path="/cs2/training" element={<Training />} />
              <Route path="/coach" element={<Coach />} />
              <Route path="/explorer" element={<Explorer />} />
              <Route path="/api-test" element={<ApiProbe />} />
              <Route path="/profile" element={<Profile />} />
              <Route path="/subscription" element={<Subscription />} />
              <Route path="*" element={<Navigate to="/overview" replace />} />
            </Routes>
          </div>
        </main>
      </div>
    </div>
  );
}
