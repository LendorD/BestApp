package application

import "testing"

func TestResolveDotaAccountOpenDotaID(t *testing.T) {
	service := NewService()
	result, err := service.ResolveDotaAccount("369102305")
	if err != nil {
		t.Fatalf("ResolveDotaAccount() error = %v", err)
	}
	if result.CanonicalAccountID != "369102305" {
		t.Fatalf("canonical account id = %s", result.CanonicalAccountID)
	}
	if result.SteamID64 != "76561198329368033" {
		t.Fatalf("steam id64 = %s", result.SteamID64)
	}
	if result.Source != "opendota_account_id" {
		t.Fatalf("source = %s", result.Source)
	}
}

func TestResolveDotaAccountSteamID64(t *testing.T) {
	service := NewService()
	result, err := service.ResolveDotaAccount("76561198329368033")
	if err != nil {
		t.Fatalf("ResolveDotaAccount() error = %v", err)
	}
	if result.CanonicalAccountID != "369102305" {
		t.Fatalf("canonical account id = %s", result.CanonicalAccountID)
	}
	if result.Source != "steam_id64" {
		t.Fatalf("source = %s", result.Source)
	}
}

func TestResolveDotaAccountProfileURL(t *testing.T) {
	service := NewService()
	result, err := service.ResolveDotaAccount("https://www.opendota.com/players/369102305")
	if err != nil {
		t.Fatalf("ResolveDotaAccount() error = %v", err)
	}
	if result.CanonicalAccountID != "369102305" {
		t.Fatalf("canonical account id = %s", result.CanonicalAccountID)
	}
	if result.Source != "opendota_url" {
		t.Fatalf("source = %s", result.Source)
	}
}
