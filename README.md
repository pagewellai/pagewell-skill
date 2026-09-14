# pagewell binaries — v0.1.1

Prebuilt `pagewell` CLI binaries for the release on `main`. This branch
holds the **current release only** and is replaced whole on every publish; it
is never tagged, so cloning the skill does not drag every version's binaries
along.

Nothing here is meant to be cloned. `scripts/install.sh` on `main`
downloads the one file this machine needs and verifies it against
`bin/SHA256SUMS`; `pagewell upgrade` does the same. The skill lives on
[`main`](https://github.com/pagewellai/pagewell-skill).

| Platform | Binary | Size |
|---|---|---|
| darwin/amd64 | `pagewell_darwin_amd64` | 12M |
| darwin/arm64 | `pagewell_darwin_arm64` | 11M |
| linux/amd64 | `pagewell_linux_amd64` | 11M |
| linux/arm64 | `pagewell_linux_arm64` | 11M |
| windows/amd64 | `pagewell_windows_amd64.exe` | 12M |
| windows/arm64 | `pagewell_windows_arm64.exe` | 11M |
