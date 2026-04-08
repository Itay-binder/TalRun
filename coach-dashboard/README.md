# TalRun Coach Dashboard

Next.js app intended for coaches (host on Vercel).

## Local run

1. Copy `.env.example` to `.env.local`
2. Fill Firebase Web config values
3. Install and run:
   - `npm install`
   - `npm run dev`

## Vercel env vars

Set these in Vercel Project Settings -> Environment Variables:

- `NEXT_PUBLIC_FIREBASE_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET`
- `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID`
- `NEXT_PUBLIC_FIREBASE_APP_ID`

## Current scope

- Google sign-in
- Basic role gate (`coach` only)
- Placeholder trainees dashboard

Next steps are listed in `../backend-docs/backend-blueprint.md`.

## Coach whitelist doc format

Collection: `coach_whitelist`

You can approve coaches by:
- document id = coach UID (recommended), or
- any id + `emailLower`

Fields (supported):
- `emailLower` (string, lowercase email)
- `active` (boolean, default `true` if missing)
- `displayName` (optional, used on first user creation)
- `notes` (optional, shown after login)
This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
