# AccountInfo - اعتبار باقی‌مانده و خطوط فعال حساب.
#
# سبک‌ترین متد سرویس و بهترین راه آزمودن کلید: چیزی ارسال نمی‌کند، اعتباری
# مصرف نمی‌کند، و حتی با اعتبار صفر هم جواب می‌دهد.
#
# جز خود پاورشل به چیزی وابسته نیست، نه ماژولی از گالری و نه چیز دیگر.
# روی ویندوز پاورشل ۵.۱ و روی پاورشل ۷ هر دو کار می‌کند.
#
# این فایل با BOM ذخیره شده است. بدون BOM، ویندوز پاورشل ۵.۱ آن را ANSI
# می‌خواند و متن فارسی داخلش خراب می‌شود.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\account-info.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$payload = [ordered]@{ ApiKey = $env:PAYAM_RESAN_API_KEY } | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://www.payam-resan.com/api/V3/AccountInfo' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

Write-Output "اعتبار: $($response.Result.Credit)"

foreach ($line in $response.Result.AvailableSenders) {
    Write-Output "خط: $line"
}
# docs:end
