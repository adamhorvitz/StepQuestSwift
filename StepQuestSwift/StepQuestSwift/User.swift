struct User: Identifiable, Equatable {
    var id: String
    var name: String
    var steps: Int
    var rank: String
    var avatarSymbol: String

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
