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
        loginButton.isEnabled = false
        loadingAct.isHidden = false
        loadingAct.startAnimating()
        }
        else {
            loadingAct.isHidden = true
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.scrollToTop()
        
        //marketcloud object will be initialized only once
        if (marketcloud == nil) {
            print("Setting marketcloud variable")
            marketcloud = (MarketcloudMain.getMcloud()!)
        }
        
        //calls the getProducts method only if products are not been downloaded yet
        if(downloadProducts){
            print("Downloading Products")
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                let result = (Product.getProducts(self.marketcloud!))
                UserData.currencies = (self.marketcloud?.getCurrencies())
                    
                if (result) && (UserData.currencies != nil) {
                print("Products have been downloaded")
                print("Currencies have been downloaded")
                    print(UserData.currencies)
                DispatchQueue.main.async {
                self.loginButton.isEnabled = true
                self.loadingAct.stopAnimating()
                self.loadingAct.isHidden = true
                    if (UserData.getData() != nil) {
                        self.emailField.text = UserData.getData()!["email"]
                        self.passwordField.text = UserData.getData()!["password"]
                        self.logIn(nil)
                    }
                    }
                } else {
                    //errors are occurred
                    let alertController = UIAlertController(title: "Error", message: "Connection Error ", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Close",
                        style: UIAlertActionStyle.destructive,
                        handler: {(action:UIAlertAction) in
                            self.closeApp();
                        }))
                    self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        print("Logout Pressed")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let alertController = UIAlertController(title: "Error", message: "Memory Warning!!\n Program will now terminate", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.destructive, handler: {(action:UIAlertAction) in
            self.closeApp();
        }));
        self.present(alertController, animated: true, completion: nil)
    }
    
    //---------------TEXTFIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Do nothing :)
    }
    
    //---------------Buttons

    
    @IBAction func loginButton(_ sender: UIButton) {
        //verifies if there are empty fields
        guard (!emailField.text!.isEmpty && !passwordField.text!.isEmpty)  else {
            let alertController = UIAlertController(title: "Error", message: "Please fill both email and password fields.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.destructive,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return;
        }
        logIn(sender)
    }
    
    //Shows a popup with useful informations about the app
    @IBAction func aboutPopUp(_ sender: UIButton) {
        let connectionInfos:String = Reachability.checkConnectionType()
        let versionInfos:String = marketcloud!.utils.getVersion()
        let alertController = UIAlertController(title: "Informazioni", message: " Marketcloud - A Sample Application written in Swift 2.2 with <3 \n\n Connessione -> \(connectionInfos)\n Marketcloud SDK \(versionInfos) \n Public key: \(marketcloud!.getKey())", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close",
            style: UIAlertActionStyle.destructive,
            handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func closeApplication(_ sender: UIButton) {
        closeApp()
    }
    
    internal func closeApp() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    fileprivate func logIn(_ sender:UIButton?) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let loginTest:[String:String] = ["email":self.emailField.text!, "password":self.passwordField.text!]
            print("datas -> \(self.emailField.text!) - \(self.passwordField.text!)")
            
            DispatchQueue.main.async {
                SwiftSpinner.show("Loggin' in...")
            }
            
            //go for the login
            print("Sending \(loginTest) to marketcloud.logIn")
            print(self.marketcloud!.logIn(loginTest))
            let userId = self.marketcloud!.getUserId()
            
            print("Ok! UserId is \(userId)")
            
            DispatchQueue.main.async {
                SwiftSpinner.hide()
                guard userId != -1 else {
                    let alertController = UIAlertController(title: "Error", message: "Incorrect login attempt\n Please try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Close",
                        style: UIAlertActionStyle.destructive,
                        handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    print("Login failed")
                    return
                }
                //Sets data about the last registered user. Will be used when back in ViewController
                UserData.setLastLoggedUser(self.emailField.text!, password: self.passwordField.text!)
                
                
                //obtains cart
                Cart.getCart()
                if(sender != nil) {
                self.performSegue(withIdentifier: "next", sender: sender)
                }
                else {
                    self.performSegue(withIdentifier: "next", sender: nil)
                }
            }
        })
    }
}

