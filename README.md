# talrun

TalRun app (Flutter + Firebase) for trainees and coaches.

## Firebase setup (Firestore + rules)

This repo now includes:
- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`
- `backend-docs/backend-blueprint.md`

### Deploy Firestore rules/indexes

1. Install Firebase CLI (once):
   - `npm i -g firebase-tools`
2. Login:
   - `firebase login`
3. Select your project:
   - `firebase use --add`
4. Deploy:
   - `firebase deploy --only firestore:rules,firestore:indexes`

## Coach dashboard recommendation

Use a separate Next.js app on Vercel with Firebase Auth (Google) and role checks (`users.role == "coach"`).
See `backend-docs/backend-blueprint.md` for data model and relationship lifecycle (coach-trainee linking, weekly unlock, ended relationships).
