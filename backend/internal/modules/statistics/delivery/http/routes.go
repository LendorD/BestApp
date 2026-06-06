// Package http previously exposed the Dota lab routes. Those routes now live in
// the dota module (internal/modules/dota/delivery/http), which delegates to the
// statistics application service. Statistics is a pure service layer with no HTTP.
package http
