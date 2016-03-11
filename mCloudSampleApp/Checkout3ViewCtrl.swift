import UIKit

//Controller for the last checkout part
class Checkout3ViewCtrl: UIViewController
{
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        orderRecapLabel.text = Cart.generateTextRecap()
        shippingAddressRecapLabel.text = UserData.lastAddressInfos!
    }

    @IBOutlet weak var orderRecapLabel: UILabel!

    @IBOutlet weak var shippingAddressRecapLabel: UILabel!

    //sets the order data then calls the createOrder method.
    //Eventually, if the order went fine empties the cart.
    @IBAction func confirmButton(sender: UIButton) {
        print("Confirmed!")
        
        let order = MarketcloudMain.getMcloud()?.createOrder(UserData.lastAddressId, billingId: UserData.lastAddressId, items: Cart.lastCart!["data"]!["items"]!! as! NSArray)
        print(order)
        
        if(order!["status"] as! Int == 1) {
            Cart.emptyCart()
            let alertController = UIAlertController(title: "Ok", message: "Order went fine. You will be redirect to main page", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Default,
                handler: {(action:UIAlertAction) in
                    self.returnToProducts()
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        let alertController = UIAlertController(title: "Error", message: "Error in order creation. Maybe some product has expired or credit cart was not accepted ", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close",
            style: UIAlertActionStyle.Destructive,
            handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //returns to the product's list view
    func returnToProducts() {
        for (var i = 0; i < self.navigationController?.viewControllers.count; i++) {
            if(self.navigationController?.viewControllers[i].isKindOfClass(ProductsViewController) == true) {
                self.navigationController?.popToViewController(self.navigationController!.viewControllers[i] as! ProductsViewController, animated: true)
                break;
            }
    }
    }
}