# TokenList - قالب‌های حساب، با کلید و متن و وضعیت تأییدشان.
#
# برای پیدا کردن TemplateKey که متدهای ارسال قالب لازم دارند. این متد هم مثل
# AccountInfo از بررسی اعتبار معاف است.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\token-list.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$payload = [ordered]@{ ApiKey = $env:PAYAM_RESAN_API_KEY } | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://api.sms-webservice.com/api/V3/TokenList' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($template in $response.Result) {
    $sendable = if ($template.Status -eq 2) { 'قابل ارسال' } else { 'قابل ارسال نیست' }
    Write-Output "$($template.Key) ($sendable): $($template.TextTemplate)"
}
# docs:end
