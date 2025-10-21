import Foundation

struct UserDefaultsStore {
    private let defaults = UserDefaults.standard

    func setLocale(_ value: String) {
        defaults.set(value, forKey: "locale_preference")
    }

    func locale() -> String {
        defaults.string(forKey: "locale_preference") ?? Locale.current.language.languageCode?.identifier ?? "en"
    }

    func setConversationId(_ id: String, forSkill skillId: String) {
        defaults.set(id, forKey: "conv_\(skillId)")
    }

    func conversationId(forSkill skillId: String) -> String? {
        defaults.string(forKey: "conv_\(skillId)")
    }
}
