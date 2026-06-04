package recorder

import (
	"errors"
	"fmt"
	"time"

	"gamementor/internal/parser"
)

var ErrSessionComplete = errors.New("recording session already has throw and landing positions")

type CaptureStage string

const (
	StageThrowCaptured   CaptureStage = "throw_position_captured"
	StageLandingCaptured CaptureStage = "landing_position_captured"
	StageDuplicate       CaptureStage = "duplicate_ignored"
)

type CapturedPoint struct {
	Position   parser.Position
	View       parser.ViewAngle
	RawLine    string
	CapturedAt time.Time
}

type Session struct {
	mapName     string
	grenadeType string
	debounce    time.Duration

	throwPosition   *CapturedPoint
	landingPosition *CapturedPoint

	lastSignature string
	lastCaptured  time.Time
}

type ExportPayload struct {
	Map             string           `json:"map"`
	GrenadeType     string           `json:"grenade_type"`
	ThrowPosition   parser.Position  `json:"throw_position"`
	ViewAngle       parser.ViewAngle `json:"view_angle"`
	LandingPosition parser.Position  `json:"landing_position"`
}

func NewSession(mapName, grenadeType string, debounce time.Duration) *Session {
	if debounce <= 0 {
		debounce = 800 * time.Millisecond
	}
	return &Session{
		mapName:     mapName,
		grenadeType: grenadeType,
		debounce:    debounce,
	}
}

func (s *Session) Capture(capture parser.Capture) (CaptureStage, error) {
	now := time.Now()
	signature := captureSignature(capture)
	if signature == s.lastSignature && now.Sub(s.lastCaptured) < s.debounce {
		return StageDuplicate, nil
	}
	s.lastSignature = signature
	s.lastCaptured = now

	point := &CapturedPoint{
		Position:   capture.Position,
		View:       capture.View,
		RawLine:    capture.RawLine,
		CapturedAt: now,
	}

	if s.throwPosition == nil {
		s.throwPosition = point
		return StageThrowCaptured, nil
	}
	if s.landingPosition == nil {
		s.landingPosition = point
		return StageLandingCaptured, nil
	}

	return "", ErrSessionComplete
}

func (s *Session) ReadyForExport() bool {
	return s.throwPosition != nil && s.landingPosition != nil
}

func (s *Session) ExportPayload() (ExportPayload, error) {
	if !s.ReadyForExport() {
		return ExportPayload{}, errors.New("recording session is incomplete")
	}
	return ExportPayload{
		Map:             s.mapName,
		GrenadeType:     s.grenadeType,
		ThrowPosition:   s.throwPosition.Position,
		ViewAngle:       s.throwPosition.View,
		LandingPosition: s.landingPosition.Position,
	}, nil
}

func captureSignature(capture parser.Capture) string {
	return fmt.Sprintf(
		"%.4f:%.4f:%.4f:%.4f:%.4f",
		capture.Position.X,
		capture.Position.Y,
		capture.Position.Z,
		capture.View.Pitch,
		capture.View.Yaw,
	)
}
