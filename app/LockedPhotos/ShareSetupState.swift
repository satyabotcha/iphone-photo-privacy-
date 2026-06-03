import Foundation

enum ShareSetupState {
    static let appGroupIdentifier = "group.com.satyabotcha.LockedPhotos"

    private static let hasUsedShareExtensionKey = "hasUsedShareExtension"

    static var hasUsedShareExtension: Bool {
        defaults.bool(forKey: hasUsedShareExtensionKey)
    }

    static func markShareExtensionUsed() {
        defaults.set(true, forKey: hasUsedShareExtensionKey)
        // Extensions can be torn down soon after launch, so flush the usage signal eagerly.
        defaults.synchronize()
    }

    static func reset() {
        defaults.removeObject(forKey: hasUsedShareExtensionKey)
        defaults.synchronize()
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
}
