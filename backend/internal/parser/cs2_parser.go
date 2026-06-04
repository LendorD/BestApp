package parser

import (
	"fmt"
	"regexp"
	"strconv"
)

var getPosRegexp = regexp.MustCompile(`setpos\s+(` + numberPattern + `)\s+(` + numberPattern + `)\s+(` + numberPattern + `)\s*;\s*setang\s+(` + numberPattern + `)\s+(` + numberPattern + `)\s+(` + numberPattern + `)`)

const numberPattern = `[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?`

type Position struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
	Z float64 `json:"z"`
}

type ViewAngle struct {
	Pitch float64 `json:"pitch"`
	Yaw   float64 `json:"yaw"`
}

type Capture struct {
	Position Position
	View     ViewAngle
	RawLine  string
}

func ParseGetPosLine(line string) (*Capture, bool, error) {
	matches := getPosRegexp.FindStringSubmatch(line)
	if matches == nil {
		return nil, false, nil
	}
	if len(matches) != 7 {
		return nil, true, fmt.Errorf("unexpected getpos match size: %d", len(matches))
	}

	values := make([]float64, 6)
	for i := 1; i < len(matches); i++ {
		value, err := strconv.ParseFloat(matches[i], 64)
		if err != nil {
			return nil, true, fmt.Errorf("parse getpos number %q: %w", matches[i], err)
		}
		values[i-1] = value
	}

	return &Capture{
		Position: Position{
			X: values[0],
			Y: values[1],
			Z: values[2],
		},
		View: ViewAngle{
			Pitch: values[3],
			Yaw:   values[4],
		},
		RawLine: line,
	}, true, nil
}
