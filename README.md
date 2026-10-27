# AppStubData

Shared synthetic JSON fixtures for multi-project architecture (including **ShowBook**, **myTV**, **Motivation Daily**, and future projects), consumed as a pinned Git submodule and Swift package.

## Fluent Project & Endpoint Architecture

The `Fixtures` package provides a fluent, type-safe builder API across projects, endpoints, and scenarios:

```swift
// Fluent Builder API:
let quotesData = try Fixtures.data(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
let channelsData = try Fixtures.data(for: .myTV).endpoint(.channels).scenario(.positive)
let bookSearch = try Fixtures.data(for: .showBook).endpoint(.search).scenario(.positive)

// Fluent String Builder:
let quoteText = try Fixtures.string(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
```

---

## Enums

### 1. `Fixtures.Project`
```swift
public enum Project: String, CaseIterable, Sendable {
    case myTV = "mytv"
    case showBook = "showbook"
    case motivationDaily = "motivationdaily"
    // Extend here for new apps
}
```

### 2. `Fixtures.Endpoint`
```swift
public enum Endpoint: String, CaseIterable, Sendable {
    // ShowBook
    case search
    case discover
    case work
    case editions
    case edition
    case countries
    case ip

    // myTV
    case channels
    case streams
    case logos
    case categories

    // MotivationDaily
    case quotes
    case authors
}
```

### 3. `Fixtures.Scenario`
- `positive`: Realistic success payloads with valid domain models.
- `empty`: Valid response envelopes containing 0 items (`[]` or empty containers).
- `negative`: Well-formed error responses (e.g. 400 Bad Request, 404 Not Found, 500 Server Error, or offline transport failure).

---

## Adding a New Project & Endpoints

1. **Extend `Fixtures.Project`** (e.g. `case myNewApp = "mynewapp"`).
2. **Extend `Fixtures.Endpoint`** (e.g. `case feeds`).
3. **Add JSON fixtures** into `Sources/AppStubData/Resources/` named:
   - `{project}-{endpoint}-{scenario}.json` (e.g. `mynewapp-feeds-positive.json`, `mynewapp-feeds-empty.json`, `mynewapp-feeds-negative.json`)
   - `{project}-{fixtureName}.json`
4. **Access seamlessly**:
   ```swift
   let data = try Fixtures.data(for: .myNewApp).endpoint(.feeds).scenario(.positive)
   ```

---

## Testing

Run tests with:
```bash
swift test --scratch-path /tmp/AppStubDataBuild
```
