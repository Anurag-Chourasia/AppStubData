# AppStubData

Shared synthetic JSON fixtures for multi-project architecture (including **ShowBook**, **myTV**, and future projects), consumed as a pinned Git submodule and Swift package.

## Project Enum Architecture

The `Fixtures.Project` enum defines all supported consumer projects:

```swift
public enum Project: String, CaseIterable, Sendable {
    case myTV = "mytv"
    case showBook = "showbook"
    // Add new projects here as the monorepo/ecosystem expands:
    // case motivationDaily = "motivationdaily"
}
```

### Adding a New Project
1. Add the case to `Fixtures.Project` (e.g. `case motivationDaily = "motivationdaily"`).
2. Place JSON fixtures inside `Sources/AppStubData/Resources/` named with the convention:
   - `{project}-{endpoint}-{scenario}.json` (e.g., `motivationdaily-quotes-positive.json`)
   - `{project}-{fixtureName}.json` (e.g., `motivationdaily-defaults.json`)
3. Access fixtures via:
   ```swift
   let data = try Fixtures.data(for: .motivationDaily, endpoint: "quotes", scenario: .positive)
   ```

---

## Scenarios

- `positive`: Realistic success payloads with valid domain models.
- `empty`: Valid response envelopes containing 0 items (`[]` or empty containers).
- `negative`: Well-formed error responses (e.g. 400 Bad Request, 404 Not Found, 500 Server Error, or offline transport failure).

---

## Usage

### 1. Project-Scoped Access (Extensible for all projects)
```swift
import AppStubData

// Load using Project enum:
let myTVChannels = try Fixtures.data(for: .myTV, endpoint: "channels", scenario: .positive)
let showBookSearch = try Fixtures.data(for: .showBook, endpoint: "search", scenario: .positive)
let myTVConfig = try Fixtures.data(for: .myTV, name: "channels")
```

### 2. Typed Project Helpers
```swift
// ShowBook
let searchData = try Fixtures.showbook(endpoint: .search, scenario: .positive)
let emptyDiscover = try Fixtures.showbook(endpoint: .discover, scenario: .empty)

// myTV
let channelsData = try Fixtures.mytv(endpoint: .channels, scenario: .positive)
let emptyStreams = try Fixtures.mytv(endpoint: .streams, scenario: .empty)
```

---

## Testing

Run tests with:
```bash
swift test --scratch-path /tmp/AppStubDataBuild
```
