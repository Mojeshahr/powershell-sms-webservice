# StatusById - وضعیت پیامک با شناسه‌هایی که متد ارسال برگردانده است.
#
# دسته‌ای بپرسید، نه یکی‌یکی. فاصله استعلام‌ها را هم کمتر از چند دقیقه
# نگذارید، وگرنه به خطای ۲۰ می‌خورید.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\status-by-id.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# شرط را روی StatusCode بگذارید، نه روی متن Status. این پنج کد یعنی هنوز در
# راه است و باید بعداً دوباره استعلام کنید، نه اینکه دوباره بفرستید.
$pending = @(0, 1, 2, 3, 10)

$payload = [ordered]@{
    ApiKey = $env:PAYAM_RESAN_API_KEY
    Ids    = @(9903211, 9903212)
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://www.payam-resan.com/api/V3/StatusById' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($message in $response.Result) {
    $again = if ($pending -contains $message.StatusCode) { ' (بعداً دوباره بپرسید)' } else { '' }
    Write-Output "$($message.Id): $($message.Status)$again"
}
# docs:end
