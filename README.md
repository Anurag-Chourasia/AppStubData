# AppStubData

Shared synthetic JSON fixtures for multi-project architecture (**ShowBook**, **myTV**, **Motivation Daily**, and future projects), consumed as a pinned Git submodule and Swift package.

---

## Architecture Overview

`AppStubData` provides both a typed Project enum and strongly typed, brand-specific fluent query builders:

```swift
import AppStubData

// ShowBook (supporting both .showBook and .ShowBook)
let emptySearch = try Fixtures.data(for: .ShowBook).endpoint(.search).scenario(.empty)
let subjects = try Fixtures.data(for: .showBook).endpoint(.subjects).scenario(.positive)

// myTV real endpoints (channels, streams, logos, categories, feeds, languages, countries, regions, allStreams)
let channels = try Fixtures.data(for: .myTV).endpoint(.channels).scenario(.positive)
let feedsError = try Fixtures.data(for: .myTV).endpoint(.feeds).scenario(.negative)

// Motivation Daily (quotes, authors, wallpapers)
let quotesData = try Fixtures.data(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
let wallpapers = try Fixtures.data(for: .motivationDaily).endpoint(.wallpapers).scenario(.positive)

// Fluent String Builder
let quoteString = try Fixtures.string(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
```

---

## Projects & Real Endpoints

### 1. `Fixtures.Project` Enum
```swift
public enum Project: String, CaseIterable, Sendable {
    case myTV = "mytv"
    case showBook = "showbook"
    case motivationDaily = "motivationdaily"

    public var displayName: String
    public var prefix: String
}
```

### 2. Real Brand-Specific Endpoints

#### **myTV** (`Fixtures.MyTVEndpoint`)
Real endpoints used by `myTV`:
- `.channels`: IPTV-org channels catalog (`/api/channels.json`)
- `.streams`: Live streams catalog (`/api/streams.json`)
- `.logos`: Channel logos catalog (`/api/logos.json`)
- `.categories`: Channel category definitions (`/api/categories.json`)
- `.feeds`: Broadcast feeds catalog (`/api/feeds.json`)
- `.languages`: Language code definitions (`/api/languages.json`)
- `.countries`: Country codes & flags (`/api/countries.json`)
- `.regions`: Geographic regions (`/api/regions.json`)
- `.allStreams`: Full M3U playlist index (`/iptv/index.m3u`)

#### **ShowBook** (`Fixtures.ShowBookEndpoint`)
Real endpoints used by `ShowBook`:
- `.search`: Open Library search API (`/search.json`)
- `.discover`: Topic/category discovery API (`/search.json?q=subject:...`)
- `.subjects`: Open Library subjects API (`/subjects/...`)
- `.work`: Work metadata details (`/works/{id}.json`)
- `.editions`: Work editions collection (`/works/{id}/editions.json`)
- `.edition`: Single book edition record (`/books/{id}.json`)
- `.countries`: First.org countries API (`/data/v1/countries`)
- `.ip`: IP geolocation API (`http://ip-api.com/json`)

#### **Motivation Daily** (`Fixtures.MotivationDailyEndpoint`)
Real endpoints used by `Motivation Daily`:
- `.quotes`: Quotes collection (`/api/quotes`, `/api/random`)
- `.authors`: Authors directory (`/authors`)
- `.wallpapers`: Unsplash/Picsum wallpaper photos (`https://picsum.photos`)

---

## Scenarios

Every real endpoint provides three standard deterministic mock scenarios:
- `.positive`: Realistic success payloads with valid domain models.
- `.empty`: Valid empty response envelopes (`[]` or empty containers).
- `.negative`: Standard error responses (404 Not Found, 500 Server Error, or malformed/offline errors).

---

## Git Submodule Guide: How to Create and Add in Projects

A dedicated, comprehensive guide is available in [`SUBMODULE_GUIDE.md`](SUBMODULE_GUIDE.md). Below is the complete operational summary:

### 1. How to Create a Submodule from Scratch
1. **Initialize Git Repo**:
   ```bash
   mkdir AppStubData && cd AppStubData
   git init -b main
   ```
2. **Create Package Structure**: Set up `Package.swift` with platforms (iOS 16+, macOS 14+), resources directory (`Sources/AppStubData/Resources`), and test target.
3. **Add Initial Code & Gitignore**: Exclude `.build/`, `.swiftpm/`, `.DS_Store`. Commit with `git add -A && git commit -m "feat: initial commit"`.
4. **Publish to GitHub**:
   ```bash
   git remote add origin https://github.com/<owner>/AppStubData.git
   git push -u origin main
   ```

### 2. How to Add the Submodule to Projects (`ShowBook`, `myTV`)
In each consumer project root:
1. **Add Submodule**:
   ```bash
   git submodule add https://github.com/<owner>/AppStubData.git Submodules/AppStubData
   ```
2. **Commit Submodule Registration**:
   ```bash
   git commit -m "feat: add AppStubData submodule"
   git push origin main
   ```

### 3. How Teammates & CI Clone Projects with Submodules
```bash
# Clone with submodules initialized in one step:
git clone --recurse-submodules https://github.com/<owner>/<repo>.git

# Or if already cloned:
git submodule update --init --recursive
```

### 4. How to Update Submodule Changes Across Projects
1. **Make, commit, and push changes in `AppStubData` FIRST**:
   ```bash
   cd AppStubData
   git add -A && git commit -m "feat: update fixtures"
   git push origin main
   ```
2. **Pull updates into consumer projects and bump pointer**:
   ```bash
   cd <ConsumerProject>/Submodules/AppStubData
   git pull origin main
   cd ../..
   git add Submodules/AppStubData
   git commit -m "chore: bump AppStubData submodule to latest"
   git push origin main
   ```

---

## Testing

Run tests with:
```bash
DEVELOPER_DIR="/Applications/Xcode 27.1.app/Contents/Developer" xcrun swift test --scratch-path /tmp/AppStubDataBuild
```
