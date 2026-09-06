# Send - ساده‌ترین ارسال، یک متن به چند شماره با یک درخواست GET.
#
# برای آزمایش سریع خوب است. در محیط عملیاتی SendBulk را بردارید: کلید را از
# نشانی بیرون می‌برد و برای هر گیرنده شناسه پی‌گیری می‌پذیرد.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'; $env:PAYAM_RESAN_SENDER = '...'
#   .\examples\v3\send.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$text = 'کد تأیید شما ۱۲۳۴۵۶ است'

# متد EscapeDataString دقیقاً یک بار encode می‌کند. اگر متن را خودتان هم پیش
# از این encode کنید، پیامک با نویسه‌های %D8 به گوشی می‌رسد.
$query = 'ApiKey='       + [uri]::EscapeDataString($env:PAYAM_RESAN_API_KEY) +
         '&Sender='      + [uri]::EscapeDataString($env:PAYAM_RESAN_SENDER) +
         '&Text='        + [uri]::EscapeDataString($text) +
         '&Recipients='  + [uri]::EscapeDataString('9121112222,9121113333')

$response = Invoke-RestMethod `
    -Method Get `
    -Uri "https://api.sms-webservice.com/api/V3/Send?$query" `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($message in $response.Result) {
    Write-Output "شناسه $($message.Id)"
}
# docs:end
