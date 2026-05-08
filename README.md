# QuotaScope

QuotaScope is a local-first dashboard for inspecting Codex usage from local session logs. It shows token trends, quota and risk status, session rankings, model rankings, request distribution, cache hit rate, and estimated cost.

The dashboard is a static HTML app. Your real usage export stays local in `data.js`, which is intentionally ignored by git.

## Features

- Cumulative token usage trend with absolute and logarithmic scales
- Date filters: last 24 hours, today, last 7 days, last 30 days, custom range
- Request and token distribution charts
- Real Codex quota status from local `rate_limits` events when available
- Session and model rankings
- Estimated cost by model and token type, shown in USD by default with an optional CNY conversion
- Local-only data generation from `~/.codex/sessions`

## Quick Start

Open `index.html` directly in a browser to view the bundled sample data.

To view your own local Codex usage on macOS or Linux:

```bash
python3 generate_codex_data.py
open index.html
```

On Windows PowerShell:

```powershell
py .\generate_codex_data.py
start .\index.html
```

By default, the generator reads Codex logs from:

- macOS/Linux: `~/.codex/sessions`
- Windows: `%USERPROFILE%\.codex\sessions`

If your Codex sessions are stored elsewhere, pass the path explicitly:

```powershell
py .\generate_codex_data.py --root "$env:USERPROFILE\.codex\sessions"
```

The generator writes `data.js` next to `index.html`. That file may contain private project names, session ids, timestamps, usage patterns, and quota status, so it is excluded by `.gitignore`.

## Cost Estimates

The cost card is an estimate, not an official bill. It uses local token counts and a built-in table based on OpenAI's published USD model prices. Actual ChatGPT/Codex billing, credits, and subscription quota status should always be checked with the official account or billing page.

USD is the source currency. The CNY view is only a display conversion. When available, QuotaScope fetches the USD/CNY rate from the Frankfurter API with the ECB provider selected. If that request fails, it falls back to the last bundled reference rate and marks the conversion as offline fallback in the UI.

## Verify Layout

The responsive visual audit uses Playwright:

```bash
npm install
npm run verify
```

## Privacy

QuotaScope does not send data to a server. `generate_codex_data.py` reads local Codex session logs and exports only usage metadata:

- session id and working-directory basename
- model name
- token counts
- rate limit metadata
- task duration, first-token latency, failures

It does not export prompt text, assistant messages, tool output, or file contents.

Review `data.js` before sharing screenshots or artifacts generated from your own usage.

## License

MIT
