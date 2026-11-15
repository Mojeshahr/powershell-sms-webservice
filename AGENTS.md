# Working with this repository

You are looking at runnable PowerShell scripts for the **Payam Resan** SMS web
service (`www.payam-resan.com`, API V3), an Iranian SMS provider. The reader
these are written for is a Windows server administrator, which in practice means
**Windows PowerShell 5.1** — monitoring alerts, scheduled reminders, a line in a
maintenance script.

Nothing to install: `Invoke-RestMethod` ships with the shell.

## Start here

```powershell
$env:PAYAM_RESAN_API_KEY = '123456-XXXXXXXXXXXXXXX'
.\examples\v3\account-info.ps1
```

`account-info.ps1` sends nothing, spends no credit, and answering proves the key
and the connection.

## Rule 1: three things exist only for PowerShell 5.1

Each of them still *works* on PowerShell 7 when removed, which is exactly what
makes them easy to lose. If the user is on Windows Server, they are on 5.1.

**A UTF-8 BOM at the start of the file.** Without it, 5.1 reads the file with the
system ANSI codepage and the Persian text inside is destroyed — sometimes it
will not even parse. Git treats a BOM as ordinary content, so nothing in
`.gitattributes` can enforce it; `check-encoding.sh` is the guard. If you create
a new script for the user, write it with a BOM.

**The body sent as bytes**, not as a string:

```powershell
$body = [System.Text.Encoding]::UTF8.GetBytes($payload)
```

Hand 5.1 a string and it encodes with the default codepage, so a Persian message
arrives as question marks. Always paired with
`-ContentType 'application/json; charset=utf-8'`.

**`-Depth` on `ConvertTo-Json`.** The default on 5.1 is `2`, and `Recipients`
then serialises as the literal string `System.Collections.Hashtable` — the
service answers with a confusing error rather than a helpful one. Every payload
uses `| ConvertTo-Json -Depth 5`. `send-token-multi.ps1` is the worst case,
because `Parameters` is an array inside an array.

## Rule 2: the TLS line

The first line of every example is there for a reason:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

Older Windows builds still default to TLS 1.0 and the service refuses them. The
symptom is a connection error that looks like a firewall problem.

## Rule 3: `[ordered]@{}`, not `@{}`

A plain hashtable has no order, so the generated JSON comes out shuffled and no
longer lines up with the field order in the reference page. It still works, but
it makes every diff and every support conversation harder.

## Rule 4: `Success`, never the HTTP status

The service answers `200` to everything, including a wrong key, an empty account
and a malformed body.

```powershell
if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}
```

`ErrorCode` is only meaningful when `Success` is false. There is no `try`/`catch`
in these scripts: `Invoke-RestMethod` throws on a transport failure, which for a
scheduled task is the right shape. In a long-running script, catch it — and note
that a thrown timeout means the outcome is **unknown**, see Rule 7.

## Rule 5: running from Task Scheduler

Two things matter there, and both are easy to get wrong.

Put the key in a **machine-level** environment variable, not in the task and not
in the code:

```powershell
[Environment]::SetEnvironmentVariable('PAYAM_RESAN_API_KEY', '123456-XXX', 'Machine')
```

And set the execution policy for that one call rather than permanently:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\scripts\send-bulk.ps1
```

To reuse a script as a function, wrap its body in `function` and take the key as
a parameter.

## Rule 6: pick the right method

| The user wants | Use | File |
|---|---|---|
| one text to many people | `SendBulk` | `send-bulk.ps1` |
| a different text per person | `SendMultiple` | `send-multiple.ps1` |
| a one-time password or code | `SendTokenSingle` | `send-token-single.ps1` |
| a template to many people | `SendTokenMulti` | `send-token-multi.ps1` |
| delivery status | `StatusByUserTraceId` | `status-by-user-trace-id.ps1` |
| balance and sender lines | `AccountInfo` | `account-info.ps1` |

**A one-time password goes through a template**, not free text — that is the
usual route for OTP, and the template fixes the sender line, which is why
`SendTokenSingle` takes no `Sender`. `token-list.ps1` lists the account's
templates; `Status` `2` means approved and sendable, `1` awaiting review, `3`
rejected.

**Prefer `SendBulk` over `send.ps1`.** `Send` is a `GET`: the key ends up in the
URL and the web server log. Same for `send-token-single-get.ps1`.

## Rule 7: phone numbers, the 99 cap, and `UserTraceId`

The service wants `9121112222` or `989121112222`. Users type `09121112222` or
`+989121112222`. Normalise before sending, or you get error `13`. Ninety-nine
recipients per request is the ceiling for `SendBulk`, `SendMultiple` and
`SendTokenMulti`. Cast the sender: `[long]$env:PAYAM_RESAN_SENDER`.

Always send a `UserTraceId`. After a timeout or error `100`, resending blind may
send twice; `StatusByUserTraceId` is the only safe way to learn whether the
message was registered. `StatusCode -eq 8` there means the id is not in the
account, so it is safe to send again.

`SendTokenSingle` is the exception: it has no such input, so its `UserTraceId`
comes back null. If a trace id is needed for an OTP, use `SendTokenMulti` with a
single recipient.

`[uri]::EscapeDataString` encodes exactly once — encode beforehand as well and
the message arrives full of `%D8`.

## Rule 8: know which errors are worth retrying

These never succeed on retry — fix the cause; retrying only burns the rate limit
until the account hits error `20`:

`1`, `2`, `3`, `6`, `8`, `9`, `10`, `11`, `12`, `13`, `14`, `19`

`19` is an empty balance; `10` means the server's IP is not on the account's
allowlist. Treat any unknown code the way you treat `100`: unclear outcome,
check with `StatusByUserTraceId` before resending.

## Rule 9: delivery status is a poll, not a callback

Status codes `0`, `1`, `2`, `3` and `10` mean still in flight — query again
later, and not more often than every few minutes or you will hit error `20`. A
scheduled task every minute is the usual way people trip this. Everything else
is final. Branch on `StatusCode`, never on the `Status` text, which is Persian
prose meant for humans and can change.

## Rule 10: `GetInbox` consumes what it returns

The service hands over each incoming message **once**. A scheduled task that
fetches the inbox and then fails before writing the result has destroyed those
messages. Write them to a file or a database in the same run.

The sender field is called `Form`, not `From`. That is the service's spelling.

## Testing without spending credit

Replace `V3` with `V3SandBox` in the URL. No message is sent and no credit is
spent. `TokenList` is not implemented there.

The sandbox is a simulator, not a mirror of the account: credit is always
`1234567`, sender lines are invented, and **it accepts any key**. Success there
proves nothing about the user's real key.

## Where the authoritative answers are

- Method reference and error tables: <https://docs.payam-resan.com>
- Machine-readable OpenAPI: <https://github.com/Mojeshahr/sms-webservice-spec>

If the spec and these scripts ever disagree, the spec wins — report it as a bug
rather than guessing.
