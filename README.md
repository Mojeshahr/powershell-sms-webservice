<div align="center">

<a href="https://payam-resan.com">
  <img src=".github/assets/logo.svg" width="64" height="64" alt="پیام رسان">
</a>

<h1>نمونه‌کدهای PowerShell وب‌سرویس پیام رسان</h1>

اتصال به وب‌سرویس <a href="https://payam-resan.com"><b>پنل پیامکی پیام رسان</b></a> با PowerShell<br>
یک فایل قابل اجرا به‌ازای هر متد سرویس، بدون هیچ وابستگی

[![API](https://img.shields.io/badge/API-V3-0a7cbd)](https://payam-resan.com)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391fe)](https://learn.microsoft.com/powershell)
[![Dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)](#شروع-سریع)
[![License](https://img.shields.io/badge/license-MIT-6e7781)](LICENSE)

<b>فارسی</b> · <a href="README.en.md">English</a>

</div>

<sub>دنبال زبان دیگری هستید؟ همین نمونه‌ها برای زبان‌های دیگر هم در
[github.com/Mojeshahr](https://github.com/Mojeshahr) هست.</sub>

---

## شروع سریع

```powershell
git clone https://github.com/Mojeshahr/powershell-sms-webservice.git
cd powershell-sms-webservice

$env:PAYAM_RESAN_API_KEY = '123456-XXXXXXXXXXXXXXX'
$env:PAYAM_RESAN_SENDER  = '30004040'

.\examples\v3\account-info.ps1
```

نه ماژولی از گالری لازم است و نه چیز دیگری. همه‌چیز با `Invoke-RestMethod` که
در خود پاورشل هست انجام می‌شود.

با `account-info.ps1` شروع کنید: چیزی ارسال نمی‌کند، اعتباری مصرف نمی‌کند، و
اگر جواب داد یعنی کلید و اتصال هر دو سالم‌اند.

## ویندوز پاورشل ۵.۱ یا پاورشل ۷

هر دو. ولی سه چیز در نمونه‌ها هست که فقط به‌خاطر ۵.۱ آنجاست، و اگر برشان
دارید روی ۷ همچنان کار می‌کند و روی ۵.۱ خراب می‌شود:

**فایل‌ها با BOM ذخیره شده‌اند.** ویندوز پاورشل ۵.۱ فایل بدون BOM را با
کدپیج ANSI سیستم می‌خواند، پس متن فارسی داخل اسکریپت خراب می‌شود و گاهی اصلاً
پارس نمی‌شود. پاورشل ۷ فرض را بر UTF-8 می‌گذارد و اهمیتی نمی‌دهد؛ همین باعث
می‌شود این ایراد به‌راحتی و بی‌سروصدا وارد شود. اسکریپت `check-encoding.sh`
نگهبانش است.

**بدنه به‌صورت بایت فرستاده می‌شود، نه رشته.** در ۵.۱ اگر رشته بدهید،
`Invoke-RestMethod` آن را با کدپیج پیش‌فرض می‌فرستد و پیامک فارسی به‌شکل
علامت سؤال به گوشی می‌رسد:

```powershell
-Body ([System.Text.Encoding]::UTF8.GetBytes($payload))
```

**پارامتر `-Depth` روی `ConvertTo-Json` حذف نشود.** عمق پیش‌فرض در ۵.۱ برابر
۲ است، پس `Recipients` بی‌صدا به رشته‌ای مثل
`System.Collections.Hashtable` تبدیل می‌شود و سرویس خطای نامفهوم می‌دهد.

خط `Tls12` هم برای ویندوزهای قدیمی‌تر است که هنوز TLS 1.0 را پیش‌فرض
می‌گیرند و اتصال به سرویس را رد می‌کنند.

## پیش از ارسال واقعی

یک سرور آزمایشی هست که مثل سرور عملیاتی جواب می‌دهد ولی پیامکی نمی‌فرستد و
اعتباری مصرف نمی‌کند. کافی است `V3` در نشانی را با `V3SandBox` عوض کنید. تنها
استثنا `TokenList` است که روی آن سرور پیاده نشده.

## متدها

<div dir="rtl">

| نمونه | متد | کار |
|---|---|---|
| [account-info.ps1](examples/v3/account-info.ps1) | `AccountInfo` | اعتبار و خطوط فعال |
| [send.ps1](examples/v3/send.ps1) | `Send` | ارسال ساده با `GET` |
| [send-bulk.ps1](examples/v3/send-bulk.ps1) | `SendBulk` | یک متن به چند گیرنده، با شناسه پی‌گیری |
| [send-multiple.ps1](examples/v3/send-multiple.ps1) | `SendMultiple` | متن جدا برای هر گیرنده |
| [token-list.ps1](examples/v3/token-list.ps1) | `TokenList` | فهرست قالب‌ها |
| [send-token-single.ps1](examples/v3/send-token-single.ps1) | `SendTokenSingle` | ارسال قالب به یک شماره |
| [send-token-single-get.ps1](examples/v3/send-token-single-get.ps1) | `SendTokenSingle` | همان، با `GET` |
| [send-token-single-concat-param.ps1](examples/v3/send-token-single-concat-param.ps1) | `SendTokenSingleConcatParam` | مقادیر قالب در رشته `p` با جداکننده نقطه‌ویرگول |
| [send-token-single-concat-param-get.ps1](examples/v3/send-token-single-concat-param-get.ps1) | `SendTokenSingleConcatParam` | همان، با `GET` |
| [send-token-multi.ps1](examples/v3/send-token-multi.ps1) | `SendTokenMulti` | یک قالب، چند گیرنده |
| [status-by-id.ps1](examples/v3/status-by-id.ps1) | `StatusById` | وضعیت با شناسه سامانه |
| [status-by-user-trace-id.ps1](examples/v3/status-by-user-trace-id.ps1) | `StatusByUserTraceId` | وضعیت با شناسه خودتان |
| [get-inbox.ps1](examples/v3/get-inbox.ps1) | `GetInbox` | پیامک‌های رسیده |

</div>

## اجرا از Task Scheduler

مخاطب اصلی این مخزن ادمین ویندوز سرور است، و آنجا اسکریپت معمولاً از
زمان‌بند اجرا می‌شود نه از کنسول. دو نکته:

کلید را در متغیر محیطی **سطح ماشین** بگذارید، نه در خود تسک و نه در کد:

```powershell
[Environment]::SetEnvironmentVariable('PAYAM_RESAN_API_KEY', '123456-XXX', 'Machine')
```

و سیاست اجرا را برای همان فراخوانی بدهید، نه به‌صورت دائمی روی سیستم:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\scripts\send-bulk.ps1
```

## استفاده در پروژه خودتان

نمونه‌ها عمداً به هیچ چیز این مخزن وابسته نیستند، پس کپی‌کردن فایل داخل
اسکریپت شما کافی است. اگر چند متد را کنار هم لازم دارید، بدنه هر فایل را داخل
یک `function` بگذارید و کلید را پارامتر بگیرید.

## چند نکته که وقت‌تان را می‌خرد

**کد وضعیت HTTP را نخوانید.** سرویس همیشه `200` برمی‌گرداند، حتی وقتی کلید
اشتباه است، پس نبودِ استثنا چیزی ثابت نمی‌کند. تصمیم را از فیلد `Success`
بگیرید. هر نمونه اینجا همین کار را می‌کند.

**شماره گیرنده صفر ابتدایی ندارد.** یعنی `9121112222` یا با کد کشور
`989121112222`. شماره‌ای که با `9` یا `989` شروع نشود کد خطای `13` می‌گیرد.

**متن را دوباره encode نکنید.** در `send.ps1` متد `EscapeDataString` خودش یک
بار این کار را می‌کند. اگر پیش از آن هم encode کنید، پیامک با نویسه‌های `%D8`
به گوشی می‌رسد.

**برای هر گیرنده یک `UserTraceId` یکتا بفرستید.** بعد از یک timeout، این تنها
راه فهمیدن این است که پیامک ثبت شده یا نه.

## امنیت کلید

کلید یک راز است. در مخزن کد، در جاوااسکریپت مرورگر و در بسته اپلیکیشن موبایل
نباید قرار بگیرد. جای آن متغیر محیطی است، همان‌طور که همه نمونه‌ها می‌خوانندش.

اگر کلیدی لو رفت، از پنل یکی تازه بسازید. کلید حذف‌شده برنمی‌گردد.

## ساختار

<div dir="rtl">

| مسیر | چه چیزی دارد |
|---|---|
| `examples/v3/` | یک نمونه مستقل به‌ازای هر عملیات سرویس |
| `check-encoding.sh` | بررسی اینکه هر فایل BOM دارد |
| `.env.example` | نمونه متغیرهای محیطی |

</div>

عدد `v3` در مسیر عمدی است. نسخه تازه سرویس یعنی پوشه `examples/v<n>/` تازه، و
پوشه موجود دست‌نخورده می‌ماند.

## مستندات و پشتیبانی

راهنمای کامل وب‌سرویس در [docs.payam-resan.com](https://docs.payam-resan.com)
است. توصیف ماشین‌خوان OpenAPI هم در
[sms-webservice-spec](https://github.com/Mojeshahr/sms-webservice-spec).

سؤال یا خطایی هست؟ [issue باز کنید](https://github.com/Mojeshahr/powershell-sms-webservice/issues)
یا با [پشتیبانی](https://payam-resan.com) تماس بگیرید.

## مجوز

منتشرشده با مجوز MIT. متن کامل در [`LICENSE`](LICENSE).

<br>
<div align="center">
  <sub>
    <img src=".github/assets/logo.svg" width="16" height="16" alt="" align="top">
    &nbsp;<b>پنل پیامکی پیام رسان - موج شهر</b>&nbsp;
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset=".github/assets/mojeshahr-dark.svg">
      <img src=".github/assets/mojeshahr-light.svg" width="16" height="16" alt="" align="top">
    </picture>
  </sub>
  <br>
  <sub>
    <a href="https://payam-resan.com">payam-resan.com</a>
    &nbsp;·&nbsp;
    <a href="https://mojeshahr.ir">mojeshahr.ir</a>
  </sub>
</div>
