package parser

import "testing"

func TestParseGetPosLine(t *testing.T) {
	line := `] setpos -1032.42 -789.12 -167.97; setang -18.40 91.20 0.00`

	capture, ok, err := ParseGetPosLine(line)
	if err != nil {
		t.Fatalf("ParseGetPosLine returned error: %v", err)
	}
	if !ok {
		t.Fatal("expected getpos line to be detected")
	}
	if capture.Position.X != -1032.42 || capture.Position.Y != -789.12 || capture.Position.Z != -167.97 {
		t.Fatalf("unexpected position: %+v", capture.Position)
	}
	if capture.View.Pitch != -18.40 || capture.View.Yaw != 91.20 {
		t.Fatalf("unexpected view angle: %+v", capture.View)
	}
}

func TestParseGetPosLineIgnoresOtherLines(t *testing.T) {
	capture, ok, err := ParseGetPosLine("some unrelated console output")
	if err != nil {
		t.Fatalf("ParseGetPosLine returned error: %v", err)
	}
	if ok {
		t.Fatalf("expected unrelated line to be ignored, got %+v", capture)
	}
}
