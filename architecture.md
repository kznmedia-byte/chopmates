# Chopmates Architecture

**Frontend/Host:** Hostinger Horizon (AI Website Builder)  
**Backend:** Supabase (Postgres + RLS)  
**OTP:** AfricasTalking  
**Images:** Cloudinary  
**Payments:** Paystack  
**Push:** Firebase Cloud Messaging (FCM)  
**Analytics:** GA4

## High-level Flow
1. User signs up with phone → OTP via AfricasTalking.
2. Profile stores name, screen_name, age, address, state/city/town/village.
3. User posts **Give** or **Need** → stored in Supabase.
4. Triggers create `notifications` rows → backend sends FCM push.
5. Receiver clicks **Claim** → match created. Both confirm to close; 24h giver-only fallback + dispute path.
6. Events/Drives publish → users claim unique codes.
7. Partners pay via Paystack → webhook logs `payments` for reporting.
