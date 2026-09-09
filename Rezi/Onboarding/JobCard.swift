import SwiftUI

/// One row in the swipeable deck.
struct JobCard: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let salary: String
    let location: String
    /// Resume match, 0–100.
    let score: Int
    /// Picks which of the supplied `CompanyLogo1…N` this card wears. Stored on
    /// the card rather than derived from deck position, so a card keeps its
    /// logo as the stack rotates.
    var logoIndex: Int = 0

    /// The word under the score in the gauge.
    var scoreLabel: String {
        switch score {
        case 70...: return "Best"
        case 40..<70: return "Good"
        default: return "Fair"
        }
    }

    var scoreColor: Color {
        switch score {
        case 70...: return ReziColor.scoreBest
        case 40..<70: return ReziColor.scoreGood
        default: return ReziColor.scoreWeak
        }
    }

    static func == (lhs: JobCard, rhs: JobCard) -> Bool { lhs.id == rhs.id }
}

extension JobCard {
    /// The three cards from the design, plus two more so the deck can recycle
    /// without a card ever being on screen twice.
    static let samples: [JobCard] = [
        JobCard(title: "Software Engineer", salary: "$250k-300k", location: "San Francisco, CA", score: 53, logoIndex: 0),
        JobCard(title: "Software Engineer", salary: "$250k-300k", location: "San Francisco, CA", score: 83, logoIndex: 1),
        JobCard(title: "Software Engineer", salary: "$250k-300k", location: "San Francisco, CA", score: 53, logoIndex: 2),
        JobCard(title: "Product Designer", salary: "$180k-220k", location: "New York, NY", score: 91, logoIndex: 3),
        JobCard(title: "iOS Engineer", salary: "$210k-260k", location: "Remote, US", score: 67, logoIndex: 4)
    ]
}

enum SwipeDirection {
    case left, right

    var sign: CGFloat { self == .right ? 1 : -1 }
}
