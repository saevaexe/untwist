import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: "disclaimer_body", defaultValue: """
                Untwist is a self-help wellness tool based on Cognitive Behavioral Therapy (CBT) principles.

                This app is NOT a substitute for professional therapy, counseling, or medical advice. It does not diagnose, treat, or cure any mental health condition.

                If you are experiencing a mental health crisis, please contact a licensed mental health professional or call your local emergency services immediately.

                Emergency contacts:
                • 988 Suicide & Crisis Lifeline (US)
                • 182 İntihar Önleme Hattı (TR)

                All data you enter stays on your device. We do not collect, store, or share any personal information.
                """))
                .font(.body)
                .foregroundStyle(Color.textPrimary)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle(String(localized: "disclaimer_title", defaultValue: "Disclaimer"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DisclaimerView()
    }
}
