# GetInbox - پیامک‌هایی که کاربران به خطوط حساب شما فرستاده‌اند.
#
# این یک استعلام است، نه webhook: سامانه چیزی به سرور شما نمی‌فرستد و باید
# خودتان دوره‌ای صدایش بزنید. فاصله را کمتر از چند دقیقه نگذارید، وگرنه به
# خطای ۲۰ می‌خورید.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\get-inbox.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$payload = [ordered]@{ ApiKey = $env:PAYAM_RESAN_API_KEY } | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://www.payam-resan.com/api/V3/GetInbox' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($sms in $response.Result) {
    # نام فیلد فرستنده در خود سرویس Form است، نه From. دنبال From نگردید.
    Write-Output "$($sms.Time)  $($sms.Form) -> $($sms.To): $($sms.Text)"
}
# docs:end
