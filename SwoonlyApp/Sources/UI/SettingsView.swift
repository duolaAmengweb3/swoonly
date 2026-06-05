import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var entitlement: EntitlementStore
    @Query private var settingsList: [AppSettings]
    @Environment(\.modelContext) private var ctx
    @State private var showPaywall = false
    private var settings: AppSettings { settingsList.first ?? AppSettings() }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if entitlement.isPro {
                        Label("Swoonly Pro — active", systemImage: "checkmark.seal.fill").foregroundStyle(Theme.success)
                        Button("Manage subscription") { openManage() }
                    } else {
                        Button { showPaywall = true } label: {
                            HStack { Label("Go unlimited", systemImage: "heart.fill"); Spacer()
                                Text("\(entitlement.monthlyPrice)/mo").foregroundStyle(Theme.textSecondary) }
                        }.tint(Theme.accent)
                    }
                    Button("Restore purchases") { Task { try? await entitlement.restore() } }
                }
                Section("Reading") {
                    HStack { Text("Text size"); Spacer()
                        Stepper(value: Binding(get: { settings.readerFontSize }, set: { settings.readerFontSize = $0 }),
                                in: 14...26, step: 1) { Text("\(Int(settings.readerFontSize))").monospacedDigit() } }
                    Toggle("Serif font", isOn: Binding(get: { settings.serifReading }, set: { settings.serifReading = $0 }))
                    Picker("Reader theme", selection: Binding(get: { settings.readerTheme },
                        set: { settings.readerThemeRaw = $0.rawValue })) {
                        ForEach(ReaderTheme.allCases) { Text($0.label).tag($0) }
                    }
                }
                Section("Notifications") {
                    Toggle("Daily reading reminder", isOn: Binding(get: { settings.dailyReminder }, set: { v in
                        settings.dailyReminder = v
                        if v { NotificationService.enableDailyReminder() } else { NotificationService.disable() }
                    }))
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://duolaamengweb3.github.io/swoonly/privacy.html")!)
                    Link("Support", destination: URL(string: "https://duolaamengweb3.github.io/swoonly/support.html")!)
                    HStack { Text("Version"); Spacer(); Text("1.0").foregroundStyle(Theme.textSecondary) }
                }
                Section {
                    Text("Stories on Swoonly are works of fiction created with AI, for entertainment. Any resemblance to real people is coincidental.")
                        .font(.caption).foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private func openManage() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") { UIApplication.shared.open(url) }
    }
}
