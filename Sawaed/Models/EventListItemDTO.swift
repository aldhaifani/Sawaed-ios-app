import Foundation

struct EventListItemDTO: Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let region: String?
    let city: String?
    let startDate: String?
}
