import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert (quiz result: AlertModel) {
        guard let view = delegate else {return}
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                result.completion()
            }
        alert.addAction(action)
        
        view.present(alert, animated: true, completion: nil)
    }
}
