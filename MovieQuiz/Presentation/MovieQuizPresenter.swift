import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    // MARK: - Functions
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        didAnswer(isCorrectAnswer: true)
    }
    
    func noButtonClicked() {
        didAnswer(isCorrectAnswer: false)
    }
    // MARK: - Private functions
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func convert (model: QuizQuestion) -> QuizStepViewModel{
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func proceedToNextQuestionOrResults() {
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
                    self.restartGame()
                }
            )
            viewController?.show (quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isCorrectAnswer
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.proceedToNextQuestionOrResults()
        }
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
}
