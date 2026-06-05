import Foundation

enum SharedStore {
    static let suiteName = "group.com.duolaameng.swoonly"
    private static let key = "swoonly_snapshot"
    static func save(_ s: SwoonlySnapshot) {
        guard let d = UserDefaults(suiteName: suiteName), let data = try? JSONEncoder().encode(s) else { return }
        d.set(data, forKey: key)
    }
    static func load() -> SwoonlySnapshot? {
        guard let d = UserDefaults(suiteName: suiteName), let data = d.data(forKey: key),
              let s = try? JSONDecoder().decode(SwoonlySnapshot.self, from: data) else { return nil }
        return s
    }
}
