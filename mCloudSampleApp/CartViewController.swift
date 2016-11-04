import UIKit

//controller for the cart view
class CartViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var tblDatas: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        //print("Bazinga")
        let total = String(Cart.calcTotal())
        totalLabel.text = "Total: \(total)"
        if(Cart.products.count == 0) {
            checkOutButton.isEnabled = false
        }
    }
    
    //-------------TABLEVIEW
    override func viewWillAppear(_ animated: Bool) {
        tblDatas.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Cart.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CellCartController
        cell.titleCell.text = Cart.products[indexPath.row].name!
        cell.priceCell.text = "Price: \(String(Cart.products[indexPath.row].price!))€";
        let quantity:String = String(Cart.products[indexPath.row].quantity!)
        cell.quantityCell.text = "Quantity: \(quantity)"
        
        cell.imgCell.image = nil
        if(Cart.products[indexPath.row].images!.count != 0) {
            
            if(ImageCache.isInCache(Cart.products[indexPath.row].id!)) {
             //   print("Image is in Cache")
                let image = ImageCache.get(Cart.products[indexPath.row].id!)
                cell.imgCell.image = nil;
                cell.imgCell.image = image
            }
            else
            {
             //   print("\n Image was not in cache ...\nSetting image from url \(Cart.products[indexPath.row].images![0]) with id \(Cart.products[indexPath.row].id!)")
                cell.imgCell.image = nil;
                cell.imgCell.load_image(Cart.products[indexPath.row].images![0],imageId: Cart.products[indexPath.row].id!)
            }
            
        }
        else {
          //  print("No image found for \(Product.products[indexPath.row].name!)")
            cell.imgCell.image = nil;
            cell.imgCell.image = UIImage(named: "logo")
        }
        return cell
    }
    
    //slide left to delete a product when in the list
    func tableView(_ TableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete) {
            print("I'm going to delete @ row \(indexPath.row) \n Object is \(Cart.products[indexPath.row].name)")
            
            var itemArray = [Any]()
            
            if(Cart.products[indexPath.row].hasVariants!) {
                itemArray.append(["product_id":Cart.products[indexPath.row].id!,"variant_id":1])
            } else {
                itemArray.append(["product_id":Cart.products[indexPath.row].id!])
            }
            
            let newCart = MarketcloudMain.getMcloud()?.removeFromCart(Cart.cartId, data: itemArray)
            
            
            let statusInt:Int = newCart!["status"] as! Int
            print("Status number = \(statusInt)")
            guard (statusInt != 0 ) else {
                let alertController = UIAlertController(title: "Error", message: "Error in removing product(s) from the cart.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Close",
                    style: UIAlertActionStyle.destructive,
                    handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //refreshes cart with the deleted object
            Cart.refreshCart(newCart!)
            if(Cart.products.isEmpty) {
                checkOutButton.isEnabled = false
            }
            else {
                checkOutButton.isEnabled = true
            }
            //recalulates total
            let total = String(Cart.calcTotal())
            totalLabel.text = "Total: \(total)"
            
            let alertController = UIAlertController(title: "Ok!", message: "Item(s) removed from cart!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close",
                style: UIAlertActionStyle.default,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            //refreshes table
            tblDatas.reloadData()
        }
    }
}
