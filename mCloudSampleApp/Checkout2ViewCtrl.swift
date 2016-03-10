import UIKit
import Stripe

class Checkout2ViewCtrl: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var creditCardField: UITextField!
    
    @IBOutlet weak var yearExpField: UITextField!
    @IBOutlet weak var monthExpField: UITextField!
    @IBOutlet weak var cvcField: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBAction func nextButton(sender: UIButton) {
        print("Going next...")
        guard(validator()) else {
            
            let alertController = UIAlertController(title: "Error", message: "All of the fields must be filled correctly", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let card = STPCardParams() //creating a stripe card object
        card.number = creditCardField.text!
        card.cvc = cvcField.text!
        card.expMonth = UInt(monthExpField.text!)!
        card.expYear = UInt(yearExpField.text!)!
        STPAPIClient.sharedClient().createTokenWithCard(card) { token, error in
            guard let stripeToken = token else {
                NSLog("Error creating token: %@", error!.localizedDescription);
                return
            }
            
            // TODO: send the token to your server so it can create a charge
            let alert = UIAlertController(title: "Welcome to Stripe", message: "Token created: \(stripeToken)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default,  handler: {(action:UIAlertAction) in
                self.performSegueWithIdentifier("check3", sender: sender)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    func validator() -> Bool {
        print("Validator on")
        
        print(monthExpField.text?.characters.count)
        print(yearExpField.text?.characters.count)
        print(creditCardField.text?.characters.count)
        print(cvcField.text?.characters.count)
        
        if(monthExpField.text?.characters.count != 2 ||  yearExpField.text?.characters.count != 2 || creditCardField.text?.characters.count != 16 || cvcField.text?.characters.count != 3)  {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
    }
}