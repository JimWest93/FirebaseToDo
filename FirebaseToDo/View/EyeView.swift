import UIKit

class EyeView: UIView {
    
    let eyeButton = UIButton()
    
    var passwordTextField = UITextField()
    
    var isSecurity = false
    
    init(frame: CGRect, target: UITextField) {
        self.passwordTextField = target
        super.init(frame: frame)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.frame.size = CGSize(width: 30, height: 20)
        eyeButton.tintColor = .black
        eyeButton.center = self.center
        eyeButton.addTarget(self, action: #selector(eyePressed), for: .touchUpInside)

        addSubview(eyeButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func eyePressed() {
        
        switch isSecurity {
        case true : eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        case false: eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }

        passwordTextField.isSecureTextEntry = isSecurity
        isSecurity = !isSecurity
    }
    
}
