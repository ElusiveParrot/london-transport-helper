/*
 Represents a single disruption from TFL's API
 */
struct Disruption: Hashable, Decodable {
    let description:    String
    let created:        String?
    let lastUpdate:     String?
}
