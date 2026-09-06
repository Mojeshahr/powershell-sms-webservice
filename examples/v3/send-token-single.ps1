# SendTokenSingle - ارسال قالب به یک شماره، با بدنه JSON.
#
# مسیر معمول رمز یک‌بارمصرف. خط فرستنده ورودی ندارد؛ سامانه آن را از روی خود
# قالب برمی‌دارد. همین واریانت POST را به کار ببرید، نه GET: در GET هم کلید
# حساب و هم خود رمز داخل نشانی و لاگ وب‌سرور می‌نشینند.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\send-token-single.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$payload = [ordered]@{
    ApiKey      = $env:PAYAM_RESAN_API_KEY
    TemplateKey = 'verifycode'
    Destination = 9121112222
    p1          = '123456'
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://api.sms-webservice.com/api/V3/SendTokenSingle' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

# این متد UserTraceId در ورودی ندارد، پس در پاسخ null برمی‌گردد. اگر شناسه
# پی‌گیری لازم دارید، SendTokenMulti را حتی برای یک گیرنده هم می‌شود به کار برد.
foreach ($message in $response.Result) {
    Write-Output "شناسه $($message.Id) از خط $($message.Sender)"
    Write-Output "متن نهایی: $($message.FinalText)"
}
# docs:end
