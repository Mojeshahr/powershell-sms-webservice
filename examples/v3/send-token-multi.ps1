# SendTokenMulti - یک قالب، چند گیرنده، مقادیر متفاوت.
#
# پارامترها اینجا آرایه‌اند، نه p1 تا p10. درایه اول به {1} می‌نشیند، دومی به
# {2} و همین‌طور تا آخر: ترتیب از شماره جای‌گاه می‌آید، نه از جایی که در متن
# قالب دیده می‌شود.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\send-token-multi.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# قالب نمونه: «مرسوله شما از {2} تحویل پست شد. بارکد مرسوله پستی: {1}»
# پارامتر Depth اینجا از همه‌جا مهم‌تر است: Parameters یک آرایه داخل یک آرایه
# است و با عمق پیش‌فرض ویندوز پاورشل ۵.۱ بی‌صدا به رشته تبدیل می‌شود.
$payload = [ordered]@{
    ApiKey      = $env:PAYAM_RESAN_API_KEY
    TemplateKey = 'postcode'
    Recipients  = @(
        [ordered]@{
            Destination = 9121112222
            UserTraceId = 1001
            Parameters  = @('BARCODE-AAA', 'شیراز')
        },
        [ordered]@{
            Destination = 9121113333
            UserTraceId = 1002
            Parameters  = @('BARCODE-BBB', 'تبریز')
        }
    )
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://api.sms-webservice.com/api/V3/SendTokenMulti' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($message in $response.Result) {
    Write-Output "$($message.UserTraceId) => $($message.FinalText)"
}
# docs:end
