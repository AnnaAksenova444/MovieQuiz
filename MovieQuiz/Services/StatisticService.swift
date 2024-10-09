import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    private enum Keys: String {
        case correctAnswers
        case bestGame
        case gamesCount
        case correct
        case total
        case date
        case totalAccuracy
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult (
                correct: storage.integer(forKey: Keys.correct.rawValue),
                total: storage.integer(forKey: Keys.total.rawValue),
                date: storage.object(forKey: Keys.date.rawValue) as? Date ?? Date())
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            storage.double(forKey: Keys.totalAccuracy.rawValue)
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let gamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            if Double(gamesCount) != 0 {
                
                return (Double(correct) / (10 * Double(gamesCount))) * 100.00
                
            } else {
                
                return 0
            }
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func store(correct count: Int, totalQuestions amount: Int) {
        let oldGameResult = bestGame
        var newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(oldGameResult) {
            newGameResult = oldGameResult
        }
        
        gamesCount += 1
        
        if bestGame.correct <= count {
            bestGame.correct = count
            bestGame.total = amount
            bestGame.date = Date()
        }
    }
}















