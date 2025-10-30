# 🍲 Chopmates.com

> **Chopmates** is a peer-to-peer food sharing community helping Nigerians fight hunger through technology.  
> It connects people who have food to share with those who need it—safely, privately, and with dignity.  
> **Our mission:** *no one should go to bed hungry when someone nearby has more than enough.*

---

## Tech Stack (MVP)
- **Frontend/Host:** Hostinger Horizon (AI Website Builder)
- **Database & Auth:** Supabase (Postgres + RLS)
- **OTP:** AfricasTalking (sandbox → live later)
- **Images:** Cloudinary
- **Payments:** Paystack (test → live later)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Analytics:** Google Analytics 4

## MVP Features
- OTP sign-up (phone)
- Give / Request posts (auto-toggle, photo or text-only)
- Ambassador program + recognition
- Food drives with claim codes
- Push notifications (new posts, requests, matches, events)
- Offline SMS posting (GIVE:/NEED: via AfricasTalking webhook)
- Partners page (/partners) for CSR & sponsorship

## 🔧 Deployment & Backup (for Beginners)
1. Open **Hostinger** → **Websites** → **Edit with Horizon** (your Chopmates site).
2. After publishing, click the **⋯** menu → **Export code** to download a ZIP backup.
3. Come back to this GitHub repo → **Add file** → **Upload files** → drop the ZIP → **Commit**. Your latest site is backed up here.
4. To restore later: download the backed-up ZIP from GitHub → in Horizon, choose **Import website** (or new project) → upload the ZIP.

### Environment Variables
Create a `.env` from `.env.example` (locally) or provide keys to Horizon via your build prompt:
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
AFRICASTALKING_USERNAME=sandbox
AFRICASTALKING_API_KEY=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
PAYSTACK_PUBLIC_KEY=
PAYSTACK_SECRET_KEY=
GA_MEASUREMENT_ID=
FCM_SERVER_KEY=
FCM_CLIENT_EMAIL=
FCM_SENDER_ID=
FCM_VAPID_KEY=
```

### Webhooks to set up later
- `POST /api/sms/webhook` (AfricasTalking inbound)
- `POST /api/payments/webhook` (Paystack signature verify)
- `POST /api/notify` (server action → FCM)

## Contributing
Open issues for features like **Benefactor**, **Wallet**, **Area Champions**, translations, etc.
