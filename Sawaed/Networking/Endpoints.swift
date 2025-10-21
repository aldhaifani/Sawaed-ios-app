import Foundation

enum Endpoints {
    static func authRequestOtp() -> String { "/api/mobile/auth/request-otp" }
    static func authVerifyOtp() -> String { "/api/mobile/auth/verify-otp" }
    static func authRefresh() -> String { "/api/mobile/auth/refresh" }
    static func authSignout() -> String { "/api/mobile/auth/signout" }

    static func onboardingStatus() -> String { "/api/mobile/v1/onboarding/status" }
    static func onboardingDraft() -> String { "/api/mobile/v1/onboarding/draft" }
    static func onboardingStep() -> String { "/api/mobile/v1/onboarding/step" }
    static func onboardingSaveDraftDetails() -> String { "/api/mobile/v1/onboarding/save-draft-details" }
    static func onboardingSaveDraftTaxonomies() -> String { "/api/mobile/v1/onboarding/save-draft-taxonomies" }
    static func onboardingComplete() -> String { "/api/mobile/v1/onboarding/complete" }

    static func locationsRegions() -> String { "/api/mobile/v1/locations/regions" }
    static func locationsCities() -> String { "/api/mobile/v1/locations/cities" }

    static func profileMe() -> String { "/api/mobile/v1/profile/me" }
    static func profileBasics() -> String { "/api/mobile/v1/profile/basics" }
    static func profilePhone() -> String { "/api/mobile/v1/profile/phone" }
    static func profileGender() -> String { "/api/mobile/v1/profile/gender" }
    static func profilePictureUploadUrl() -> String { "/api/mobile/v1/profile/picture/upload-url" }
    static func profilePictureComplete() -> String { "/api/mobile/v1/profile/picture/complete" }

    static func aiConfig() -> String { "/api/mobile/v1/ai/config" }
    static func aiSkills() -> String { "/api/mobile/v1/ai/skills" }
    static func aiPathActive() -> String { "/api/mobile/v1/ai/path/active" }
    static func aiPath() -> String { "/api/mobile/v1/ai/path" }
    static func aiCompleteModule() -> String { "/api/mobile/v1/ai/path/complete-module" }
    static func aiIncompleteModule() -> String { "/api/mobile/v1/ai/path/incomplete-module" }
    static func aiUnenroll() -> String { "/api/mobile/v1/ai/path/unenroll" }

    static func events() -> String { "/api/mobile/v1/events" }
    static func event(id: String) -> String { "/api/mobile/v1/events/\(id)" }
    static func eventRegister(id: String) -> String { "/api/mobile/v1/events/\(id)/register" }
    static func eventCancel(id: String) -> String { "/api/mobile/v1/events/\(id)/cancel" }

    static func chatSend() -> String { "/api/chat/send" }
    static func chatStatus() -> String { "/api/chat/status" }
}
