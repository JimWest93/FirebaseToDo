import UIKit
import Firebase
import SkyFloatingLabelTextField

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    let signInSegue = "signInSegue"
    let signUpSegue = "signUpSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardNotifications()
        viewsSetup()
        reLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "toDoListViewController") as? ToDoListViewController else {return}
        vc.modalPresentationStyle = .fullScreen
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty
        else { displayErrorLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error as NSError? != nil {
                let errorMassage = AuthErrorCode(rawValue: error!._code)!.errorMessage
                self?.displayErrorLabel(withText: errorMassage)
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: (self?.signInSegue)!, sender: nil)
                return
            }
            
            self?.displayErrorLabel(withText: "No such user")
            
        }
        
    }
    
    @IBAction func register(_ sender: Any) {
        performSegue(withIdentifier: signUpSegue, sender: nil)
    }
    
    func displayErrorLabel(withText text: String) {
        errorLabel.text = text
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            self?.errorLabel.alpha = 1
        }) { [weak self] complete in
            self?.errorLabel.alpha = 0
        }
        
    }
    
    func reLogin() {
        Auth.auth().addStateDidChangeListener({ [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.signInSegue)!, sender: nil)
            }
        })
    }
    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: view.bounds.size.height + keyboardFrameSize.height)
        (self.view as! UIScrollView).bounces = false
        (self.view as! UIScrollView).isScrollEnabled = true
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrameSize.height, right: 0)
    }
    
    @objc func keyboardDidHide() {
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        }, completion: nil)
        
        (self.view as! UIScrollView).isScrollEnabled = false
        
    }
    
    @objc func randomTap() {
        self.view.endEditing(true)
    }
    
    
    func viewsSetup() {
        errorLabel.alpha = 0
        
        passwordTextField.selectedTitleColor = .white
        emailTextField.selectedTitleColor = .white
        
        let eyeView = EyeView(frame: CGRect(x: -5, y: 0, width: 30, height: 20), target: passwordTextField)
        passwordTextField.rightView = eyeView
        passwordTextField.rightViewMode = .always
        
        tap = UITapGestureRecognizer(target: self, action: #selector(randomTap))
        self.view.addGestureRecognizer(tap)
    }
    
}
