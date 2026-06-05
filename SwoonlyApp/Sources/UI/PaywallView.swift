import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var entitlement: EntitlementStore
    @Environment(\.dismiss) private var dismiss
    @State private var yearly = true
    @State private var buying = false

    // Every perk maps to a real shipped behavior — no coins exist in the app, no ads exist, all chapters unlock.
    private let perks: [(String, String)] = [
        ("infinity", "Every chapter, unlimited"),
        ("xmark.seal.fill", "No coins — ever"),
        ("hand.thumbsup.fill", "Zero ads"),
        ("textformat", "Cozy reader — themes, fonts & sizes"),
        ("books.vertical.fill", "All genres included"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ZStack {
                    Circle().fill(Theme.accentSoft).frame(width: 84, height: 84)
                    Image(systemName: "heart.fill").font(.system(size: 42)).foregroundStyle(Theme.accent)
                }.padding(.top, 28)
                Text("Swoonly Pro").font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(Theme.textPrimary)
                Text("Unlimited. No coins. No ads.\nFinish any book for one price.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(perks, id: \.0) { p in
                        HStack(spacing: 14) {
                            Image(systemName: p.0).font(.title3).foregroundStyle(Theme.accent).frame(width: 28)
                            Text(p.1).font(.subheadline.weight(.medium)).foregroundStyle(Theme.textPrimary)
                            Spacer()
                        }
                    }
                }.card(20)

                planRow(isYearly: true, title: "Yearly", price: entitlement.yearlyPrice, sub: "Best value · 7-day free trial")
                planRow(isYearly: false, title: "Monthly", price: entitlement.monthlyPrice, sub: "7-day free trial")

                Button {
                    Task {
                        buying = true
                        if let p = yearly ? entitlement.yearly : entitlement.monthly { _ = try? await entitlement.purchase(p) }
                        buying = false
                        if entitlement.isPro { dismiss() }
                    }
                } label: {
                    Text(buying ? "…" : "Start 7-day free trial").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent).controlSize(.large).tint(Theme.accent)
                .accessibilityIdentifier("purchasePro")

                Button("Restore purchases") { Task { try? await entitlement.restore(); if entitlement.isPro { dismiss() } } }
                    .font(.footnote).tint(Theme.textSecondary)
                Text("The first chapters of every book are always free. Cancel anytime. Subscription auto-renews unless cancelled 24h before the period ends.")
                    .font(.caption2).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center).padding(.horizontal, 8)
            }.padding(20)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: { Image(systemName: "xmark.circle.fill") }.tint(Theme.textSecondary).padding()
        }
    }

    private func planRow(isYearly: Bool, title: String, price: String, sub: String) -> some View {
        let selected = yearly == isYearly
        return Button { yearly = isYearly } label: {
            HStack {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle").foregroundStyle(Theme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
                    Text(sub).font(.caption).foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text(price).font(.headline.monospacedDigit()).foregroundStyle(Theme.textPrimary)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(selected ? Theme.accent : Theme.hairline, lineWidth: selected ? 1.6 : 0.8))
        }.buttonStyle(.plain)
    }
}
