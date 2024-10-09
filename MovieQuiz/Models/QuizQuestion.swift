import Foundation

struct QuizQuestion {
    let image: Data
    let text: String
    let correctAnswer: Bool
    
    init(image: Data, text: String, correctAnswer: Bool) {
        self.image = image
        self.text = text
        self.correctAnswer = correctAnswer
    }
}
