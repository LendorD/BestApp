package application

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"gamementor/internal/domain"
)

// TokenManager issues and verifies signed JWTs (HS256). It is implemented with
// the standard library only, so no external JWT dependency is required.
type TokenManager struct {
	secret []byte
	ttl    time.Duration
	now    func() time.Time
}

// Claims is the JWT payload we issue for authenticated users.
type Claims struct {
	UserID   int64  `json:"uid"`
	Username string `json:"usr"`
	Email    string `json:"eml"`
	IssuedAt int64  `json:"iat"`
	Expires  int64  `json:"exp"`
}

// GetUserID / GetUsername let *Claims satisfy the delivery auth-middleware
// TokenClaims interface without the middleware importing this package.
func (c *Claims) GetUserID() int64    { return c.UserID }
func (c *Claims) GetUsername() string { return c.Username }

func NewTokenManager(secret string, ttl time.Duration) *TokenManager {
	if strings.TrimSpace(secret) == "" {
		secret = "gamementor-dev-insecure-secret-change-me"
	}
	if ttl <= 0 {
		ttl = 168 * time.Hour
	}
	return &TokenManager{secret: []byte(secret), ttl: ttl, now: time.Now}
}

// TTL exposes the configured token lifetime.
func (m *TokenManager) TTL() time.Duration { return m.ttl }

// Generate builds a signed token for the given user.
func (m *TokenManager) Generate(userID int64, username, email string) (string, time.Time, error) {
	now := m.now().UTC()
	exp := now.Add(m.ttl)
	claims := Claims{
		UserID:   userID,
		Username: username,
		Email:    email,
		IssuedAt: now.Unix(),
		Expires:  exp.Unix(),
	}

	header := segment(map[string]string{"alg": "HS256", "typ": "JWT"})
	payload, err := json.Marshal(claims)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("marshal claims: %w", err)
	}
	body := header + "." + encode(payload)
	signature := m.sign(body)
	return body + "." + signature, exp, nil
}

// Parse verifies the token signature and expiry, returning its claims.
func (m *TokenManager) Parse(token string) (*Claims, error) {
	token = strings.TrimSpace(token)
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return nil, domain.Unauthorized("invalid token format")
	}
	body := parts[0] + "." + parts[1]
	expected := m.sign(body)
	if !hmac.Equal([]byte(expected), []byte(parts[2])) {
		return nil, domain.Unauthorized("invalid token signature")
	}

	raw, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return nil, domain.Unauthorized("invalid token payload")
	}
	var claims Claims
	if err := json.Unmarshal(raw, &claims); err != nil {
		return nil, domain.Unauthorized("invalid token payload")
	}
	if claims.UserID <= 0 {
		return nil, domain.Unauthorized("invalid token subject")
	}
	if claims.Expires > 0 && m.now().UTC().Unix() > claims.Expires {
		return nil, domain.Unauthorized("token expired")
	}
	return &claims, nil
}

func (m *TokenManager) sign(body string) string {
	mac := hmac.New(sha256.New, m.secret)
	mac.Write([]byte(body))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func segment(v any) string {
	raw, _ := json.Marshal(v)
	return encode(raw)
}

func encode(raw []byte) string {
	return base64.RawURLEncoding.EncodeToString(raw)
}
