# LYNKO Keyboard

Offline-first Android keyboard: English + Sinhala (Singlish → සිංහල), themes, swipe typing, emoji,
clipboard, stylish text, voice typing, translate and AI tools.

## Files (folders නැහැ)
settings.gradle · build.gradle · gradle.properties · AndroidManifest.xml · method.xml · file_paths.xml · lynko.keystore.b64 ·
LynkoIME.java · MainActivity.java · README.md · **logo.jpg** (ඔයාගේ image එක)

`logo.jpg` repo root එකට දැම්මාම app icon + "LYNKO" keyboard theme + app UI logo එකට auto use වෙනවා.
(≤ 512×512 නම් හොඳයි.) නැතිනම් default gradient logo එක පෙන්වනවා.

## v2.1
- **Romantic theme** (❤ Romantic chip in Home/Preview): wine-pink gradient + hearts float up from every key you press.
  Settings → Typing: "Hearts when you press keys" and "Hearts in every theme".
- Keys now fire when you lift your finger even if it slipped, the gap between keys is touchable, and fast two-finger typing no longer cancels keys.
- Big `logo.jpg` no longer crashes the app (it is shrunk when loaded). If anything still fails, the app shows the error on screen instead of closing.

## v2.2
- Sinhala keys: q = ඳ, z = ඤ now type too. Each key shows its Sinhala letter in සිං mode (long-press = direct letter).
- English word suggestions, auto-capital at sentence start, double space = full stop (Settings → Typing).
- **Updates**: every GitHub Action run publishes a Release (build-N). LYNKO app → Home → *Updates* checks it
  (also automatically on open) and offers *Download & install*. Repo must be public.
- Signing key: `lynko.keystore.b64` (repo root) is decoded by the workflow so every build has the same key,
  otherwise Android refuses to update. Keep it in the repo.

### iOS (ios/ folder)
Separate Swift app + keyboard extension (Romantic theme, hearts, English + Singlish→Sinhala).
`.github/workflows/ios.yml` builds an **unsigned .ipa** on a Mac runner and attaches it to a pre-release (`ios-N`).
Install it with AltStore / Sideloadly (free Apple ID, re-sign every 7 days). App Store / TestFlight needs a paid Apple Developer account.

## Build
GitHub Actions workflow එකෙන් (`.github/workflows/build.yml`) APK එක build වෙනවා,
නැත්නම් Android Studio වලින් Open කරලා Run.

## Notes
- Translate: Google Translate (unofficial endpoint, internet ඕන, නතර වෙන්න පුළුවන්).
- AI tools: ඔයාගේම Anthropic API key එක Settings වල දාන්න.
- Voice typing: phone එකේ speech service (Google) ඕන.
- Swipe typing: built-in English word list එකෙන් (LynkoIME.java → Engine.WORDS වලට words එකතු කරන්න පුළුවන්).
- "Compact" mode = narrow keyboard (left/right/center). Android වලට keyboard එකක් real floating window එකක් කරන්න බැහැ.
