import UIKit

//Controller for the first part of the checkout
class Checkout1ViewCtrl: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var fullnameLabel: UITextField!
    
    @IBOutlet weak var countryLabel: UITextField!
    
    @IBOutlet weak var stateLabel: UITextField!
    
    @IBOutlet weak var cityLabel: UITextField!
    
    @IBOutlet weak var addressLabel: UITextField!
    
    @IBOutlet weak var postalcodeLabel: UITextField!
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
    }

    
    //---------------TEXTFIELD
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        /* 
        print(fullnameLabel.text!)
        print(countryLabel.text!)
        print(stateLabel.text!)
        print(cityLabel.text!)
        print(addressLabel.text!)
        print(postalcodeLabel.text!)
        //Do nothing
        */
    }
    
    //validates fields, saves the address then goes to the next view
    @IBAction func nextButton(sender: UIButton) {
        if(validator()) {
            let fullname = (fullnameLabel.text!)
            let country = (countryLabel.text!)
            let state = (stateLabel.text!)
            let city = (cityLabel.text!)
            let address = (addressLabel.text!)
            let postalCode = (postalcodeLabel.text!)
            let email = UserData.getLastRegistedUserEmail()
            
            print("validator is ok. \n email is \(email)")
            let testAddress:[String:String] = ["email":UserData.getLastRegistedUserEmail(),"full_name": fullname,"country" : country, "state": state, "city": city, "address1": address, "postal_code": postalCode]
            
            let shippingAddress = MarketcloudMain.getMcloud()!.createAddress(testAddress)
            print(shippingAddress)
            
            guard (shippingAddress["status"] as! Int != 0) else {

                let alertController = UIAlertController(title: "Error", message: "Critical error in creating new address", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Close",
                    style: UIAlertActionStyle.Destructive,
                    handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            UserData.lastAddressId = shippingAddress["data"]!["id"] as! Int
            UserData.lastAddressInfos = "\(fullname) \n\(country),\(state) \n\(city), \(address) - \(postalCode)"
            self.performSegueWithIdentifier("check2", sender: sender)
        }
    }
    
    //validates the fields
    func validator() -> Bool {
        guard (!fullnameLabel.text!.isEmpty && !countryLabel.text!.isEmpty && !stateLabel.text!.isEmpty && !cityLabel.text!.isEmpty && !addressLabel.text!.isEmpty && !postalcodeLabel.text!.isEmpty)  else {
            let alertController = UIAlertController(title: "Error", message: "All fields must be filled out in order to process the request", preferredStyle: .Alert)
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