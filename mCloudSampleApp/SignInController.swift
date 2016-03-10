import UIKit
import Marketcloud

class SignInController: UIViewController, UITextFieldDelegate
{
    
    let marketcloud:Marketcloud? = MarketcloudMain.getMcloud()
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signInButton(sender: UIButton) {
        if validator(){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                let datas:[String:String] = ["email":self.emailField.text!,"name": self.nameField.text!,"password" : self.passwordField.text!]
                dispatch_async(dispatch_get_main_queue()) {
                    SwiftSpinner.show("Signin' in...")
                }
                let newUser:NSDictionary = self.marketcloud!.createUser(datas)
                print(newUser)
                dispatch_async(dispatch_get_main_queue()) {
                    SwiftSpinner.hide()
                    guard (newUser["status"] as! Int != 0) else {
                        let alertController = UIAlertController(title: "Error", message: "Email already in use. Try with a different one!", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Close",
                            style: UIAlertActionStyle.Destructive,
                            handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    }
                    let alertController = UIAlertController(title: "Ok!", message: "User created successfully!", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                        UserData.setLastRegisteredUser(self.emailField.text!, password: self.passwordField.text!);
                        print("Setted UserData \n \(UserData.getLastRegistedUserEmail(),UserData.getLastRegisteredUserPassword())")
                        let next = self.storyboard!.instantiateViewControllerWithIdentifier("viewController") as! ViewController
                        next.downloadProducts = false
                        next.load = true                        
                        self.navigationController?.pushViewController(next, animated: true)
                    }));
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    //---------------TEXTFIELD
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //print(emailField.text!, nameField.text!, passwordField.text!)
    }
    
    func isValidPassword(password:String) -> Bool {
        if (password.characters.count > 5) {
            return true
        }
        else {
            return false
        }
    }
    
    func validator() -> Bool {
        guard (!emailField.text!.isEmpty && !nameField.text!.isEmpty && !passwordField.text!.isEmpty)  else {
            let alertController = UIAlertController(title: "Error", message: "All fields must be filled out in order to process the request", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        guard (isValidPassword(passwordField.text!))  else {
            let alertController = UIAlertController(title: "Error", message: "Password must contain at least 6 characters!", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        guard (emailField.text!.isValidEmail())  else {
            let alertController = UIAlertController(title: "Error", message: "Invalid email", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        self.view.endEditing(true)
        return true
    }
}