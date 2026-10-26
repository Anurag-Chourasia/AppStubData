# AppStubData

Shared synthetic JSON fixtures for ShowBook and MyTV, consumed as a pinned Git submodule and local Swift package. No personal accounts, credentials, live artwork, or playable remote streams.

`Fixtures.data(name)` and `Fixtures.string(name)` throw for missing files. Each consumer chooses success/empty/offline behavior; Release must not enable fixture mode. Update fixtures here, test their JSON, review the change, then deliberately advance each app's submodule commit. Never follow a floating branch in CI.

Run `swift test --scratch-path /tmp/AppStubDataBuild`.
