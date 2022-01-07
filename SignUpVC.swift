//
//  SignUpVC.swift
//  SilverFox
//
//  Created by Satinderjeet Kaur on 24/02/21.
//

import UIKit
import Alamofire

class SignUpVC: UIViewController {
    enum SignupFromViewController {
      case program
      case other
    }
    //MARK:- OUTLETS
    
    @IBOutlet weak var backBtnImageView: UIImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var alreadyHaveActLbl: UILabel!
    @IBOutlet weak var securePassShowHideBtn: UIButton!
    
    //MARK:- OUTLET OF CONSTRAINTS
     @IBOutlet weak var bottomImageHtConstraint: NSLayoutConstraint!
    var isLoginFrom = SignupFromViewController.other
    var commingFrom = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let modelName = UIDevice.modelName
        print(modelName)
        if modelName == "Simulator iPod touch (7th generation)" {
            bottomImageHtConstraint.constant = 125.0
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
   //MARK:- BUTTON ACTIONS
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        if tfFirstName.text?.trimmingCharacters(in: .whitespaces) == "" {
            Alert.showSimple(enterFirstName)
        }else if tfLastName.text?.trimmingCharacters(in: .whitespaces) == "" {
            Alert.showSimple(enterLastName)
        }else if tfEmail.text?.trimmingCharacters(in: .whitespaces) == "" {
            Alert.showSimple("Please enter email")
        }else if isValidEmail(tfEmail.text!) == false{
            Alert.showSimple(enterValidEmail)
        }else if tfPassword.text?.trimmingCharacters(in: .whitespaces) == "" {
            Alert.showSimple(enterPassword)
        }else if tfPassword.text?.count ?? 0 < 6{
            Alert.showSimple("Password Should contain atleast 6 characters")
        }else if tfPassword.text != tfConfirmPassword.text {
            Alert.showSimple(enterConfirmpassword)
        }else{
            signUp()
        }
    }
    
    @IBAction func signInBtnAction(_ sender: UIButton) {
        goToSignIn()
    }
    
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        goToSignIn()
    }
    
    func goToSignIn(){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = mainStoryBoard.instantiateViewController(withIdentifier: loginVC)
        UIApplication.shared.windows.first?.rootViewController = ViewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    @IBAction func securePasswordShowBtnAction(_ sender: Any) {
        if (self.tfPassword.isSecureTextEntry == true) {
            securePassShowHideBtn.setTitle("Hide", for: .normal)
            self.tfPassword.isSecureTextEntry = false
        } else {
            securePassShowHideBtn.setTitle("Show", for: .normal)
            self.tfPassword.isSecureTextEntry = true
        }
    }
    
    
}

extension SignUpVC {
    
    func signUp() {
        Hud.show(message: "Please Wait", view: self.view)
        DataService.sharedInstance.signUp(fName: tfFirstName.text ?? "", lName: tfLastName.text ?? "", emailId: tfEmail.text ?? "", password: tfPassword.text ?? "" ) { (resultDict, errorMsg) in
            Hud.hide(view: self.view)
            print(resultDict as Any)
            
            if errorMsg == nil{
                print(resultDict)
                if resultDict?.status == 200 {
                    UserDefaults.standard.setValue(resultDict?.data?.ID, forKey: kUserID)
                    UserDefaults.standard.setValue(resultDict?.data?.user_email, forKey: kUserEmail)
                    UserDefaults.standard.setValue(resultDict?.data?.first_name, forKey: kUserFirstName)
                    UserDefaults.standard.setValue(resultDict?.data?.last_name, forKey: kUserLastName)
                    reloadHome = "true"
                     
                    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                    let ViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarVC")
                    UIApplication.shared.windows.first?.rootViewController = ViewController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                    
                } else {
                    
                }
                if let message = resultDict?.msg {
                    Alert.showSimple(message)
                }
            }else{
                Alert.showSimple(errorMsg ?? "")
            }
        }
    }
    
}
