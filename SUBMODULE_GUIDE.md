# Git Submodule End-to-End Guide: Creation, Integration, & Maintenance

This comprehensive guide explains how to build, integrate, and maintain Git submodules across multiple iOS/macOS projects using **`AppStubData`** as the reference architecture.

---

## Table of Contents
1. [What is a Git Submodule?](#what-is-a-git-submodule)
2. [Phase 1: Creating a Submodule Repository from Scratch](#phase-1-creating-a-submodule-repository-from-scratch)
3. [Phase 2: Adding the Submodule to Consumer Projects](#phase-2-adding-the-submodule-to-consumer-projects)
4. [Phase 3: Cloning Projects Containing Submodules](#phase-3-cloning-projects-containing-submodules)
5. [Phase 4: Making Updates & Bumping Pointers](#phase-4-making-updates--bumping-pointers)
6. [Phase 5: Consuming the Submodule in Xcode & Swift Packages](#phase-5-consuming-the-submodule-in-xcode--swift-packages)
7. [Phase 6: Best Practices & Common Pitfalls](#phase-6-best-practices--common-pitfalls)

---

## What is a Git Submodule?

A **Git Submodule** allows you to keep an independent Git repository as a subdirectory of another Git repository. 

Key characteristics:
- **Pinned Commit**: The parent (consumer) repository does not track the submodule's files directly; it only records a single commit SHA (a *gitlink* tree entry).
- **Decoupled Lifecycle**: The submodule has its own commit history, branches, tags, and remotes.
- **Deterministic Builds**: Different consumer apps (e.g. `ShowBook` and `myTV`) can point to the exact same tested commit, or advance at their own pace without unexpected breakage.

---

## Phase 1: Creating a Submodule Repository from Scratch

### Step 1: Initialize the Local Git Repository
Create a directory for your shared package and initialize Git:
```bash
mkdir AppStubData
cd AppStubData
git init -b main
```

### Step 2: Set Up Swift Package Manager (SPM) Structure
Create the standard package layout:
```bash
mkdir -p Sources/AppStubData/Resources
mkdir -p Tests/AppStubDataTests
```

Create `Package.swift`:
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppStubData",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppStubData", targets: ["AppStubData"])
    ],
    targets: [
        .target(
            name: "AppStubData",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AppStubDataTests",
            dependencies: ["AppStubData"]
        )
    ]
)
```

### Step 3: Add `.gitignore`
Ensure build artifacts and system files are excluded:
```gitignore
.DS_Store
/.build
/.swiftpm
*.xcodeproj
*.xcworkspace
DerivedData/
```

### Step 4: Commit Initial Code
```bash
git add -A
git commit -m "feat: initial commit for AppStubData package"
```

### Step 5: Create Remote Repository & Push
Create an empty repository on GitHub (`https://github.com/<owner>/AppStubData.git`) and push:
```bash
git remote add origin https://github.com/<owner>/AppStubData.git
git branch -M main
git push -u origin main
```

---

## Phase 2: Adding the Submodule to Consumer Projects

Repeat these steps inside each project that needs to consume the submodule (e.g., `ShowBook`, `myTV`):

### Step 1: Add the Submodule
In the root directory of your consumer repository:
```bash
cd /path/to/MyTV
git submodule add https://github.com/<owner>/AppStubData.git Submodules/AppStubData
```

### Step 2: What Git Creates
Running `git submodule add` automatically:
1. Clones `AppStubData` into `Submodules/AppStubData`.
2. Creates or updates the `.gitmodules` file in the consumer project root:
   ```ini
   [submodule "Submodules/AppStubData"]
       path = Submodules/AppStubData
       url = https://github.com/<owner>/AppStubData.git
   ```
3. Stages `.gitmodules` and the submodule directory `Submodules/AppStubData` (recording the current commit SHA).

### Step 3: Commit and Push Submodule Registration
```bash
git status
# Changes to be committed:
#   new file:   .gitmodules
#   new file:   Submodules/AppStubData

git commit -m "feat: add AppStubData submodule"
git push origin main
```

---

## Phase 3: Cloning Projects Containing Submodules

When teammates or CI systems clone a repository that contains submodules:

### Method A: Single Command (Recommended)
Clone with `--recurse-submodules` so Git automatically fetches all submodules:
```bash
git clone --recurse-submodules https://github.com/<owner>/MyTV.git
```

### Method B: Two-Step Initialization
If someone already ran a plain `git clone`:
```bash
git clone https://github.com/<owner>/MyTV.git
cd MyTV

# Initialize and pull the pinned submodule commit:
git submodule update --init --recursive
```

---

## Phase 4: Making Updates & Bumping Pointers

### Step 1: Make Changes in the Submodule Repo
Always push updates to the submodule's remote **first**:
```bash
cd /path/to/AppStubData
# Edit Fixtures.swift or add JSON fixtures in Sources/AppStubData/Resources
git add -A
git commit -m "feat: add new endpoint fixtures"
git push origin main
```
*Note the new commit SHA (e.g. `e836e95`).*

### Step 2: Update the Submodule in Each Consumer Project
Inside consumer repositories (`MyTV`, `ShowBook`), pull the latest submodule commit:

```bash
# Option A: Pull directly inside the submodule directory
cd /path/to/MyTV/Submodules/AppStubData
git checkout main
git pull origin main

# Return to parent project
cd /path/to/MyTV
```

Or from the consumer root using git's remote update helper:
```bash
# Option B: One-liner from consumer root
git submodule update --remote --merge Submodules/AppStubData
```

### Step 3: Verify and Commit the Submodule Pointer Bump
Running `git status` in the consumer project will show:
```
modified:   Submodules/AppStubData (new commits)
```

Stage and commit this change:
```bash
git add Submodules/AppStubData
git commit -m "chore: bump AppStubData submodule to e836e95"
git push origin main
```

> **Crucial Rule**: The consumer repo only commits the **pointer** (the commit SHA) of the submodule. It never commits files inside the submodule.

---

## Phase 5: Consuming the Submodule in Xcode & Swift Packages

### In Xcode Projects (`.xcodeproj`)
1. Open the consumer project in Xcode (e.g. `MyTV.xcodeproj`).
2. Open Finder and locate the `Submodules/AppStubData` folder.
3. Drag the `AppStubData` folder into the Xcode Project Navigator (at the root level alongside your project).
4. Select your app target > **General** > **Frameworks, Libraries, and Embedded Content**.
5. Click **+** and select `AppStubData`.

### In Swift Packages (`Package.swift`)
If your consumer is a Swift Package, reference the submodule locally:
```swift
dependencies: [
    .package(path: "Submodules/AppStubData")
]
```

### Usage in Code
```swift
import AppStubData

// Strongly typed brand-specific fluent API:
let data = try Fixtures.data(for: .myTV).endpoint(.channels).scenario(.positive)
let search = try Fixtures.data(for: .ShowBook).endpoint(.search).scenario(.empty)
```

---

## Phase 6: Best Practices & Common Pitfalls

### 1. The "Push Order" Rule (Avoid Detached Remote Breakage)
> **NEVER** push a consumer project that points to a submodule commit that only exists locally on your machine.
- **Rule**: Always `git push` inside `AppStubData` first.
- If you forget, CI or your team will encounter:
  `fatal: reference is not a tree: <commit-sha>`

### 2. The "Detached HEAD" Trap
When Git runs `git submodule update`, it checks out the exact pinned commit without attaching to a branch (`HEAD detached at <sha>`).
- If you make edits inside `Submodules/AppStubData`:
  ```bash
  cd Submodules/AppStubData
  git checkout main   # Attach to main before committing!
  git pull origin main
  # make edits, commit, and push
  ```

### 3. Automated Verification Script
Add a verification script (e.g., `Scripts/verify-submodules.py`) to your CI pipeline:
```python
import subprocess
import sys

def verify_submodules():
    res = subprocess.run(["git", "submodule", "status"], capture_output=True, text=True, check=True)
    for line in res.stdout.strip().splitlines():
        if line.startswith("+"):
            print(f"Error: Submodule is out of sync with pinned commit: {line}")
            sys.exit(1)
        if line.startswith("-"):
            print(f"Error: Submodule is uninitialized: {line}")
            sys.exit(1)
    print("All submodules match their pinned commits.")

if __name__ == "__main__":
    verify_submodules()
```
Run this script in GitHub Actions / Xcode Cloud prior to running test suites.
