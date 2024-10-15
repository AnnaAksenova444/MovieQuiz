import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var correctAnswers = 0
    
    private var currentQuestionIndex = 0
    
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol?
    weak var viewController: MovieQuizViewController?
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert (model: QuizQuestion) -> QuizStepViewModel{
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        guard let statisticService else { return }
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/10"
            statisticService.store(
                correct: correctAnswers,
                totalQuestions: self.questionsAmount)
            
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "\(text) \n" +
                "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
                "Рекорд: \(statisticService.bestGame.correct)/10 \(statisticService.bestGame.date.dateTimeString)\n" +
                "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self else {return}
                    self.self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            )
            viewController?.show (quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
