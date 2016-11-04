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
    @IBAction func confirmButton(_ sender: UIButton) {
        print("Confirmed!")
        
        
        //let order = MarketcloudMain.getMcloud()?.createOrder(UserData.lastAddressId, billingId: UserData.lastAddressId, items: Cart.lastCart!["data"]!["items"]!! as! NSArray)
        let cartId:Int = (Cart.lastCart!.value(forKey: "data") as! NSDictionary).value(forKey: "id") as! Int
        
        let order:NSDictionary = (MarketcloudMain.getMcloud()?.createOrder(UserData.lastAddressId, billingId: UserData.lastAddressId, cartId: cartId))!
        
        
        print("Printing order")
        print(order)
        
        let orderId = (order.value(forKey: "data") as! NSDictionary).value(forKey: "id") as! Int
        
        if(order["status"] as! Int == 1) {
            
            print("Elaborating stripeToken + order")
            print("Order id is \(orderId) and stripeToken is \(UserData.lastStripeToken)")
            print(MarketcloudMain.getMcloud()?.completeOrder(orderId, stripeToken: UserData.lastStripeToken))
            
            UserData.lastStripeToken = ""
            
            Cart.emptyCart()
            let alertController = UIAlertController(title: "Ok", message: "Order went fine. You will be redirect to main page", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.default,
                handler: {(action:UIAlertAction) in
                    self.returnToProducts()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        let alertController = UIAlertController(title: "Error", message: "Error in order creation. Maybe some product has expired or credit cart was not accepted ", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close",
            style: UIAlertActionStyle.destructive,
            handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //returns to the product's list view
    func returnToProducts() {
        if(self.navigationController == nil) {
            print("Aborting! navigationController is nil!")
            return
        } else {
            for i in 0 ..< self.navigationController!.viewControllers.count {
                if(self.navigationController?.viewControllers[i].isKind(of: ProductsViewController.self) == true) {
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[i] as! ProductsViewController, animated: true)
                    break;
                }
            }
        }
    }
}
