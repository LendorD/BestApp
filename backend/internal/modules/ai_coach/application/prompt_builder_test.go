package application

import (
	"strings"
	"testing"
	"time"

	analyticsdomain "gamementor/internal/modules/analytics/domain"
)

func TestBuildDotaReviewPrompt(t *testing.T) {
	prompt, err := BuildDotaReviewPrompt(&analyticsdomain.DotaSnapshot{
		SteamID:        "123",
		Matches:        10,
		Winrate:        60,
		AverageKDA:     4.2,
		ImpactScore:    72,
		StabilityScore: 65,
		Normalized: map[string]any{
			"steam_id":    "123",
			"winrate":     60,
			"average_kda": 4.2,
		},
		CreatedAt: time.Date(2026, 6, 4, 12, 0, 0, 0, time.UTC),
	})
	if err != nil {
		t.Fatalf("unexpected prompt error: %v", err)
	}

	for _, needle := range []string{"summary", "strengths", "main_mistakes", "recommendations", "Analytics snapshot", `"steam_id": "123"`} {
		if !strings.Contains(prompt, needle) {
			t.Fatalf("prompt does not contain %q:\n%s", needle, prompt)
		}
	}
}
