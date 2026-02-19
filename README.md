# Stand-Up Timer

[![Snap][snap-badge]][snap-link]
[![Codecov Status][codecov-badge]][codecov-link]

**Stand-Up Timer** is a lightweight desktop application that helps run efficient
stand-up or daily-scrum meetings.

## Basic Usage

- Add team members – Add team members one-by-one or from your clipboard.
- Select speakers – Click a name to include/exclude it.
- Check "Expected time" – Shows total minutes based on your selection.
- Start – The first speaker's timer begins.
- Stop/Resume – Pause if needed.
- Next person – Skip ahead manually.
- Restart – Reset the whole session without closing the app.

![Screenshot](./screenshot.png)

## Installation

Stand-Up Timer is available on all major Linux distributions.

On snap-ready systems, you can install it on the command-line with:

```shell
sudo snap install standup-timer
```

## CI/CD Dashboard

Stand-Up Timer can display the status of CI/CD workflows during the meeting.
Configure it by creating `~/.config/standup-timer/workflows.yaml`.

### GitHub Actions

```yaml
github_token: ghp_xxxx          # optional default token for all GitHub entries

workflows:
  - label: "My workflow"        # display name (optional)
    provider: github
    owner: canonical             # GitHub organisation or user
    repo: my-repo
    workflow: ci.yaml            # workflow filename
    token: ghp_xxxx              # per-entry token (overrides github_token)
```

The `token` is only required for private repositories. It can be set once as
`github_token` at the top level and will apply to all GitHub entries that do
not specify their own `token`.

### Jenkins

```yaml
workflows:
  - label: "My Jenkins job"     # display name (optional)
    provider: jenkins
    url: https://jenkins.example.com/job/my-job
    username: admin              # optional
    token: abc123                # Jenkins API token (optional)
```

### Mixed example

```yaml
github_token: ghp_xxxx

workflows:
  - label: "Checkbox Daily Builds"
    provider: github
    owner: canonical
    repo: checkbox
    workflow: checkbox-daily-native-builds.yaml

  - label: "Release pipeline"
    provider: jenkins
    url: https://jenkins.example.com/job/release
    username: admin
    token: abc123
```

## Community and Support

You can report any issues, bugs, or feature requests on the project's
[GitHub repository][github-issues].

## Contribute to Stand-Up Timer

Stand-Up Timer is open source. Contributions are welcome.

If you're interested, start with the [contributing guide](./CONTRIBUTING.md).

## License and Copyright

Stand-Up Timer is released under the [GPL-3.0 license](./LICENSE).

© 2025 Canonical Ltd.

[snap-badge]: https://snapcraft.io/standup-timer/badge.svg
[snap-link]: https://snapcraft.io/standup-timer
[codecov-badge]: https://codecov.io/github/canonical/standup-timer/graph/badge.svg
[codecov-link]: https://codecov.io/github/canonical/standup-timer
[github-issues]: https://github.com/canonical/standup-timer/issues
