import Foundation

struct GameResult {
    var correct: Int
    var total: Int
    var date: Date
    
    init(correct: Int, total: Int, date: Date) {
        self.correct = correct
        self.total = total
        self.date = date
    }
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

