package domain

import "time"

const (
	CS2SideT  = "T"
	CS2SideCT = "CT"

	CS2GrenadeTypeSmoke   = "smoke"
	CS2GrenadeTypeFlash   = "flash"
	CS2GrenadeTypeMolotov = "molotov"
	CS2GrenadeTypeHE      = "he"

	DifficultyEasy   = "easy"
	DifficultyMedium = "medium"
	DifficultyHard   = "hard"
)

type CS2Map struct {
	ID          int64     `json:"id"`
	Code        string    `json:"code"`
	DisplayName string    `json:"display_name"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type CS2Grenade struct {
	ID           int64     `json:"id"`
	Map          string    `json:"map"`
	Side         string    `json:"side"`
	Type         string    `json:"type"`
	Title        string    `json:"title"`
	Description  string    `json:"description"`
	FromPosition string    `json:"from_position"`
	ToPosition   string    `json:"to_position"`
	Difficulty   string    `json:"difficulty"`
	ImageURL     string    `json:"image_url"`
	VideoURL     string    `json:"video_url"`
	Tags         []string  `json:"tags"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type CreateCS2GrenadeInput struct {
	Map          string   `json:"map"`
	Side         string   `json:"side"`
	Type         string   `json:"type"`
	Title        string   `json:"title"`
	Description  string   `json:"description"`
	FromPosition string   `json:"from_position"`
	ToPosition   string   `json:"to_position"`
	Difficulty   string   `json:"difficulty"`
	ImageURL     string   `json:"image_url"`
	VideoURL     string   `json:"video_url"`
	Tags         []string `json:"tags"`
}

type UpdateCS2GrenadeInput = CreateCS2GrenadeInput

type CS2GrenadeFilter struct {
	Map        string
	Side       string
	Type       string
	Difficulty string
	Limit      int
	Offset     int
}
