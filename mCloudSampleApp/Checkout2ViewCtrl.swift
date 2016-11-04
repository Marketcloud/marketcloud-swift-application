import UIKit
import Stripe

//Controller for the credit card's view.
class Checkout2ViewCtrl: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var creditCardField: UITextField!
    
    @IBOutlet weak var yearExpField: UITextField!
    @IBOutlet weak var monthExpField: UITextField!
    @IBOutlet weak var cvcField: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBAction func nextButton(_ sender: UIButton) {
        print("Going next...")
        guard(validator()) else {
            
            let alertController = UIAlertController(title: "Error", message: "All of the fields must be filled correctly", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.destructive,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        DispatchQueue.main.async {
            SwiftSpinner.show("Loading")
        }
        //Obtains datas about the credit cards in Stripe card object
        let card = STPCardParams() //creating a stripe card object
        card.number = creditCardField.text!
        card.cvc = cvcField.text!
        card.expMonth = UInt(monthExpField.text!)!
        card.expYear = UInt(yearExpField.text!)!
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            guard let stripeToken = token else {
                DispatchQueue.main.async {
                    SwiftSpinner.hide()
                }
                NSLog("Error creating token: %@", error!.localizedDescription);
                return
            }
            UserData.lastStripeToken = stripeToken.tokenId
            DispatchQueue.main.async {
                SwiftSpinner.hide()
            }
            //TODO: send the token to your server so it can create a charge
            let alert = UIAlertController(title: "Welcome to Stripe", message: "Token created: \(stripeToken.tokenId)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default,  handler: {(action:UIAlertAction) in
                self.performSegue(withIdentifier: "check3", sender: sender)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //validates the credit card's field
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
    
    //TEXTFIELDS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    //-------------
    
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
    }
}
