# SendTokenSingle با GET - همان ارسال قالب، با ورودی در نشانی.
#
# برای آزمایش دستی مناسب است، برای محیط عملیاتی نه: در GET هم کلید حساب و هم
# مقدار رمز یک‌بارمصرف داخل نشانی می‌نشینند و در لاگ وب‌سرور و هدر Referer
# ثبت می‌شوند. واریانت POST را بردارید.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\send-token-single-get.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$query = 'ApiKey='       + [uri]::EscapeDataString($env:PAYAM_RESAN_API_KEY) +
         '&TemplateKey=' + [uri]::EscapeDataString('verifycode') +
         '&Destination=' + [uri]::EscapeDataString('9121112222') +
         '&p1='          + [uri]::EscapeDataString('123456')

$response = Invoke-RestMethod `
    -Method Get `
    -Uri "https://www.payam-resan.com/api/V3/SendTokenSingle?$query" `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($message in $response.Result) {
    Write-Output "شناسه $($message.Id)، متن نهایی: $($message.FinalText)"
}
# docs:end
