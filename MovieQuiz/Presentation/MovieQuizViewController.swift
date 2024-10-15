import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private let currentDate = Date()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alert:AlertPresenterProtocol = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        
        showLoadingIndicator()
        questionFactory.loadData()
        
        presenter.viewController = self
    }
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        noButton.isEnabled = true
        yesButton.isEnabled = true
        imageView.layer.borderColor = nil
        imageView.layer.borderWidth = 0
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.statisticService = self.statisticService
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else {return}
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.loadData()
            }
        )
        show(quiz: viewModel)
    }
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}
//MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate{
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
// MARK: - AlertPresenterDelegate

extension MovieQuizViewController:AlertPresenterDelegate {
    func show(quiz: AlertModel) {
        let alert = AlertPresenter()
        alert.delegate = self
        self.alert = alert
        
        alert.showAlert(quiz: quiz)
    }
}
