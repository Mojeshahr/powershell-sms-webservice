<div align="center">

<a href="https://payam-resan.com">
  <img src=".github/assets/logo.svg" width="64" height="64" alt="Payam Resan">
</a>

<h1>PowerShell examples for the Payam Resan SMS web service</h1>

Talk to the <a href="https://payam-resan.com"><b>Payam Resan SMS panel</b></a> from PowerShell<br>
One runnable file per API method, with no dependencies

[![API](https://img.shields.io/badge/API-V3-0a7cbd)](https://payam-resan.com)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391fe)](https://learn.microsoft.com/powershell)
[![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)](#quick-start)
[![License](https://img.shields.io/badge/license-MIT-6e7781)](LICENSE)

<a href="README.md">فارسی</a> · <b>English</b>

</div>

<sub>Looking for another language? The same examples exist for the others at
[github.com/Mojeshahr](https://github.com/Mojeshahr).</sub>

---

## Quick start

```powershell
git clone https://github.com/Mojeshahr/powershell-sms-webservice.git
cd powershell-sms-webservice

$env:PAYAM_RESAN_API_KEY = '123456-XXXXXXXXXXXXXXX'
$env:PAYAM_RESAN_SENDER  = '30004040'

.\examples\v3\account-info.ps1
```

No module from the gallery and nothing else to install. Everything runs on
`Invoke-RestMethod`, which ships with PowerShell.

Start with `account-info.ps1`. It sends nothing, spends no credit, and if it
answers then both the key and the connection are fine.

## Windows PowerShell 5.1 or PowerShell 7

Both. But three things in these examples are there only for 5.1, and removing
any of them leaves something that still works on 7 and breaks on 5.1:

**The files are saved with a BOM.** Windows PowerShell 5.1 reads a BOM-less
file using the system ANSI codepage, so the Persian text inside the script
arrives mangled and sometimes will not even parse. PowerShell 7 assumes UTF-8
and does not care, which is precisely what makes this easy to break without
noticing. `check-encoding.sh` is the guard.

**The body is sent as bytes, not as a string.** Give 5.1 a string and
`Invoke-RestMethod` encodes it with the default codepage, so a Persian message
arrives as question marks:

```powershell
-Body ([System.Text.Encoding]::UTF8.GetBytes($payload))
```

**Do not drop `-Depth` from `ConvertTo-Json`.** The default depth on 5.1 is 2,
so `Recipients` is silently turned into the string
`System.Collections.Hashtable` and the service answers with a confusing error.

The `Tls12` line is there for older Windows builds that still default to
TLS 1.0 and get refused by the service.

## Before sending anything real

There is a sandbox server that answers exactly like production but sends no
message and spends no credit. Swap `V3` for `V3SandBox` in the URL. The one
exception is `TokenList`, which the sandbox does not implement.

## The methods

| Example | Method | What it does |
|---|---|---|
| [account-info.ps1](examples/v3/account-info.ps1) | `AccountInfo` | Credit and active lines |
| [send.ps1](examples/v3/send.ps1) | `Send` | Simple send over `GET` |
| [send-bulk.ps1](examples/v3/send-bulk.ps1) | `SendBulk` | One text to many recipients, with tracking ids |
| [send-multiple.ps1](examples/v3/send-multiple.ps1) | `SendMultiple` | A separate text per recipient |
| [token-list.ps1](examples/v3/token-list.ps1) | `TokenList` | The account's templates |
| [send-token-single.ps1](examples/v3/send-token-single.ps1) | `SendTokenSingle` | Send a template to one number |
| [send-token-single-get.ps1](examples/v3/send-token-single-get.ps1) | `SendTokenSingle` | The same, over `GET` |
| [send-token-multi.ps1](examples/v3/send-token-multi.ps1) | `SendTokenMulti` | One template, many recipients |
| [status-by-id.ps1](examples/v3/status-by-id.ps1) | `StatusById` | Status by the service's id |
| [status-by-user-trace-id.ps1](examples/v3/status-by-user-trace-id.ps1) | `StatusByUserTraceId` | Status by your own id |
| [get-inbox.ps1](examples/v3/get-inbox.ps1) | `GetInbox` | Messages people sent to your lines |

## Running from Task Scheduler

The reader this repository is written for is a Windows server administrator,
and there a script usually runs from the scheduler rather than a console. Two
things matter.

Put the key in a **machine-level** environment variable, not in the task and
not in the code:

```powershell
[Environment]::SetEnvironmentVariable('PAYAM_RESAN_API_KEY', '123456-XXX', 'Machine')
```

And set the execution policy for that one call rather than permanently:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\scripts\send-bulk.ps1
```

## Using this in your own project

Every example is deliberately free of any dependency on this repository, so
copying the file into your script is enough. If you need several methods
together, wrap each file's body in a `function` and take the key as a
parameter.

## Things that will save you time

**Do not read the HTTP status code.** The service answers `200` to everything,
including a wrong key, so the absence of an exception proves nothing. Decide on
the `Success` field. Every example here does.

**Recipient numbers carry no leading zero.** Use `9121112222`, or
`989121112222` with the country code. A number that does not start with `9` or
`989` returns error code `13`.

**Do not encode the text twice.** In `send.ps1`, `EscapeDataString` already
does it once. Encode beforehand and the message arrives full of `%D8`.

**Send a unique `UserTraceId` per recipient.** After a timeout it is the only
way to learn whether the message was registered.

## Key safety

The key is a secret. It does not belong in a code repository, in browser
JavaScript, or in a mobile app bundle. It belongs in an environment variable,
which is where every example here reads it from.

If a key leaks, issue a new one from the panel. A deleted key never comes back.

## Layout

| Path | What it holds |
|---|---|
| `examples/v3/` | One self-contained example per service operation |
| `check-encoding.sh` | Checks that every file starts with a BOM |
| `.env.example` | The environment variables the examples read |

The `v3` in the path is deliberate. A new service version means a new
`examples/v<n>/`, with the existing folder left alone.

## Documentation and support

The full guide to the web service is at
[docs.payam-resan.com](https://docs.payam-resan.com), and the machine-readable
OpenAPI description is in
[sms-webservice-spec](https://github.com/Mojeshahr/sms-webservice-spec).

Question or bug? [Open an issue](https://github.com/Mojeshahr/powershell-sms-webservice/issues)
or contact [support](https://payam-resan.com).

## License

Released under the MIT license. Full text in [`LICENSE`](LICENSE).

<br>
<div align="center">
  <sub>
    <img src=".github/assets/logo.svg" width="16" height="16" alt="" align="top">
    &nbsp;<b>Payam Resan SMS Panel - Moje Shahr</b>&nbsp;
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset=".github/assets/mojeshahr-dark.svg">
      <img src=".github/assets/mojeshahr-light.svg" width="16" height="16" alt="" align="top">
    </picture>
  </sub>
  <br>
  <sub>
    <a href="https://payam-resan.com">payam-resan.com</a>
    &nbsp;·&nbsp;
    <a href="https://mojeshahr.ir">mojeshahr.ir</a>
  </sub>
</div>
