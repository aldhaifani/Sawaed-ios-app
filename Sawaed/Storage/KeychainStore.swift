import Foundation
import Security

final class KeychainStore {
    private let service = "app.sawaed.mobile"
    private let accountAccess = "access_token"
    private let accountRefresh = "refresh_token"

    func accessToken() -> String? { read(key: accountAccess) }

    func setTokens(access: String, refresh: String) {
        _ = save(key: accountAccess, value: access)
        _ = save(key: accountRefresh, value: refresh)
    }

    func refreshToken() -> String? { read(key: accountRefresh) }

    func clearTokens() {
        _ = delete(key: accountAccess)
        _ = delete(key: accountRefresh)
    }

    private func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
