# SendMultiple - متن و خط فرستنده جدا برای هر گیرنده.
#
# برای پیام‌های شخصی‌سازی‌شده که با یک قالب ثابت پوشش داده نمی‌شوند. برخلاف
# SendBulk، اینجا Text و Sender در سطح هر گیرنده تعریف می‌شوند.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'; $env:PAYAM_RESAN_SENDER = '...'
#   .\examples\v3\send-multiple.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$sender = [long]$env:PAYAM_RESAN_SENDER

# پارامتر Depth را حذف نکنید. ConvertTo-Json در ویندوز پاورشل ۵.۱ به‌صورت
# پیش‌فرض فقط دو لایه را باز می‌کند و Recipients بی‌صدا به رشته تبدیل می‌شود.
$payload = [ordered]@{
    ApiKey     = $env:PAYAM_RESAN_API_KEY
    Recipients = @(
        [ordered]@{
            Sender      = $sender
            Destination = 9121112222
            Text        = 'آقای محمدی، سفارش شما ارسال شد.'
            UserTraceId = 1001
        },
        [ordered]@{
            Sender      = $sender
            Destination = 9121113333
            Text        = 'خانم رضایی، سفارش شما ارسال شد.'
            UserTraceId = 1002
        }
    )
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://www.payam-resan.com/api/V3/SendMultiple' `
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
