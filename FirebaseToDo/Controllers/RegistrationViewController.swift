import UIKit
import Firebase
import FirebaseAuth
import SkyFloatingLabelTextField

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewsSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .white
    }
    
    func showAlertWithError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showSucessfulAlert() {
        let alert = UIAlertController(title: "Alert!", message: "Registration successful!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        guard let email = emailTextField.text, let userName = userNameTextField.text, let password = passwordTextField.text, email != "", password != "", userName != ""
        else {
            self.showAlertWithError(error: "Please fill in all required fields")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if error == nil {
                if let result = result {
                    let ref = Database.database().reference().child("users")
                    ref.child(result.user.uid).updateChildValues(["name": userName, "email" : email])
                    self?.showSucessfulAlert()
                }
            } else {
                if let error = error as NSError? {
                    self?.showAlertWithError(error: AuthErrorCode(rawValue: error._code)!.errorMessage)
                }
                
            }
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func randomTap() {
        self.view.endEditing(true)
    }
    
    func viewsSetup() {
        
        passwordTextField.selectedTitleColor = .white
        emailTextField.selectedTitleColor = .white
        userNameTextField.selectedTitleColor = .white
        
        let eyeView = EyeView(frame: CGRect(x: -5, y: 0, width: 30, height: 20), target: passwordTextField)
        passwordTextField.rightView = eyeView
        passwordTextField.rightViewMode = .always
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(randomTap))
        self.view.addGestureRecognizer(tap)
    }
    
}
