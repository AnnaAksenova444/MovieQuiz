import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert (quiz result: AlertModel) {
        guard let view = delegate as? UIViewController else {return}
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) {[weak self] _ in
                guard self != nil else {return}
                result.completion()
            }
        alert.addAction(action)
        
        view.present(alert, animated: true, completion: nil)
    }
}
