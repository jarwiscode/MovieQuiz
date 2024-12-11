import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGame
        case totalCorrectAnswers
        case totalQuestions
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            guard let data = storage.dictionary(forKey: Keys.bestGame.rawValue),
                  let correct = data["correct"] as? Int,
                  let total = data["total"] as? Int,
                  let date = data["date"] as? Date else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            let data: [String: Any] = [
                "correct": newValue.correct,
                "total": newValue.total,
                "date": newValue.date
            ]
            storage.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        guard totalQuestions > 0 else { return 0.0 }
        
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        return Double(totalCorrectAnswers) / Double(totalQuestions)
    }
    
    var totalCorrectAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalQuestions: Int {
        get {
            return storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers += count
        totalQuestions += amount
        
        gamesCount += 1
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter.string(from: date)
    }
}
