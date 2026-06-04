package application

import (
	"encoding/json"
	"fmt"

	coachdomain "gamementor/internal/modules/ai_coach/domain"
	analyticsdomain "gamementor/internal/modules/analytics/domain"
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
