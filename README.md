# GradeFlow

AI-powered essay feedback and interview practice built with Flutter + Firebase.

## What's inside

- UI: Material 3 with custom animations and Lottie
- State management: BLoC (flutter_bloc)
- AI services: Firebase AI (Vertex AI Gemini models)
- Features:
  - Essay/grammar feedback
  - AI-generated interview questions and feedback
  - Speech-to-text for answers
  - PDF export of interview feedback
- Navigation: Onboarding (first run only) + Root with bottom navigation (Essay, Interview)

## Updated architecture

- lib/blocs/
  - grammar/: GrammarBloc (submit essay -> feedback)
  - interview/: InterviewBloc (load questions, next, finish -> feedback)
- lib/services/
  - ai_service.dart: low-level AI calls
  - essay_repository.dart: wrapper for essay feedback
  - interview_repository.dart: wrapper for interview flows
- lib/screens/
  - onboarding_screen.dart: first-run welcome screen (Get Started)
  - root_screen.dart: bottom navigation (Essay, Interview)
  - home_page.dart: legacy landing (kept for reference)
  - essay_screen.dart: uses GrammarBloc, saves history locally
  - interview_screen.dart: uses InterviewBloc, saves history locally
- lib/services/
  - history_repository.dart: SharedPreferences storage for onboarding flag + per-feature history

## Run locally

1. Flutter and Firebase must be configured. Google services JSON/Plist are included.
2. Get packages.
3. Run the app. On first launch you'll see the onboarding screen; tap Get Started.

Routes:

- Entry: Onboarding → Root (bottom nav)
- Routes: '/onboarding', '/root', '/essay', '/interview' (for deep links)

## Notes

- The old screens (`essay_page.dart`, `interview_page.dart`) remain in the repo for reference but routes now point to the new bloc-based screens.
- You can fine-tune prompts or swap models in `lib/services/ai_service.dart`.
