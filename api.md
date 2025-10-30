# API Notes (MVP)

## OTP
- `POST /api/otp/send { phone }`
- `POST /api/otp/verify { phone, code }` → sets `users.verified=true`

## Posts
- `POST /api/posts` create { type: give|need, title, quantity, photo_url?, state, city, town, village, expiry? }
- `PATCH /api/posts/:id` fulfill/expire

## Matches
- `POST /api/matches` on Claim: creates pending match linking giver/receiver/post
- `PATCH /api/matches/:id` confirm from each party; auto-close after 24h if giver-only

## Events
- `GET /api/events`
- `POST /api/events/:id/claim` → issues code like `CHOP-8X3P`

## Payments
- `POST /api/payments/initiate` → Paystack checkout init
- `POST /api/payments/webhook` → verify signature, write `payments` row

## Notifications
- `POST /api/notify { area, title, body }` → send FCM push

## SMS Webhook
- `POST /api/sms/webhook` from AfricasTalking
  - Body starts with `GIVE:` or `NEED:` → create corresponding post for that phone
