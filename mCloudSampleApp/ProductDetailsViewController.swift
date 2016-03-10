import UIKit
import Marketcloud

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
        product = UserData.selectedProduct
        self.navigationItem.title = "Back"
        print("Product is \(product!.name)")
        self.title = product!.name
        if(product!.images!.count != 0){
        imgView.load_image(product!.images![0], imageId: product!.id!)
        } else {
            imgView.image = UIImage(named: "logo")
        }
        labelDesc.text = product!.description
        priceLabel.text = "Price: \(String(product!.price!))€";
    }
    
    @IBAction func changeQuantity(sender: UISegmentedControl) {
        var quantity:Int = Int(quantityLabel.text!)!
            switch segmentedControl.selectedSegmentIndex
            {
            case 1:
                print("stock_quantity is \(product!.stock_level!)");
                if(quantity != product!.stock_level){
                quantityLabel.text = String(quantity + 1);
                quantity++;
                print("Quantity is now \(quantity)")
                addToCartButton.enabled = true
                }
                else {
                    print("OUT OF STOCK")
                }
            case 0:
                if(quantity != 0){
                    quantityLabel.text = String(quantity - 1);
                    quantity--
                    if (quantity == 0) {
                        addToCartButton.enabled = false
                    }
                }
            default:
                break; 
            }
        
    }
    
    @IBAction func addToCart(sender: UIButton) {
        let id:Int = (product?.id)!
        let quantity:Int = Int(quantityLabel.text!)!
        
        print("Selected id \(id) and quantity \(quantity)")
        
        var itemArray = [AnyObject]()
        
        let booleano:Bool = product!.hasVariants!
        if(booleano) {
            itemArray.append(["product_id":id,"quantity":quantity,"variant_id":1])
        }
        else {
            itemArray.append(["product_id":id,"quantity":quantity])
        }
        
        let newCart = (marketcloud?.addToCart(Cart.cartId, data: itemArray))
        
        guard (newCart!["status"] != nil) else {
            let alertController = UIAlertController(title: "Error", message: "Network Error. The application will now terminate.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            exit(0)
        }
        
        
        let statusInt:Int = newCart!["status"] as! Int
        print("Status number = \(statusInt)")
        guard (statusInt != 0 ) else {
            print(newCart)
            let alertController = UIAlertController(title: "Error", message: "Unable to add the item to the cart. Probably it's out of stock.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Destructive,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        Cart.refreshCart(newCart!)
        let alertController = UIAlertController(title: "Ok!", message: "Item added to cart!", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close",
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}