import Foundation

struct EventDetailDTO: Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let region: String?
    let city: String?
    let startDate: String?
    let endDate: String?
}
