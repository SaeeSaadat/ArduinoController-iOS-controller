//
//  SSLoginViewController.swift
//  ArduinoController-ios
//
//  Created by Saee Saadat on 2/16/21.
//

import UIKit

class SSLoginViewController: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var switchDescLabel: UILabel!
    
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTopConstraint: NSLayoutConstraint!
    
    private var mode: Int = 0 // 0 = signup , 1 = signin
    private let animationDuration: Double = 0.3
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SSNavigationController.shared.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SSNavigationController.shared.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

    }
    
    private func setupView() {
        setupTextFields()
        setupButton()
        scrollView.alwaysBounceVertical = true
    }
    
    private func setupTextFields() {
       
        let fields = [usernameTextfield, emailTextField, passwordTextfield, confirmPasswordTextfield]
        
        fields.forEach({
            if let field = $0 {
                field.attributedPlaceholder = NSAttributedString(string: field.placeholder?.localized ?? "", attributes: [NSAttributedString.Key.foregroundColor: SSColors.accent2.color.withAlphaComponent(0.3)])
                
                field.delegate = self
                
                let separator = UIView()
                field.addSubview(separator)
                
                separator.tag = SSViewTags.textFieldSeparator.rawValue
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = SSColors.accent2.color.withAlphaComponent(0.7)
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 1.0),
                    separator.bottomAnchor.constraint(equalTo: field.bottomAnchor),
                    separator.leadingAnchor.constraint(equalTo: field.leadingAnchor, constant: -5),
                    separator.trailingAnchor.constraint(equalTo: field.trailingAnchor, constant: -5)
                ])
            }
        })
    }
    
    private func customizeSeparator(_ view: UIView) {
        view.tag = SSViewTags.textFieldSeparator.rawValue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SSColors.accent2.color.withAlphaComponent(0.7)
        guard let supview = view.superview else { return }
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1.0),
            view.bottomAnchor.constraint(equalTo: supview.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: supview.leadingAnchor, constant: -5),
            view.trailingAnchor.constraint(equalTo: supview.trailingAnchor, constant: -5)
        ])
    }
    
    private func setupButton() {
        submitButton.layer.cornerRadius = 20.0
        submitButton.layer.borderWidth = 2.0
        submitButton.layer.borderColor = SSColors.accent.color.cgColor
    }

    @IBAction func switchMode(_ sender: UIButton) {
        if mode == 0 {
            sender.setTitle("sign.up".localized, for: .normal)
            switchToSignin()
        } else {
            sender.setTitle("sign.in".localized, for: .normal)
            switchToSignup()
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        //Validation
        guard let username = usernameTextfield.text, username.count > 4 else {
            invalidateTextField(usernameTextfield)
            showError(message: "username.short")
            return
        }
        
        guard let password = passwordTextfield.text, checkPassword(password) else {
            invalidateTextField(passwordTextfield)
            showError(message: "password.rule")
            return
        }
        
        if mode == 0 { // signup
            
            guard let email = emailTextField.text, checkEmail(email) else {
                invalidateTextField(emailTextField)
                showError(message: "email.invalid")
                return
            }
            
            guard let confPass = confirmPasswordTextfield.text, password == confPass else {
                invalidateTextField(confirmPasswordTextfield)
                showError(message: "confirm.password.error")
                return
            }
            
            //TODO: Signup
            
        } else { //signin
            
            //TODO Signin
            signin(username: username, sessionToken: "R1892719646192478")
        }
    }
    
    private func signin(username: String, sessionToken: String) {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appdelegate.signin(username: username, sessionToken: sessionToken)
    }
}

//MARK: - Validation
extension SSLoginViewController {
    
    private func checkPassword(_ password: String) -> Bool {
        let checker = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        return checker.evaluate(with: password)
    }
    
    private func checkEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func invalidateTextField(_ field: UITextField) {
        guard let line = field.viewWithTag(SSViewTags.textFieldSeparator.rawValue) else { return }
        line.backgroundColor = SSColors.errorRed.color.withAlphaComponent(0.7)
    }
    
    private func validateTextField(_ field: UITextField) {
        guard let line = field.viewWithTag(SSViewTags.textFieldSeparator.rawValue) else { return }
        line.backgroundColor = SSColors.accent2.color.withAlphaComponent(0.7)
    }
    
    private func showError(message: String) {
        SSNavigationController.shared.showBottomPopUpAlert(withTitle: message.localized, alertState: .failure)
    }
}


//MARK: - Transition login / logout
extension SSLoginViewController {
    
    private func switchToSignin() {
        
        passwordTopConstraint.constant = ConstraintConstants.signinPasswordUp.rawValue
        buttonTopConstraint.constant = ConstraintConstants.signinButtonUp.rawValue
        
        self.submitButton.setTitle("sign.in".localized, for: .normal)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.emailTextField.alpha = 0
            self.confirmPasswordTextfield.alpha = 0
            self.termsLabel.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { finished in
            if finished {
                self.emailTextField.isHidden = true
                self.confirmPasswordTextfield.isHidden = true
                self.termsLabel.isHidden = true
            }
        })
        
        UIView.transition(with: switchDescLabel, duration: animationDuration, options: [.transitionCrossDissolve], animations: {
            self.switchDescLabel.text = "switch.desc.sign.in".localized
        }, completion: nil)
        
        mode = 1
    }
    
    private func switchToSignup() {
        passwordTopConstraint.constant = ConstraintConstants.signupPasswordUp.rawValue
        buttonTopConstraint.constant = ConstraintConstants.signupButtonUp.rawValue
        
        self.emailTextField.isHidden = false
        self.confirmPasswordTextfield.isHidden = false
        self.termsLabel.isHidden = false
        self.submitButton.setTitle("sign.up".localized, for: .normal)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.emailTextField.alpha = 1.0
            self.confirmPasswordTextfield.alpha = 1.0
            self.termsLabel.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: switchDescLabel, duration: animationDuration, options: [.transitionCrossDissolve], animations: {
            self.switchDescLabel.text = "switch.desc.sign.in".localized
        }, completion: nil)
        
        mode = 0
    }
    
    private enum ConstraintConstants : CGFloat {
        case signupButtonUp = 120
        case signupPasswordUp = 90
        case signinButtonUp = 45
        case signinPasswordUp = 15
    }
    
}

extension SSLoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateTextField(textField)
    }
}