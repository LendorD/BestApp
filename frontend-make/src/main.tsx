import { createRoot } from "react-dom/client";
import { HashRouter } from "react-router";
import { AuthProvider } from "./lib/auth";
import { PlayerProvider } from "./lib/store";
import App from "./app/App.tsx";
import "./styles/index.css";

// HashRouter keeps deep links working on GitHub Pages (no server rewrites
// needed) and behaves identically behind the local nginx/Vite proxy.
createRoot(document.getElementById("root")!).render(
  <HashRouter>
    <AuthProvider>
      <PlayerProvider>
        <App />
      </PlayerProvider>
    </AuthProvider>
  </HashRouter>
);
