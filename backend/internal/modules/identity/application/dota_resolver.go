package application

import (
	"fmt"
	"net/url"
	"regexp"
	"strconv"
	"strings"

	"gamementor/internal/domain"
)

const steamID64Offset int64 = 76561197960265728

var (
	playerPathPattern  = regexp.MustCompile(`/players/(\d+)`)
	profilePathPattern = regexp.MustCompile(`/profiles/(\d+)`)
)

type Service struct{}

func NewService() *Service {
	return &Service{}
}

type ResolveDotaAccountInput struct {
	Input string `json:"input"`
}

type ResolveDotaAccountResult struct {
	Input              string            `json:"input"`
	Game               string            `json:"game"`
	CanonicalAccountID string            `json:"canonical_account_id"`
	OpenDotaAccountID  string            `json:"opendota_account_id"`
	SteamID64          string            `json:"steam_id64"`
	Source             string            `json:"source"`
	ProfileURLs        map[string]string `json:"profile_urls"`
}

func (s *Service) ResolveDotaAccount(rawInput string) (*ResolveDotaAccountResult, error) {
	input := strings.TrimSpace(rawInput)
	if input == "" {
		return nil, domain.ValidationError("input is required")
	}

	accountID, steamID64, source, err := parseDotaIdentity(input)
	if err != nil {
		return nil, err
	}

	accountIDText := strconv.FormatInt(accountID, 10)
	steamID64Text := strconv.FormatInt(steamID64, 10)
	return &ResolveDotaAccountResult{
		Input:              input,
		Game:               "dota2",
		CanonicalAccountID: accountIDText,
		OpenDotaAccountID:  accountIDText,
		SteamID64:          steamID64Text,
		Source:             source,
		ProfileURLs: map[string]string{
			"opendota": fmt.Sprintf("https://www.opendota.com/players/%s", accountIDText),
			"dotabuff": fmt.Sprintf("https://www.dotabuff.com/players/%s", accountIDText),
			"steam":    fmt.Sprintf("https://steamcommunity.com/profiles/%s", steamID64Text),
		},
	}, nil
}

func parseDotaIdentity(input string) (accountID int64, steamID64 int64, source string, err error) {
	candidate := strings.Trim(input, ` "'`)
	source = "opendota_account_id"

	if parsed, parseErr := url.Parse(candidate); parseErr == nil && parsed.Host != "" {
		host := strings.ToLower(parsed.Host)
		path := parsed.EscapedPath()
		switch {
		case strings.Contains(host, "steamcommunity.com"):
			if value := firstPathID(profilePathPattern, path); value != "" {
				candidate = value
				source = "steam_profile_url"
			}
		case strings.Contains(host, "opendota.com"):
			if value := firstPathID(playerPathPattern, path); value != "" {
				candidate = value
				source = "opendota_url"
			}
		case strings.Contains(host, "dotabuff.com"):
			if value := firstPathID(playerPathPattern, path); value != "" {
				candidate = value
				source = "dotabuff_url"
			}
		}
	}

	id, parseErr := strconv.ParseInt(candidate, 10, 64)
	if parseErr != nil || id <= 0 {
		return 0, 0, "", domain.ValidationError("input must be OpenDota account id, SteamID64, or supported profile URL")
	}

	if id > steamID64Offset {
		steamID64 = id
		accountID = steamID64 - steamID64Offset
		if accountID <= 0 {
			return 0, 0, "", domain.ValidationError("invalid SteamID64")
		}
		if source == "opendota_account_id" {
			source = "steam_id64"
		}
		return accountID, steamID64, source, nil
	}

	accountID = id
	steamID64 = steamID64Offset + accountID
	return accountID, steamID64, source, nil
}

func firstPathID(pattern *regexp.Regexp, path string) string {
	match := pattern.FindStringSubmatch(path)
	if len(match) < 2 {
		return ""
	}
	return match[1]
}
