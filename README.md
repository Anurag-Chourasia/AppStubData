# AppStubData

Shared synthetic JSON fixtures for **ShowBook** and **myTV**, consumed as a pinned Git submodule and Swift package. No personal accounts, credentials, live artwork, or playable remote streams.

## Overview

`AppStubData` supplies deterministic mock fixtures and scenarios generated from live & structured network logs:

- **Scenarios**:
  - `positive`: Realistic success payloads with valid domain models (books, channels, streams, logos, countries, IP).
  - `empty`: Valid response envelopes containing 0 items (empty lists/dictionaries).
  - `negative`: Well-formed error responses (e.g. 400 Bad Request, 404 Not Found, 500 Server Error, or offline transport failure).

## Endpoints

### ShowBook
- `search`: Open Library search (`/search.json`)
- `discover`: Subject recommendations (`/search.json?q=subject:...`)
- `work`: Work details (`/works/{id}.json`)
- `editions`: Edition catalog (`/works/{id}/editions.json`)
- `edition`: Single edition book (`/books/{id}.json`)
- `countries`: First.org countries API (`/data/v1/countries`)
- `ip`: IP-API geolocation (`/json`)

### myTV
- `channels`: IPTV-org channels list (`/api/channels.json`)
- `streams`: IPTV-org live streams (`/api/streams.json`)
- `logos`: IPTV-org logo catalog (`/api/logos.json`)
- `categories`: IPTV-org channel categories (`/api/categories.json`)
- Dedicated error payloads: `mytvErrorResponse()`, `mytvOfflineError()`

## Usage

```swift
import AppStubData

// ShowBook fixtures
let searchData = try Fixtures.showbook(endpoint: .search, scenario: .positive)
let emptyDiscover = try Fixtures.showbook(endpoint: .discover, scenario: .empty)

// myTV fixtures
let channelsData = try Fixtures.mytv(endpoint: .channels, scenario: .positive)
let emptyStreams = try Fixtures.mytv(endpoint: .streams, scenario: .empty)

// Generic access
let rawData = try Fixtures.data("mytv-channels")
let rawString = try Fixtures.string("showbook-0")
```

## Testing

Run tests with:
```bash
swift test --scratch-path /tmp/AppStubDataBuild
```
