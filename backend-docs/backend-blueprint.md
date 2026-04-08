# Backend Blueprint (Coach/Trainee)

## Core goals
- Coach logs in with Google and manages own trainees.
- Trainee sees only unlocked weeks.
- Coach can pre-build full plan and unlock weekly.
- Trainee can keep app access even after coach relationship ends.

## Data model (Firestore)

### `users/{uid}`
- `role`: `coach | trainee`
- `displayName`, `photoUrl`, `email`
- `activePlanId` (nullable)
- `coachStatus`: `none | active | ended`
- `currentCoachId` (nullable)
- `createdAt`, `updatedAt`

### `coach_trainees/{coachId_traineeId}`
- `coachId`, `traineeId`
- `status`: `active | ended`
- `startedAt`, `endedAt`
- `createdAt`, `updatedAt`

> Ended link keeps history and allows trainee to continue as independent.

### `plans/{planId}`
- `coachId`, `traineeId`
- `title`, `goal`, `weeksTotal`
- `status`: `draft | active | paused | completed | archived`
- `startDate`, `endDate` (nullable)
- `currentOpenWeek` (e.g. 3)
- `createdAt`, `updatedAt`

### `plans/{planId}/weeks/{weekId}`
- `weekIndex` (1..N)
- `isOpen` (boolean)
- `startAt`, `endAt`
- `notes`

### `plans/{planId}/weeks/{weekId}/workouts/{workoutId}`
- `title`, `kind`, `dayIndex`
- `targetDistanceKm`, `targetDurationMin`, `targetPace`
- `status`: `planned | completed | skipped`
- `activityId` (nullable)
- `completedAt` (nullable)
- `coachNotes`, `traineeNotes`
- `createdAt`, `updatedAt`

### `activities/{activityId}`
- `userId`
- `workoutId` (nullable)
- `source`: `manual | gps | strava | garmin | apple_health`
- `startedAt`, `endedAt`, `durationSec`
- `distanceM`, `avgPaceSecPerKm`, `avgHr`, `calories`
- `polyline` (optional compressed route)
- `createdAt`, `updatedAt`

## Relationship lifecycle

1. Coach sends invite code/link.
2. Trainee accepts invite.
3. Backend creates/activates `coach_trainees/{coachId_traineeId}` with `active`.
4. Coach can assign/create plans only for active links.
5. If trainee leaves coach:
   - set link `status=ended`, `endedAt=...`
   - trainee keeps `users` + `activities` and app access.
   - plans remain read-only history unless copied to independent plan.

## Weekly unlock behavior
- Coach can build all weeks in advance.
- Trainee UI displays only weeks where `isOpen=true`.
- Coach unlock action:
  - set `weeks/{weekId}.isOpen = true`
  - optionally update `plans/{planId}.currentOpenWeek`

## Dashboard scope (Vercel web app)

### Auth
- Firebase Auth (Google provider)
- role guard: only `users.role == coach`

### Coach dashboard pages
- trainees list
- trainee profile + recent activities
- plan builder (create/edit weeks/workouts)
- unlock week action
- performance dashboard (weekly km, PR trend, completion rate)

## Recommended stack for web dashboard
- Next.js (App Router) on Vercel
- Firebase JS SDK for client reads
- Cloud Functions (or Next API routes + Admin SDK) for privileged writes

## Why Functions/Admin for sensitive writes
Use server-side endpoint for:
- creating coach-trainee links
- assigning plans
- ending relationship
- unlock week actions

This prevents spoofed client writes.

## Immediate next implementation steps
1. Deploy `firestore.rules` and `firestore.indexes.json`.
2. Add `users.role` + `coach_trainees` flow (invite/accept).
3. Replace demo plan source with Firestore repository.
4. Build minimal coach web dashboard on Vercel:
   - login
   - trainees table
   - create/edit plan
   - unlock week button
5. Add GPS session in app and save activity -> link to workout.
