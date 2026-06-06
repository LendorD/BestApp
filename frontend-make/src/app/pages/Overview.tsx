import { ProfileHeader } from "../components/ProfileHeader";
import { ScoreGauge } from "../components/ScoreGauge";
import { KpiCards } from "../components/KpiCards";
import { PerformanceTrend } from "../components/PerformanceTrend";
import { HexRadar } from "../components/HexRadar";
import { AiCoach } from "../components/AiCoach";
import { RecentMatches } from "../components/RecentMatches";
import { ProComparison } from "../components/ProComparison";

export default function Overview() {
  return (
    <>
      <ProfileHeader />
      <div className="grid gap-4 grid-cols-1 lg:grid-cols-[260px_minmax(0,1fr)]">
        <ScoreGauge />
        <div className="flex flex-col gap-4 min-w-0">
          <KpiCards />
          <PerformanceTrend />
        </div>
      </div>
      <div className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <HexRadar />
        <AiCoach />
      </div>
      <RecentMatches />
      <ProComparison />
    </>
  );
}
