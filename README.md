<div dir="rtl">

# 🤖 Backhaul Monitor BOT

<p align="center">
  <img src="https://img.shields.io/badge/Shell-Bash-green?style=for-the-badge&logo=gnubash"/>
  <img src="https://img.shields.io/badge/Platform-Linux-blue?style=for-the-badge&logo=linux"/>
  <img src="https://img.shields.io/badge/Telegram-Bot-blue?style=for-the-badge&logo=telegram"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge"/>
</p>

---

## 📌 معرفی

ابزاری هوشمند برای **مانیتورینگ تانل‌های Backhaul** از طریق تلگرام.  
بصورت خودکار تعداد تانل‌ها را پیدا کرده و با بررسی هوشمند **لاگ تانل** (نه پینگ سرورها) وضعیت اتصال را پایش می‌کند.

### ✨ ویژگی‌ها

- 🔍 **شناسایی خودکار** تمام تانل‌های Backhaul
- 📊 **پایش هوشمند مداوم** وضعیت تانل از روی آخرین لاگ
- 🟢🔴 **تشخیص وضعیت** از روی لاگ های تانل
- 🌐 **نمایش IP سرور** در گزارش
- 📤 **ارسال گزارش** به ربات تلگرام در بازه‌های زمانی دلخواه
- ⚙️ **منوی تعاملی** برای مدیریت آسان

---


## ⚡ نصب و اجرا - فقط روی سرور خارج

با **curl**:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sajjad-Alimadadi/backhaul-monitor/main/backhaul-monitor.sh)
```

> اگر `curl` ندارید، با **wget**:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/Sajjad-Alimadadi/backhaul-monitor/main/backhaul-monitor.sh)
```

---

## 📋 نحوه کار

```
 🟢  ──►  وضعیت: Active
 🔴  ──►  وضعیت: Inactive
```

---

## 📤 نمونه پیام تلگرام

```
🤖 Tunnel Monitor Report
━━━━━━━━━━━━━━━━━━━━
🌐 Server IP: 185.x.x.x
📅 Date: 2026/02/23
🕐 Time: 14:30:00
📊 Total Tunnels: 2
━━━━━━━━━━━━━━━━━━━━

🟢 Tunnel #1 — iran-1
📶 Status: Active
📝 Last Log:
[آخرین خط لاگ تانل]
─────────────────────

🔴 Tunnel #2 — iran-2
📶 Status: Inactive
📝 Last Log:
[آخرین خط لاگ تانل]
─────────────────────

✅ Report Complete
⏱ Next report in: 5 minutes
```

---

## ⚙️ منوی مدیریت

| گزینه | عملکرد |
|-------|--------|
| 1 | 🔑 ست کردن Bot Token |
| 2 | 👤 ست کردن Admin ID |
| 3 | ⏱ تنظیم بازه زمانی ارسال |
| 4 | 🔄 فعال/غیرفعال کردن مانیتور |
| 5 | 📤 ارسال گزارش تست |
| 6 | 🗑️ حذف کامل |
| 7 | 🚪 خروج |

---

## 👤 توسعه‌دهنده

**Sajjad Alimadadi**  
[![GitHub](https://img.shields.io/badge/GitHub-Sajjad--Alimadadi-black?style=flat&logo=github)](https://github.com/Sajjad-Alimadadi)

---

## 📜 لایسنس

این پروژه تحت لایسنس **MIT** منتشر شده است.

</div>
