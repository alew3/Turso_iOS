import Foundation

struct DatabaseRow: Identifiable, Hashable, Equatable {
    let id = UUID()
    let data: [String: Any]
    
    subscript(key: String) -> Any? {
            return data[key]
    }

    static func == (lhs: DatabaseRow, rhs: DatabaseRow) -> Bool {
        return lhs.id == rhs.id && NSDictionary(dictionary: lhs.data).isEqual(to: rhs.data)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(NSDictionary(dictionary: data))
    }
}
