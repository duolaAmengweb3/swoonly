import WidgetKit
import SwiftUI

private let rose = Color(red: 0.831, green: 0.345, blue: 0.443)

struct SwoonlyEntry: TimelineEntry { let date: Date; let snap: SwoonlySnapshot }

struct SwoonlyProvider: TimelineProvider {
    func placeholder(in c: Context) -> SwoonlyEntry { SwoonlyEntry(date: .now, snap: .placeholder) }
    func getSnapshot(in c: Context, completion: @escaping (SwoonlyEntry) -> Void) {
        completion(SwoonlyEntry(date: .now, snap: SharedStore.load() ?? .placeholder))
    }
    func getTimeline(in c: Context, completion: @escaping (Timeline<SwoonlyEntry>) -> Void) {
        let e = SwoonlyEntry(date: .now, snap: SharedStore.load() ?? .placeholder)
        completion(Timeline(entries: [e], policy: .after(.now.addingTimeInterval(3600))))
    }
}

struct SwoonlyWidgetView: View {
    var entry: SwoonlyEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "heart.fill").font(.caption2).foregroundStyle(rose)
                Text("SWOONLY").font(.caption2.weight(.bold)).tracking(1).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            if let title = entry.snap.currentTitle {
                Text("Keep reading").font(.caption2).foregroundStyle(.secondary)
                Text(title).font(.system(size: 17, weight: .bold, design: .serif)).lineLimit(2)
                if let next = entry.snap.nextChapterTitle {
                    Text("Next: \(next)").font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
            } else {
                Text("Find your next romance").font(.system(size: 16, weight: .bold, design: .serif)).lineLimit(2)
                Text("First chapters are free").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct SwoonlyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SwoonlyWidget", provider: SwoonlyProvider()) { SwoonlyWidgetView(entry: $0) }
            .configurationDisplayName("Keep Reading")
            .description("Jump back into your current story.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct SwoonlyWidgetBundle: WidgetBundle {
    var body: some Widget { SwoonlyWidget() }
}
