# CLAUDE.md (public-keys-core)

Static-site repo. Hosts the operator's GPG public keys so verifiers of
signed PDFs / signed git objects can fetch the matching `.asc` and run
`gpg --verify`. Published at
`https://evandenrijd.github.io/public-keys-core` via GitHub Pages.

## Layout

```
data/                   .asc public-key exports + openvpn-ca.crt
README.org              source of truth — key table + verify instructions
index.html              generated from README.org by `make`
Makefile                org-mode HTML export wrapper
LICENSE                 GPLv3
```

## Workflow

```sh
make            # regenerate index.html from README.org
make clean      # rm index.html
```

`make` invokes `emacs --batch ... org-html-export-to-html` and renames
the output to `index.html`. The `htmlize.el >= 1.34 required` warnings
are benign — no `<src>` blocks need syntax highlighting in this README.

## Adding a new public key

1. Export from the local gpg keyring (whole primary + subkeys, ascii-armored):
   ```sh
   gpg --armor --export <KEYID> > data/signing-keyid-<FULL_FINGERPRINT_OR_LONG_ID>.asc
   ```
   Filename convention: `signing-keyid-<16-hex-long-id>.asc` for the
   `[S]` subkey's long ID — that's what readers grep for from the PDF
   footer / commit signature. Keep legacy keys; historical signatures
   still need them for verification.
2. Append a row to the `* Public Keys` table in `README.org`:
   `| Name | Key ID | [[file:data/...asc][Download]] | Comment (algo, year) |`
3. `make` to regenerate `index.html`.
4. Commit + push. GitHub Pages picks up the new files within a minute.

## Commit + changelog

Repo uses the env-family `update_changelog` workflow: stage files,
write `.changelog.pl.conf` with `commit_info(message =>, changelog =>)`,
run `update_changelog`. The script auto-bootstraps `CHANGELOG.org` on
first invocation. Never hand-edit `CHANGELOG.org`. Pre-`update_changelog`
commits (`8b2d315` initial through `f0ba104` openvpn cert) used a free-form
`Add: ...` style and have no changelog entry — `* Unreleased` starts
from the first `update_changelog`-managed commit forward.

## Consumers

- `~/vc/projects/env/expenses-core2/data/signature.pl.conf` references
  the perso ed25519 [S] subkey ~AD8B718F7FB4C89A~; the PDFs that
  `ec2-build` emits embed a footer pointing at this site.
- Other env subdirs (`gitops/`, dotfiles GPG agent config, etc.) sign
  git commits with the same key — verifiers fetch the `.asc` here.
