import SwiftUI

struct OnboardingView: View {
    var onDone: () -> Void
    @State private var page = 0
    private let pages: [(String, String, String)] = [
        ("books.vertical.fill", "Unlimited romance", "Werewolf, billionaire, fantasy and more — read every chapter."),
        ("xmark.seal.fill", "No coins. No ads.", "Never pay per chapter again. No coins, no ad-walls, ever."),
        ("heart.fill", "One fair price", "Finish any book for one price — start with a 7-day free trial.")
    ]
    var body: some View {
        VStack {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    VStack(spacing: 18) {
                        Spacer()
                        Image(systemName: pages[i].0).font(.system(size: 64)).foregroundStyle(Theme.accent)
                        Text(pages[i].1).font(.system(size: 30, weight: .bold, design: .serif))
                            .foregroundStyle(Theme.textPrimary).multilineTextAlignment(.center)
                        Text(pages[i].2).font(.body).foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center).padding(.horizontal, 36)
                        Spacer()
                    }.tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            Button(page < pages.count - 1 ? "Next" : "Start reading") {
                if page < pages.count - 1 { withAnimation { page += 1 } } else { onDone() }
            }
            .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
            .buttonStyle(.borderedProminent).controlSize(.large).tint(Theme.accent)
            .padding(.horizontal, 24).padding(.bottom, 16)
            .accessibilityIdentifier("onboardContinue")
        }
        .background(Theme.canvas.ignoresSafeArea())
    }
}
