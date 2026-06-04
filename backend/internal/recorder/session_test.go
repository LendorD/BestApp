package recorder

import (
	"testing"
	"time"

	"gamementor/internal/parser"
)

func TestSessionCaptureFlow(t *testing.T) {
	session := NewSession("de_mirage", "smoke", time.Second)

	stage, err := session.Capture(parser.Capture{
		Position: parser.Position{X: 1, Y: 2, Z: 3},
		View:     parser.ViewAngle{Pitch: -10, Yaw: 90},
	})
	if err != nil {
		t.Fatalf("capture throw: %v", err)
	}
	if stage != StageThrowCaptured {
		t.Fatalf("unexpected first stage: %s", stage)
	}

	stage, err = session.Capture(parser.Capture{
		Position: parser.Position{X: 4, Y: 5, Z: 6},
		View:     parser.ViewAngle{Pitch: 0, Yaw: 0},
	})
	if err != nil {
		t.Fatalf("capture landing: %v", err)
	}
	if stage != StageLandingCaptured {
		t.Fatalf("unexpected second stage: %s", stage)
	}

	payload, err := session.ExportPayload()
	if err != nil {
		t.Fatalf("export payload: %v", err)
	}
	if payload.ThrowPosition.X != 1 || payload.LandingPosition.X != 4 || payload.ViewAngle.Yaw != 90 {
		t.Fatalf("unexpected payload: %+v", payload)
	}
}

func TestSessionDebounce(t *testing.T) {
	session := NewSession("de_mirage", "smoke", time.Second)
	capture := parser.Capture{
		Position: parser.Position{X: 1, Y: 2, Z: 3},
		View:     parser.ViewAngle{Pitch: -10, Yaw: 90},
	}

	if _, err := session.Capture(capture); err != nil {
		t.Fatalf("first capture: %v", err)
	}
	stage, err := session.Capture(capture)
	if err != nil {
		t.Fatalf("duplicate capture: %v", err)
	}
	if stage != StageDuplicate {
		t.Fatalf("expected duplicate stage, got %s", stage)
	}
}
