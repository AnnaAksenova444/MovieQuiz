import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alert:AlertPresenterProtocol = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    // MARK: - Functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        noButton.isEnabled = true
        yesButton.isEnabled = true
        imageView.layer.borderColor = nil
        imageView.layer.borderWidth = 0
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else {return}
                self.presenter.restartGame()
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
// MARK: - AlertPresenterDelegate

extension MovieQuizViewController:AlertPresenterDelegate {
    func show(quiz: AlertModel) {
        let alert = AlertPresenter()
        alert.delegate = self
        self.alert = alert
        
        alert.showAlert(quiz: quiz)
    }
}
