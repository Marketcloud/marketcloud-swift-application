import UIKit
import Marketcloud

//Controller for the product's detail view
class ProductDetailsViewController: UIViewController {
    
    let marketcloud:Marketcloud? = MarketcloudMain.getMcloud()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var addToCartButton: UIButton!
    
    var product:Product? = nil
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.scrollToTop()
        
        //retrieves the product
        product = UserData.selectedProduct
        
        self.navigationItem.title = "Back"
        //print("Product is \(product!.name)")
        self.title = product!.name
        if(product!.images!.count != 0){
        imgView.load_image(product!.images![0], imageId: product!.id!)
        } else {
            imgView.image = UIImage(named: "logo")
        }
        labelDesc.text = product!.description?.stripHtmlTags()
        priceLabel.text = "Price: \(String(product!.price!))€";
    }
    
    //sets the quantity of the product
    @IBAction func changeQuantity(sender: UISegmentedControl) {
        var quantity:Int = Int(quantityLabel.text!)!
            switch segmentedControl.selectedSegmentIndex
            {
            case 1:
                //print("stock_quantity is \(product!.stock_level!)");
                if(quantity != product!.stock_level){
                quantityLabel.text = String(quantity + 1);
                quantity += 1;
               // print("Quantity is now \(quantity)")
                addToCartButton.enabled = true
                }
                else {
                    NSLog("OUT OF STOCK")
                }
            case 0:
                if(quantity != 0){
                    quantityLabel.text = String(quantity - 1);
                    quantity -= 1
                    if (quantity == 0) {
                        addToCartButton.enabled = false
                    }
                }
            default:
                break; 
            }
        
    }
    
    //adds an object to the cart
    @IBAction func addToCart(sender: UIButton) {
        let id:Int = (product?.id)!
        let quantity:Int = Int(quantityLabel.text!)!
        
        print("Selected id \(id) and quantity \(quantity)")
        
        var itemArray = [AnyObject]()
        
        //if has variants, auto-select the first one.
        //Variant support will be improved in the next versions
        let booleano:Bool = product!.hasVariants!
        if(booleano) {
            itemArray.append(["product_id":id,"quantity":quantity,"variant_id":1])
        }
        else {
            itemArray.append(["product_id":id,"quantity":quantity])
        }
        print("Printing itemArray")
        print(itemArray)
        let newCart = (marketcloud?.addToCart(Cart.cartId, data: itemArray))
        print(newCart)
        guard (newCart!["status"] != nil) else {
            let alertController = UIAlertController(title: "Error", message: "Network Error. The application will now terminate.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            exit(0)
        }
        let statusInt:Int = newCart!["status"] as! Int
        //print("Status number = \(statusInt)")
        guard (statusInt != 0 ) else {
            //print(newCart)
            let alertController = UIAlertController(title: "Error", message: "Unable to add the item to the cart. Probably it's out of stock.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        //sets the new cart with the new object
        Cart.refreshCart(newCart!)
        let alertController = UIAlertController(title: "Ok!", message: "Item added to cart!", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close",
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
