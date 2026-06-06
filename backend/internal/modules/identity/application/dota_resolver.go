package application

import (
	"context"
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

// SteamResolver resolves a Steam custom (vanity) URL name to a SteamID64.
// Implemented by internal/clients/steam. Optional (may be nil).
type SteamResolver interface {
	ResolveVanity(ctx context.Context, vanity string) (string, error)
	Enabled() bool
}

type Service struct {
	steam SteamResolver
}

// NewService accepts an optional Steam resolver (variadic keeps existing callers/tests working).
func NewService(steam ...SteamResolver) *Service {
	svc := &Service{}
	if len(steam) > 0 {
		svc.steam = steam[0]
	}
	return svc
}

var vanityPathPattern = regexp.MustCompile(`/id/([^/]+)`)
var vanityBarePattern = regexp.MustCompile(`^[A-Za-z0-9_.-]{2,64}$`)

// extractVanity returns a Steam custom-URL name from /id/<name> links or a bare
// non-numeric handle; "" when the input is not a vanity candidate.
func extractVanity(input string) string {
	in := strings.Trim(strings.TrimSpace(input), ` "'`)
	if parsed, err := url.Parse(in); err == nil && parsed.Host != "" {
		if strings.Contains(strings.ToLower(parsed.Host), "steamcommunity.com") {
			if m := vanityPathPattern.FindStringSubmatch(parsed.EscapedPath()); len(m) > 1 {
				return m[1]
			}
		}
		return ""
	}
	if _, err := strconv.ParseInt(in, 10, 64); err == nil {
		return ""
	}
	if vanityBarePattern.MatchString(in) {
		return in
	}
	return ""
}

// ResolveDotaAccountAuto first tries the offline parser, then falls back to
// resolving a Steam vanity URL via the Steam Web API (if configured).
func (s *Service) ResolveDotaAccountAuto(ctx context.Context, rawInput string) (*ResolveDotaAccountResult, error) {
	if res, err := s.ResolveDotaAccount(rawInput); err == nil {
		return res, nil
	}
	vanity := extractVanity(rawInput)
	if vanity == "" {
		// not a vanity: return the original parser error
		_, err := s.ResolveDotaAccount(rawInput)
		return nil, err
	}
	if s.steam == nil || !s.steam.Enabled() {
		return nil, domain.ValidationError("для ссылки /id/<имя> нужен STEAM_API_KEY; либо используйте SteamID64 или ссылку /profiles/<id>")
	}
	steamID64, err := s.steam.ResolveVanity(ctx, vanity)
	if err != nil {
		return nil, domain.ValidationError("не удалось определить профиль Steam: " + err.Error())
	}
	res, err := s.ResolveDotaAccount(steamID64)
	if err != nil {
		return nil, err
	}
	res.Source = "steam_vanity_url"
	return res, nil
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
