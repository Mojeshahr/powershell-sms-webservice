# SendBulk - یک متن به چند گیرنده، هر کدام با شناسه پی‌گیری خودتان.
#
# روش پیشنهادی برای ارسال عملیاتی. کلید در بدنه درخواست می‌رود نه در نشانی،
# و برای هر گیرنده UserTraceId می‌پذیرد تا گزارش تحویل را بدون نگه‌داشتن Id
# سامانه بگیرید.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'; $env:PAYAM_RESAN_SENDER = '...'
#   .\examples\v3\send-bulk.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# پارامتر Depth را حذف نکنید. ConvertTo-Json در ویندوز پاورشل ۵.۱ به‌صورت
# پیش‌فرض فقط دو لایه را باز می‌کند و Recipients بی‌صدا به رشته تبدیل می‌شود.
$payload = [ordered]@{
    ApiKey     = $env:PAYAM_RESAN_API_KEY
    Sender     = [long]$env:PAYAM_RESAN_SENDER
    Text       = 'سفارش شما ثبت شد.'
    Recipients = @(
        [ordered]@{ Destination = 9121112222; UserTraceId = 1001 },
        [ordered]@{ Destination = 9121113333; UserTraceId = 1002 }
    )
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://api.sms-webservice.com/api/V3/SendBulk' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($message in $response.Result) {
    Write-Output "$($message.UserTraceId) => شناسه $($message.Id)"
}
# docs:end
