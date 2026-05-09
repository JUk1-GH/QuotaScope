package main

import (
	"testing"
	"time"
)

func TestPreferRateLimitsKeepsGlobalCodexQuota(t *testing.T) {
	global := map[string]any{
		"limit_id":  "codex",
		"plan_type": "pro",
	}
	model := map[string]any{
		"limit_id":   "codex_bengalfox",
		"limit_name": "GPT-5.3-Codex-Spark",
	}
	globalTs := time.Date(2026, 5, 9, 9, 0, 0, 0, time.UTC)
	modelTs := globalTs.Add(10 * time.Minute)

	if preferRateLimits(model, modelTs, true, global, globalTs, true) {
		t.Fatal("model-specific rate limits must not replace global codex quota")
	}
	if !preferRateLimits(global, globalTs, true, model, modelTs, true) {
		t.Fatal("global codex quota should replace model-specific rate limits")
	}
}

func TestPreferRateLimitsUsesNewestWithinSameQuotaClass(t *testing.T) {
	older := map[string]any{
		"limit_id": "codex",
	}
	newer := map[string]any{
		"limit_id": "codex",
	}
	olderTs := time.Date(2026, 5, 9, 9, 0, 0, 0, time.UTC)
	newerTs := olderTs.Add(10 * time.Minute)

	if !preferRateLimits(newer, newerTs, true, older, olderTs, true) {
		t.Fatal("newer global quota should replace older global quota")
	}
	if preferRateLimits(older, olderTs, true, newer, newerTs, true) {
		t.Fatal("older global quota should not replace newer global quota")
	}
}

func TestCutoffForDaysSupportsAllHistory(t *testing.T) {
	now := time.Date(2026, 5, 9, 10, 0, 0, 0, time.UTC)

	if cutoff := cutoffForDays(0, now); !cutoff.IsZero() {
		t.Fatalf("all-history cutoff should be zero time, got %s", cutoff)
	}
	if cutoff := cutoffForDays(30, now); !cutoff.Equal(now.Add(-30 * 24 * time.Hour)) {
		t.Fatalf("30-day cutoff mismatch: %s", cutoff)
	}
}

func TestCacheCoversDaysHandlesAllHistory(t *testing.T) {
	if !cacheCoversDays(0, 30) {
		t.Fatal("all-history cache should cover a shorter requested window")
	}
	if cacheCoversDays(30, 0) {
		t.Fatal("30-day cache must not satisfy an all-history request")
	}
	if !cacheCoversDays(30, 7) {
		t.Fatal("30-day cache should cover a 7-day request")
	}
}

func TestMergeSessionFileDeduplicatesRepeatedSnapshots(t *testing.T) {
	tsA := "2026-05-09T10:00:00Z"
	tsB := "2026-05-09T10:00:01Z"
	snapshot := Usage{Input: 1000, Cached: 800, Output: 50, Reasoning: 10, Total: 1050}
	event := UsageEvent{
		Ts:          tsA,
		Sid:         "session-1",
		Model:       "gpt-test",
		Usage:       Usage{Input: 1000, Cached: 800, Output: 50, Reasoning: 10, Total: 1050},
		Snapshot:    snapshot,
		HasSnapshot: true,
	}
	duplicate := event
	duplicate.Ts = tsB

	loaded := LoadedData{}
	var latestLimitsTs time.Time
	seen := map[string]struct{}{}
	mergeSessionFile(ParsedFile{Sid: "session-1", Model: "gpt-test", UsageEvents: []UsageEvent{event}}, time.Time{}, &loaded, &latestLimitsTs, seen)
	mergeSessionFile(ParsedFile{Sid: "session-1", Model: "gpt-test", UsageEvents: []UsageEvent{duplicate}}, time.Time{}, &loaded, &latestLimitsTs, seen)

	if len(loaded.Events) != 1 {
		t.Fatalf("expected 1 deduplicated usage event, got %d", len(loaded.Events))
	}
	if len(loaded.Sessions) != 1 {
		t.Fatalf("expected duplicate session file to be skipped, got %d session rows", len(loaded.Sessions))
	}
	if loaded.Sessions[0].Calls != 1 || loaded.Sessions[0].Usage.Total != 1050 {
		t.Fatalf("unexpected session totals: calls=%d total=%d", loaded.Sessions[0].Calls, loaded.Sessions[0].Usage.Total)
	}
}
