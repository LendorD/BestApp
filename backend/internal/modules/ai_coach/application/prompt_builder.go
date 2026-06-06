package application

import (
	"encoding/json"
	"fmt"

	coachdomain "gamementor/internal/modules/ai_coach/domain"
	analyticsdomain "gamementor/internal/modules/statistics/domain"
)

func BuildDotaReviewPrompt(snapshot *analyticsdomain.DotaSnapshot) (string, error) {
	if snapshot == nil {
		return "", coachdomain.InvalidInput("analytics snapshot is required")
	}

	payload, err := json.MarshalIndent(snapshot.Normalized, "", "  ")
	if err != nil {
		return "", fmt.Errorf("marshal analytics snapshot: %w", err)
	}

	return fmt.Sprintf(`You are GameMentor AI Coach for Dota 2.
Analyze the player only from the normalized analytics snapshot below.
Return strict JSON with exactly these keys:
summary, strengths, weaknesses, main_mistakes, recommendations, training_plan, heroes_to_focus, heroes_to_avoid, next_steps.

Rules:
- Be practical and specific for ranked improvement.
- Mention winrate trends, KDA, GPM/XPM, impact, stability, farming, fighting, objective scores.
- Keep every array short: 3 to 5 items.
- Do not invent private match details not present in the snapshot.

Analytics snapshot:
%s`, string(payload)), nil
}

// BuildDotaMatchPrompt builds a prompt to review a single match. matchText is a
// compact text summary produced from the (parsed) replay; snapshot is optional
// extra context about the player and may be nil.
func BuildDotaMatchPrompt(matchText string, snapshot *analyticsdomain.DotaSnapshot) (string, error) {
	if matchText == "" {
		return "", coachdomain.InvalidInput("match summary is required")
	}

	context := ""
	if snapshot != nil {
		if payload, err := json.MarshalIndent(snapshot.Normalized, "", "  "); err == nil {
			context = "\n\nPlayer recent-form snapshot (for context):\n" + string(payload)
		}
	}

	return fmt.Sprintf(`You are GameMentor AI Coach for Dota 2.
Review this single match for the player and explain how they could have played better.
Return strict JSON with exactly these keys:
summary, strengths, weaknesses, main_mistakes, recommendations, training_plan, heroes_to_focus, heroes_to_avoid, next_steps.

Rules:
- Focus on this specific game: laning, KDA, farm pace (GPM/XPM/LH), teamfights, objectives.
- Be concrete and actionable. Keep every array short: 3 to 5 items.
- If the replay was not fully parsed, work from the available stats and say what extra detail a full parse would add.
- Do not invent events that are not in the data.

Match data:
%s%s`, matchText, context), nil
}
