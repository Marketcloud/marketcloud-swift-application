import UIKit

class CartViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var tblDatas: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        print("Bazinga")
        let total = String(Cart.calcTotal())
        totalLabel.text = "Total: \(total)"
        if(Cart.products.count == 0) {
            checkOutButton.enabled = false
        }
    }
    
    //-------------TABLEVIEW
    override func viewWillAppear(animated: Bool) {
        tblDatas.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Cart.products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //sincronizza le celle in base alla posizione nell'array tasks
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CellCartController
        cell.titleCell.text = Cart.products[indexPath.row].name!
        cell.priceCell.text = "Price: \(String(Cart.products[indexPath.row].price!))€";
        let quantity:String = String(Cart.products[indexPath.row].quantity!)
        cell.quantityCell.text = "Quantity: \(quantity)"
        
        cell.imgCell.image = nil
        if(Cart.products[indexPath.row].images!.count != 0) {
            
            if(ImageCache.isInCache(Cart.products[indexPath.row].id!)) {
                print("Image is in Cache")
                let image = ImageCache.get(Cart.products[indexPath.row].id!)
                cell.imgCell.image = nil;
                cell.imgCell.image = image
            }
            else
            {
                print("\n Image was not in cache ...\nSetting image from url \(Cart.products[indexPath.row].images![0]) with id \(Cart.products[indexPath.row].id!)")
                cell.imgCell.image = nil;
                cell.imgCell.load_image(Cart.products[indexPath.row].images![0],imageId: Cart.products[indexPath.row].id!)
            }
            
        }
        else {
            print("No image found for \(Product.products[indexPath.row].name!)")
            cell.imgCell.image = nil;
            cell.imgCell.image = UIImage(named: "logo")
        }
        return cell
    }
    
    //GESTISCE L'ELIMINAZIONE DEI FILM DELL'UTENTE
    func tableView(TableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            print("I'm going to delete @ row \(indexPath.row) \n Object is \(Cart.products[indexPath.row].name)")
            
            var itemArray = [AnyObject]()
            
            if(Cart.products[indexPath.row].hasVariants!) {
                itemArray.append(["product_id":Cart.products[indexPath.row].id!,"variant_id":1])
            } else {
                itemArray.append(["product_id":Cart.products[indexPath.row].id!])
            }
            
            let newCart = MarketcloudMain.getMcloud()?.removeFromCart(Cart.cartId, data: itemArray)
            
            
            let statusInt:Int = newCart!["status"] as! Int
            print("Status number = \(statusInt)")
            guard (statusInt != 0 ) else {
                let alertController = UIAlertController(title: "Error", message: "Error in removing product(s) from the cart.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Close",
                    style: UIAlertActionStyle.Destructive,
                    handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            Cart.refreshCart(newCart!)
            if(Cart.products.isEmpty) {
                checkOutButton.enabled = false
            }
            else {
                checkOutButton.enabled = true
            }
            
            let total = String(Cart.calcTotal())
            totalLabel.text = "Total: \(total)"
            
            let alertController = UIAlertController(title: "Ok!", message: "Item(s) removed from cart!", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.Default,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            tblDatas.reloadData()
        }
    }
}