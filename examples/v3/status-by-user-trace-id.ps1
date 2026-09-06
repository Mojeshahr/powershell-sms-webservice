# StatusByUserTraceId - وضعیت پیامک با شناسه‌هایی که خودتان داده‌اید.
#
# اگر UserTraceId را کلید رکورد پایگاه داده خودتان بگذارید، دیگر لازم نیست Id
# سامانه را ذخیره کنید. این متد راه امن تشخیص ارسال تکراری هم هست: بعد از قطع
# ارتباط، اول اینجا بپرسید ثبت شده یا نه.
#
# جز خود پاورشل به چیزی وابسته نیست. روی ویندوز پاورشل ۵.۱ و پاورشل ۷ هر دو
# کار می‌کند. این فایل با BOM ذخیره شده، وگرنه ۵.۱ متن فارسی را خراب می‌خواند.
#
#   $env:PAYAM_RESAN_API_KEY = '...'
#   .\examples\v3\status-by-user-trace-id.ps1

# docs:start
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$payload = [ordered]@{
    ApiKey       = $env:PAYAM_RESAN_API_KEY
    UserTraceIds = @(1001, 1002)
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod `
    -Method Post `
    -Uri 'https://api.sms-webservice.com/api/V3/StatusByUserTraceId' `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
    -TimeoutSec 30

if (-not $response.Success) {
    Write-Error "ناموفق. کد $($response.ErrorCode): $($response.Error)"
    exit 1
}

foreach ($message in $response.Result) {
    # کد ۸ یعنی این شناسه در حساب شما نیست. بعد از یک timeout، همین یعنی
    # ارسال ثبت نشده و می‌توانید با خیال راحت دوباره بفرستید.
    if ($message.StatusCode -eq 8) {
        Write-Output "$($message.UserTraceId): ثبت نشده"
        continue
    }

    Write-Output "$($message.UserTraceId): $($message.Status)"
}
# docs:end
