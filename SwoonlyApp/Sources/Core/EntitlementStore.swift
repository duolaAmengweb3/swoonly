import StoreKit
import SwiftUI

@MainActor
final class EntitlementStore: ObservableObject {
    static let shared = EntitlementStore()
    static let monthlyID = "com.duolaameng.swoonly.monthly"
    static let yearlyID  = "com.duolaameng.swoonly.yearly"
    static var productIDs: [String] { [monthlyID, yearlyID] }

    @Published private(set) var isPro: Bool
    @Published private(set) var products: [Product] = []
    private let key = "swoonly_pro"

    init() {
        isPro = UserDefaults.standard.bool(forKey: key)
        let args = ProcessInfo.processInfo.arguments
        // Skip StoreKit when a launch arg forces a state (screenshots/reset/preview/UI tests).
        if args.contains(where: { ["--reset", "--screenshots", "--lockedPreview", "--uitestPro"].contains($0) }) { return }
        Task { await observeTransactions(); await refresh(); await loadProducts() }
    }

    var monthly: Product? { products.first { $0.id == Self.monthlyID } }
    var yearly:  Product? { products.first { $0.id == Self.yearlyID } }
    var monthlyPrice: String { monthly?.displayPrice ?? "$12.99" }
    var yearlyPrice:  String { yearly?.displayPrice ?? "$79.99" }

    func loadProducts() async {
        products = (try? await Product.products(for: Self.productIDs))?
            .sorted { $0.price < $1.price } ?? []
    }

    func refresh() async {
        for await r in Transaction.currentEntitlements {
            if case .verified(let t) = r, Self.productIDs.contains(t.productID),
               t.revocationDate == nil, !(t.expirationDate.map { $0 < .now } ?? false) {
                setPro(true); return
            }
        }
        setPro(false)
    }

    private func observeTransactions() async {
        Task.detached {
            for await r in Transaction.updates {
                if case .verified(let t) = r { await t.finish(); await self.refresh() }
            }
        }
    }

    @discardableResult
    func purchase(_ product: Product) async throws -> Bool {
        if case .success(let v) = try await product.purchase(), case .verified(let t) = v {
            await t.finish(); await refresh(); return isPro
        }
        return false
    }

    func restore() async throws { try await AppStore.sync(); await refresh() }

    func setPro(_ v: Bool) {
        isPro = v
        UserDefaults.standard.set(v, forKey: key)
    }
}
