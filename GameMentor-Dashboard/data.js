/* GameMentor — realistic mock data for Dota 2 & CS2 dashboards */
(function () {
  // helper: build a small jittered series
  function series(base, spread, n, seed) {
    let s = seed || 7;
    const out = [];
    for (let i = 0; i < n; i++) {
      s = (s * 9301 + 49297) % 233280;
      const r = s / 233280;
      out.push(Math.round((base + (r - 0.5) * spread) * 100) / 100);
    }
    return out;
  }

  const dota = {
    accent: "#00D084",
    accentSoft: "rgba(0,208,132,0.12)",
    player: {
      name: "Lendor",
      tag: "Lendor.gm",
      accountId: "369102305",
      region: "EU West",
      rolesLine: "Carry · Mid",
      avatar: "L",
      rankTier: "Divine III",
      rankSub: "Top 6% region",
      mmr: 5420,
      mmrDelta: 184,
      seasonLabel: "RANKED · SEASON 7",
    },
    score: {
      value: 74,
      delta: 6,
      percentile: "Top 12%",
      caption: "Better than 88% of Divine players",
      breakdown: [
        { label: "Laning", value: 71, hint: "GPM / XPM lead @10" },
        { label: "Teamfight", value: 78, hint: "Participation 71%" },
        { label: "Farming", value: 82, hint: "Last hits / min" },
        { label: "Objectives", value: 64, hint: "Tower / Roshan timing" },
        { label: "Vision", value: 58, hint: "Wards & dewards" },
        { label: "Survival", value: 69, hint: "Deaths / map control" },
      ],
    },
    kpis: [
      { label: "Winrate", value: "56%", delta: "+4", up: true, spark: series(52, 14, 14, 11) },
      { label: "KDA", value: "3.42", delta: "+0.31", up: true, spark: series(3.1, 1.1, 14, 23) },
      { label: "GPM", value: "612", delta: "+18", up: true, spark: series(590, 70, 14, 31) },
      { label: "XPM", value: "684", delta: "+22", up: true, spark: series(660, 80, 14, 41) },
      { label: "Last hits / 10m", value: "78", delta: "-3", up: false, spark: series(80, 16, 14, 53) },
      { label: "Hero DMG", value: "28.4k", delta: "+2.1k", up: true, spark: series(26, 7, 14, 61) },
    ],
    trend: {
      // 12 data points (weeks)
      mmr: series(5236, 220, 16, 3).map((v, i) => Math.round(5180 + i * 16 + (v - 5236) * 0.4)),
      winrate: series(53, 16, 16, 9).map((v) => Math.max(38, Math.min(70, Math.round(v)))),
    },
    radar: {
      axes: ["Laning", "Fight", "Farm", "Objectives", "Vision", "Survival"],
      you: [71, 78, 82, 64, 58, 69],
      rankAvg: [66, 64, 70, 62, 60, 63],
    },
    insights: [
      {
        kind: "weak",
        tag: "PRIMARY LEAK",
        title: "You stop pressuring after won fights",
        body: "In 9 of last 14 wins the advantage faded before the next objective. Convert kills into tower / Roshan within 25s.",
      },
      {
        kind: "strong",
        tag: "STRENGTH",
        title: "Elite early farm tempo",
        body: "GPM @10 sits in the top 8% of your bracket. Your laning conversion is a real edge — draft greedier cores.",
      },
      {
        kind: "focus",
        tag: "FOCUS THIS WEEK",
        title: "Ward efficiency & deward windows",
        body: "Vision score is your lowest pillar (58). Target 1.4 dewards / 10 min and place on power-rune timings.",
      },
    ],
    matches: [
      { hero: "Juggernaut", hi: "JG", result: "W", k: 12, d: 3, a: 9, kda: "12/3/9", gpm: 678, dur: "38:12", impact: 9.1, when: "2h" },
      { hero: "Phantom Assassin", hi: "PA", result: "W", k: 15, d: 6, a: 7, kda: "15/6/7", gpm: 712, dur: "41:50", impact: 8.4, when: "5h" },
      { hero: "Faceless Void", hi: "FV", result: "L", k: 6, d: 9, a: 11, kda: "6/9/11", gpm: 521, dur: "47:03", impact: 5.2, when: "8h" },
      { hero: "Morphling", hi: "MO", result: "W", k: 11, d: 4, a: 13, kda: "11/4/13", gpm: 645, dur: "35:40", impact: 8.8, when: "1d" },
      { hero: "Ember Spirit", hi: "ES", result: "L", k: 8, d: 8, a: 9, kda: "8/8/9", gpm: 558, dur: "44:19", impact: 5.9, when: "1d" },
      { hero: "Anti-Mage", hi: "AM", result: "W", k: 10, d: 2, a: 5, kda: "10/2/5", gpm: 734, dur: "33:08", impact: 9.4, when: "2d" },
      { hero: "Slark", hi: "SL", result: "W", k: 13, d: 5, a: 10, kda: "13/5/10", gpm: 601, dur: "39:55", impact: 7.7, when: "2d" },
    ],
    leaderboard: {
      caption: "vs Pro carries · normalized per-min",
      rows: [
        { name: "You", you: true, score: 74, gpm: 612, kda: 3.42 },
        { name: "Yatoro", you: false, score: 96, gpm: 731, kda: 5.10 },
        { name: "Nisha", you: false, score: 94, gpm: 705, kda: 4.62 },
        { name: "Ame", you: false, score: 95, gpm: 742, kda: 4.88 },
      ],
      bars: [
        { label: "GPM", you: 82, pro: 96 },
        { label: "KDA", you: 67, pro: 92 },
        { label: "Last hits", you: 88, pro: 97 },
        { label: "Map impact", you: 71, pro: 95 },
      ],
    },
    goals: [
      { label: "Last-hits — 78 by 10:00", pct: 86, sub: "current avg 73" },
      { label: "Deward 1.4 / 10 min", pct: 54, sub: "current 0.8" },
      { label: "Smoke participation 60%", pct: 71, sub: "current 49%" },
    ],
  };

  const cs2 = {
    accent: "#FF6B00",
    accentSoft: "rgba(255,107,0,0.12)",
    player: {
      name: "Lendor",
      tag: "Lendor.gm",
      accountId: "STEAM 7656...4021",
      region: "EU",
      rolesLine: "Entry · AWP",
      avatar: "L",
      rankTier: "Faceit 9",
      rankSub: "Premier 19,840",
      mmr: 1984,
      mmrDelta: 96,
      seasonLabel: "PREMIER · S2",
    },
    score: {
      value: 68,
      delta: 4,
      percentile: "Top 18%",
      caption: "Better than 82% of Premier players",
      breakdown: [
        { label: "Aim", value: 80, hint: "HS% & spray control" },
        { label: "Utility", value: 61, hint: "Util dmg / round" },
        { label: "Positioning", value: 66, hint: "Trade & angles" },
        { label: "Clutch", value: 72, hint: "1vX conversion" },
        { label: "Economy", value: 70, hint: "Buy discipline" },
        { label: "Entry", value: 58, hint: "Opening duels" },
      ],
    },
    kpis: [
      { label: "K/D", value: "1.18", delta: "+0.07", up: true, spark: series(1.12, 0.4, 14, 12) },
      { label: "ADR", value: "86.4", delta: "+5.1", up: true, spark: series(82, 18, 14, 24) },
      { label: "HS%", value: "54%", delta: "+3", up: true, spark: series(51, 12, 14, 33) },
      { label: "Win%", value: "52%", delta: "-2", up: false, spark: series(54, 14, 14, 44) },
      { label: "Util DMG", value: "12.4", delta: "+1.2", up: true, spark: series(11, 5, 14, 55) },
      { label: "Clutch%", value: "31%", delta: "+4", up: true, spark: series(28, 11, 14, 66) },
    ],
    trend: {
      mmr: series(1900, 90, 16, 4).map((v, i) => Math.round(1860 + i * 9 + (v - 1900) * 0.4)),
      winrate: series(50, 16, 16, 8).map((v) => Math.max(36, Math.min(66, Math.round(v)))),
    },
    radar: {
      axes: ["Aim", "Utility", "Position", "Clutch", "Economy", "Entry"],
      you: [80, 61, 66, 72, 70, 58],
      rankAvg: [70, 64, 65, 63, 66, 62],
    },
    insights: [
      {
        kind: "weak",
        tag: "PRIMARY LEAK",
        title: "Over-peeking on entry without trade setup",
        body: "You take 1st contact in 38% of rounds but die un-traded 6/10 times. Anchor a trader before the swing.",
      },
      {
        kind: "strong",
        tag: "STRENGTH",
        title: "Top-tier raw aim & HS%",
        body: "HS% sits top 9% of Premier. Your duel mechanics carry rounds — lean into AWP / aggressive holds.",
      },
      {
        kind: "focus",
        tag: "FOCUS THIS WEEK",
        title: "Utility damage & default smokes",
        body: "Utility is your lowest pillar (61). Drill 3 map-default smoke sets — target 16+ util dmg / round.",
      },
    ],
    matches: [
      { hero: "Mirage", hi: "MR", result: "W", k: 24, d: 16, a: 5, kda: "24/16/5", gpm: 0, score: "16-12", dur: "ADR 94", impact: 1.28, when: "1h" },
      { hero: "Inferno", hi: "IN", result: "W", k: 21, d: 14, a: 7, kda: "21/14/7", gpm: 0, score: "16-9", dur: "ADR 88", impact: 1.31, when: "3h" },
      { hero: "Ancient", hi: "AN", result: "L", k: 17, d: 22, a: 4, kda: "17/22/4", gpm: 0, score: "11-16", dur: "ADR 71", impact: 0.86, when: "6h" },
      { hero: "Nuke", hi: "NK", result: "W", k: 27, d: 18, a: 6, kda: "27/18/6", gpm: 0, score: "16-14", dur: "ADR 101", impact: 1.34, when: "1d" },
      { hero: "Anubis", hi: "AB", result: "L", k: 15, d: 19, a: 8, kda: "15/19/8", gpm: 0, score: "13-16", dur: "ADR 76", impact: 0.92, when: "1d" },
      { hero: "Vertigo", hi: "VT", result: "W", k: 23, d: 15, a: 5, kda: "23/15/5", gpm: 0, score: "16-11", dur: "ADR 90", impact: 1.22, when: "2d" },
      { hero: "Dust II", hi: "D2", result: "W", k: 20, d: 13, a: 9, kda: "20/13/9", gpm: 0, score: "16-10", dur: "ADR 85", impact: 1.19, when: "2d" },
    ],
    leaderboard: {
      caption: "vs Pro riflers · normalized",
      rows: [
        { name: "You", you: true, score: 68, gpm: 86, kda: 1.18 },
        { name: "s1mple", you: false, score: 97, gpm: 92, kda: 1.42 },
        { name: "ZywOo", you: false, score: 97, gpm: 91, kda: 1.45 },
        { name: "donk", you: false, score: 96, gpm: 95, kda: 1.39 },
      ],
      bars: [
        { label: "Aim", you: 86, pro: 98 },
        { label: "Util", you: 61, pro: 90 },
        { label: "Clutch", you: 72, pro: 94 },
        { label: "Impact", you: 70, pro: 96 },
      ],
    },
    goals: [
      { label: "Util damage 16+ / round", pct: 62, sub: "current 12.4" },
      { label: "Traded death rate < 35%", pct: 48, sub: "current 60%" },
      { label: "Crosshair placement drills", pct: 80, sub: "12 / 15 sessions" },
    ],
  };

  window.GM_DATA = { dota, cs2 };
})();
