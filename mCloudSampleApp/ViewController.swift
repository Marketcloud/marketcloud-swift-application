import UIKit
import Marketcloud

//view controller for the main view
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loadingAct: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var marketcloud:Marketcloud? = MarketcloudMain.getMcloud()
    var downloadProducts:Bool = true
    var load:Bool = false
    
    override func viewDidLoad() {
        if(downloadProducts) {
        loginButton.enabled = false
        loadingAct.hidden = false
        loadingAct.startAnimating()
        }
        else {
            loadingAct.hidden = true
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.scrollToTop()
        
        //marketcloud object will be initialized only once
        if (marketcloud == nil) {
            print("Setting marketcloud variable")
            MarketcloudMain.setMarketcloud("f84af487-a315-42e6-a57a-d79296bd9d99")
            marketcloud = (MarketcloudMain.getMcloud()!)
        }
        //calls the getProducts method only if products are not been downloaded yet
        if(downloadProducts){
            print("Downloading Products")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let result = (Product.getProducts(self.marketcloud!))
                    
                if (result) {
                print("Products have been downloaded")
                dispatch_async(dispatch_get_main_queue()) {
                self.loginButton.enabled = true
                self.loadingAct.stopAnimating()
                self.loadingAct.hidden = true
                    }
                } else {
                    //errors are occurred
                    let alertController = UIAlertController(title: "Error", message: "Connection Error ", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close",
                        style: UIAlertActionStyle.Destructive,
                        handler: {(action:UIAlertAction) in
                            self.closeApp();
                        }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
        if(load){ //if user came from the signup view
            print("Loading user fields")
            print(UserData.getLastRegistedUserEmail())
            print(UserData.getLastRegisteredUserPassword())
            if(UserData.getLastRegistedUserEmail() != "") {
                emailField.text = UserData.getLastRegistedUserEmail()
            }
            if(UserData.getLastRegisteredUserPassword() != "") {
                passwordField.text = UserData.getLastRegisteredUserPassword()
            }
        }
    }
    
    @IBAction func logOutButtonPressed(sender: UIBarButtonItem) {
        print("Logout Pressed")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let alertController = UIAlertController(title: "Error", message: "Memory Warning!!\n Program will now terminate", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Destructive, handler: {(action:UIAlertAction) in
            self.closeApp();
        }));
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //---------------TEXTFIELD
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //Do nothing :)
    }
    
    //---------------Buttons

    
    @IBAction func loginButton(sender: UIButton) {
        //verifies if there are empty fields
        guard (!emailField.text!.isEmpty && !passwordField.text!.isEmpty)  else {
            let alertController = UIAlertController(title: "Error", message: "Please fill both email and password fields.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let loginTest:[String:String] = ["email":self.emailField.text!, "password":self.passwordField.text!]
             print("Ok! \(self.emailField.text!) - \(self.passwordField.text!)")
            
                dispatch_async(dispatch_get_main_queue()) {
                     SwiftSpinner.show("Loggin' in...")
                }
            
            //go for the login
            self.marketcloud!.logIn(loginTest)
            let userId = self.marketcloud!.getUserId()
            
            dispatch_async(dispatch_get_main_queue()) {
                SwiftSpinner.hide()
                guard userId != -1 else {
                    let alertController = UIAlertController(title: "Error", message: "Incorrect login attempt\n Please try again.", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close",
                    style: UIAlertActionStyle.Destructive,
                    handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    print("Login failed")
                    return
                }
                //Sets data about the last registered user. Will be used when back in ViewController
                UserData.setLastRegisteredUser(self.emailField.text!, password: self.passwordField.text!)
                //obtains cart
                Cart.getCart()
                self.performSegueWithIdentifier("next", sender: sender)
            }
        })
    }
    
    //Shows a popup with useful informations about the app
    @IBAction func aboutPopUp(sender: UIButton) {
        let connectionInfos:String = Reachability.checkConnectionType()
        let alertController = UIAlertController(title: "Informazioni", message: " Marketcloud - A Sample Application written in Swift 2.1 with <3 \n\n Connessione -> \(connectionInfos)\n Marketcloud SDK \n Public key: \(marketcloud!.getKey())", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close",
            style: UIAlertActionStyle.Destructive,
            handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func closeApplication(sender: UIButton) {
        closeApp()
    }
    
    internal func closeApp() {
        UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
    }
}

