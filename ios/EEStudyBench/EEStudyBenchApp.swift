import SwiftUI

/// EE Study Bench: a native shell around the offline study site bundled in `www/`.
@main
struct EEStudyBenchApp: App {
    var body: some Scene {
        WindowGroup {
            StudyWebView()
                .ignoresSafeArea()
                .background(Color("LaunchBackground").ignoresSafeArea())
        }
    }
}
