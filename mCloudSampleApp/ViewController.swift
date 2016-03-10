import UIKit
import Marketcloud

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
        if (marketcloud == nil) {
            print("Setting marketcloud variable")
            //f84af487-a315-42e6-a57a-d79296bd9d99

            MarketcloudMain.setMarketcloud("f84af487-a315-42e6-a57a-d79296bd9d99")
            marketcloud = (MarketcloudMain.getMcloud()!)
        }
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
        if(load){
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
        //Do nothing
    }
    
    //---------------Buttons

    
    @IBAction func loginButton(sender: UIButton) {
        guard (!emailField.text!.isEmpty && !passwordField.text!.isEmpty)  else {
            let alertController = UIAlertController(title: "Error", message: "Please fill both email and password fields.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return;
        }
       
        //La richiesta avviena in maniera asincrona
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //preparo roba per chiamata sincrona
            let loginTest:[String:String] = ["email":self.emailField.text!, "password":self.passwordField.text!]
             print("Ok! \(self.emailField.text!) - \(self.passwordField.text!)")
                dispatch_async(dispatch_get_main_queue()) {
                     SwiftSpinner.show("Loggin' in...")
                }
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
                UserData.setLastRegisteredUser(self.emailField.text!, password: self.passwordField.text!)
                Cart.getCart()
                print("Got Cart")
                self.performSegueWithIdentifier("next", sender: sender)
            }
        })
    }
    

    
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

