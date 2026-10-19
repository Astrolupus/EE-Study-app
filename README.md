# EE Study Bench

Study app for first-year electrical engineering: Circuits, Calculus I, Physics, Digital logic and Programming.
Each subject has four steps (Prior knowledge, Theory, Practice, Review), and there is a timed exam builder
that mixes topics from any subject. Everything runs offline, and progress is saved on the device.

**Live web app:** https://astrolupus.github.io/EE-Study-app/

## Install on an iPhone (no Mac needed)

1. Open the live link above in **Safari** on the iPhone.
2. Tap **Share**, then **Add to Home Screen**, then **Add**.

It opens full screen from its own icon and keeps working without an internet connection after the first visit.

## Native iOS app (Xcode)

The `ios/` folder is a complete Xcode project (SwiftUI + WKWebView, no third-party libraries)
that bundles the same app.

1. On a Mac with Xcode 15 or newer, open `ios/EEStudyBench.xcodeproj`.
2. Select the **EEStudyBench** target > **Signing & Capabilities**, tick **Automatically manage signing**
   and pick your Apple ID as the **Team**.
3. Change the **Bundle Identifier** (`com.yourname.eestudybench`) to something unique.
4. Choose your iPhone or a simulator at the top of the window and press **Run** (Cmd+R).
5. First run on a real phone: **Settings > General > VPN & Device Management** > trust your Apple ID,
   and turn on **Settings > Privacy & Security > Developer Mode** if asked.

A free Apple ID runs the app on your own phone for 7 days at a time. TestFlight and the App Store need the
Apple Developer Program (US$99/year): choose **Any iOS Device**, then **Product > Archive > Distribute App**.

## Folder layout

| Path | What it is |
| --- | --- |
| `index.html` | The whole study app (pages, diagrams, question generators) |
| `fonts/`, `icons/` | Bundled fonts and app icons |
| `manifest.webmanifest`, `sw.js` | Home-screen install and offline support |
| `ios/` | Xcode project; `ios/EEStudyBench/www/` is a copy of the web app |

When `index.html` changes, copy it into `ios/EEStudyBench/www/` too so the iOS app gets the update.

## Licences

Fonts: Inter, JetBrains Mono and Barlow Condensed, under the SIL Open Font License (`fonts/OFL.txt`).
