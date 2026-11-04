# Contributing

## Workflow

1. Open an issue for any change that adds a component or changes a pinned source version.
2. Fork, branch from `main`, and keep each pull request to one change.
3. Source repositories and refs are pinned in `ee/config.sh` and `iop/config.sh`; change a pin there, not in a step script.
4. Run `bash -n` on every script you touch and build the affected target (`ee/build.sh`, `iop/build.sh`, or `scripts/release-linux.sh`).

## Code style

- Comments are single lines and only for tool or compiler behavior that is not obvious from the code.
- Shared logic belongs in `lib/common.sh`; step scripts contain only target-specific configuration.
- Scripts are committed with the executable bit set.

## AI-assisted contributions

AI-generated code is accepted. Contributions that the author cannot explain without AI assistance are discouraged and may be closed.

- State in the pull request which AI tool and model were used, or that none was.
- Write the pull request description yourself, without AI.
- You are responsible for every line you submit: be prepared to explain and defend each change in review.

## License

By submitting a contribution, you agree that it is licensed under the same license as this repository (see [LICENSE](LICENSE)).
