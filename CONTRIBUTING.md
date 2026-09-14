# Contributing

Maintainer notes for this repository: the rules that keep it consistent with the
other repositories in this organisation and with the documentation site.

If you came here to use this repository rather than change it, read `AGENTS.md`
instead.

## Rule one: no dependencies

An example runs with a stock PowerShell and nothing else. `Invoke-RestMethod`
ships with the shell, so there is no module from the gallery, no `Install-Module`
and no helper from this repository. A reader copies the file into their script
and it works.

## Rule two: write for 5.1, not just for 7

The reader is a Windows server administrator, which in practice means Windows
PowerShell 5.1. Three things in every example exist only for that, and each one
still works on 7 if removed, which is what makes them easy to lose:

- **A UTF-8 BOM at the start of the file.** Without it 5.1 reads the file with
  the system ANSI codepage and the Persian text is destroyed. `./check-encoding.sh`
  is the guard; git cannot enforce this, since a BOM is ordinary content to it.
- **The body sent as bytes:** `[System.Text.Encoding]::UTF8.GetBytes($payload)`.
  Hand 5.1 a string and it encodes with the default codepage, so a Persian
  message arrives as question marks.
- **`-Depth` on `ConvertTo-Json`.** The default on 5.1 is 2, and `Recipients`
  then serialises as the literal string `System.Collections.Hashtable`.

The `Tls12` line belongs to the same family: older Windows builds still default
to TLS 1.0 and the service refuses them.

## Rule three: ordered hashtables

Payloads use `[ordered]@{ … }`, not `@{ … }`. A plain hashtable has no order, so
the generated JSON comes out shuffled and no longer lines up with the field
order in the reference page. `[ordered]` costs nothing and keeps the two
readable side by side.

## Rule four: the examples are the documentation

Each file carries `# docs:start` and `# docs:end`. The region between them is
lifted verbatim into the method's page on docs.payam-resan.com, so it is read by
people who have never seen this repository.

Two consequences:

- **Full-line comments are stripped** when the region is lifted. Anything the
  reader must see has to be code. The `Success` check is an `if`, not a note.
- The file name matches the reference page slug exactly: `send-bulk.ps1`,
  `status-by-user-trace-id.ps1`. A path with two variants gets two files, the
  plain name for `POST` and a `-get` suffix for `GET`.

The full contract lives in the `handbook` repository, section `docs-site`, file
`code-samples.md`.

## Rule five: check Success, never the status code

The service answers `200` to everything, including a wrong key and an empty
account, so the absence of an exception proves nothing:

```powershell
if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}
```

## Rule six: a version is a folder

A new service version means a new `examples/v<n>/`. No file inside an existing
version folder is moved or renamed; older versions still have users.

## Secrets

The key comes from `PAYAM_RESAN_API_KEY` in the environment. No key, no real
phone number and no customer name goes into a file here, not even a dead one.
Example numbers are `9121112222` upward and the example key is
`123456-XXXXXXXXXXXXXXX`.

## Layout

| Path | What it holds |
|---|---|
| `examples/v3/` | one self-contained file per service operation |
| `check-encoding.sh` | checks that every example starts with a BOM |
| `.env.example` | the environment variables the examples read |

## Before every commit

```bash
./check-encoding.sh

for f in examples/v3/*.ps1; do
	errors=$(pwsh -NoLogo -NoProfile -Command "
		\$e = \$null
		[void][System.Management.Automation.Language.Parser]::ParseFile('$f', [ref]\$null, [ref]\$e)
		\$e.Count
	")
	[ "$errors" = "0" ] || echo "FAILED $f ($errors parse errors)"
done
```

Point them at `api/V3SandBox/` before running one for real, so no message goes
out.

## Git

Semantic messages, `type(scope): subject`, with no explanatory body and no
attribution trailer. Commits here are authored as Payam Resan.
