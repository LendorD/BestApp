/* GameMentor — canvas mount */
const AW = 1500;
const DARK = { background: "#050608" };

function CanvasApp() {
  return (
    <DesignCanvas>
      <DCSection id="dash" title="GameMentor · Dashboard Redesign" subtitle="Premium esports analytics — 3 layout & color directions. Click a board title to open it fullscreen; switch Dota 2 / CS2 inside each.">
        <DCArtboard id="varA" label="A · Command Center (Dota)" width={AW} height={1990} style={DARK}>
          <DashboardApp variant="A" initialGame="dota" />
        </DCArtboard>
        <DCArtboard id="varB" label="B · Score-First (Premium)" width={AW} height={2060} style={DARK}>
          <DashboardApp variant="B" initialGame="dota" accentOverride="#D4AF37" />
        </DCArtboard>
        <DCArtboard id="varC" label="C · Pro Dense (CS2)" width={AW} height={1830} style={DARK}>
          <DashboardApp variant="C" initialGame="cs2" />
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}
ReactDOM.createRoot(document.getElementById("root")).render(<CanvasApp />);
