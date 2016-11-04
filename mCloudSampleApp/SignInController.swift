import UIKit
import Marketcloud

//Controller for the signin view
class SignInController: UIViewController, UITextFieldDelegate
{
    
    let marketcloud:Marketcloud? = MarketcloudMain.getMcloud()
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    //validate the fields, then creates thenew user and returns to the login view
    @IBAction func signInButton(_ sender: UIButton) {
        if validator(){
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                
                let datas:[String:String] = ["email":self.emailField.text!,"name": self.nameField.text!,"password" : self.passwordField.text!]
                DispatchQueue.main.async {
                    SwiftSpinner.show("Signin' in...")
                }
                let newUser:NSDictionary = self.marketcloud!.createUser(datas)
                print(newUser)
                DispatchQueue.main.async {
                    SwiftSpinner.hide()
                    guard (newUser["status"] as! Int != 0) else {
                        let alertController = UIAlertController(title: "Error", message: "Email already in use. Try with a different one!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Close",
                            style: UIAlertActionStyle.destructive,
                            handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    let alertController = UIAlertController(title: "Ok!", message: "User created successfully!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                        UserData.setLastRegisteredUser(self.emailField.text!, password: self.passwordField.text!);
                        print("Setted UserData \n \(UserData.getLastRegistedUserEmail(),UserData.getLastRegisteredUserPassword())")
                        //returns to the login view
                        let next = self.storyboard!.instantiateViewController(withIdentifier: "viewController") as! ViewController
                        next.downloadProducts = false
                        next.load = true                        
                        self.navigationController?.pushViewController(next, animated: true)
                    }));
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    //---------------TEXTFIELD
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print(emailField.text!, nameField.text!, passwordField.text!)
    }
    
    func isValidPassword(_ password:String) -> Bool {
        if (password.characters.count > 5) {
            return true
        }
        else {
            return false
        }
    }
    
    func validator() -> Bool {
        guard (!emailField.text!.isEmpty && !nameField.text!.isEmpty && !passwordField.text!.isEmpty)  else {
            let alertController = UIAlertController(title: "Error", message: "All fields must be filled out in order to process the request", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.destructive,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        guard (isValidPassword(passwordField.text!))  else {
            let alertController = UIAlertController(title: "Error", message: "Password must contain at least 6 characters!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.destructive,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        guard (emailField.text!.isValidEmail())  else {
            let alertController = UIAlertController(title: "Error", message: "Invalid email", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.destructive,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        self.view.endEditing(true)
        return true
    }
}
