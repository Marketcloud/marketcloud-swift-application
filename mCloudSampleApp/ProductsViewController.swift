import UIKit
import Marketcloud

//Controller for the products list view
class ProductsViewController: UIViewController, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource {
    
    var marketcloud:Marketcloud? = MarketcloudMain.getMcloud()

    @IBOutlet weak var tblProducts: UITableView!
    
    //logs out, destroyes the cart and returns to the login view
    @IBAction func logoutPressed(sender: UIBarButtonItem) {
        let res = marketcloud!.logOut()
        if(res["Ok"] != nil ) {
            print(res)
            print("Logout button Pressed")
            Cart.products.removeAll()
            Cart.lastCart = nil
            Cart.cartId = -1
            print("CartId is now \(Cart.cartId)")
        }
        else {
            print(res)
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Products List"
    }
    
    //-------------TABLEVIEW
    
    override func viewWillAppear(animated: Bool) {
        tblProducts.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Product.getProductsCount()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (Product.products[indexPath.row].show == false) {
            return 0
        } else {
            return 110
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //sincronizza le celle in base alla posizione nell'array tasks
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CellProductsController
        
        cell.titleCell.text = Product.products[indexPath.row].name!
        //cell.descrCell.text = Products.products[indexPath.row].description
        cell.priceCell.text = "Price: \(String(Product.products[indexPath.row].price!))€";
    

        dispatch_async(dispatch_get_main_queue(), {
            // check if the cell is still on screen, and only if it is, update the image.
            let updateCell = tableView.cellForRowAtIndexPath(indexPath)
            if updateCell != nil {
                if(Product.products[indexPath.row].images!.count != 0) {
                    if(ImageCache.isInCache(Product.products[indexPath.row].id!)) {
                        //print("Image is in Cache")
                        let image = ImageCache.get(Product.products[indexPath.row].id!)
                        cell.imgCell.image = nil;
                        cell.imgCell.image = image
                    }
                        else
                    {
                    //print("\n Image was not in cache ...\nSetting image from url \(Product.products[indexPath.row].images![0]) with id \(Product.products[indexPath.row].id!)")
                    cell.imgCell.image = nil;
                    cell.imgCell.load_image(Product.products[indexPath.row].images![0],imageId: Product.products[indexPath.row].id!)
                    }
                }
                else {
                    //print("No image found for \(Product.products[indexPath.row].name!)")
                    cell.imgCell.image = nil;
                    cell.imgCell.image = UIImage(named: "logo")
                }
                
                cell.setNeedsLayout()
            }
        })
        return cell
    }
    
    //---------------------
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //for filtering purposes
    func textFieldDidEndEditing(textField: UITextField) {
        let filter = textField.text!
        if (filter == "") {
            Product.removeFilters()
        } else {
            Product.filter(filter)
            print("Filtering \(filter)")
        }
        tblProducts.reloadData()
    }
    //---------------------

    
    //-----------SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "detail"){
        UserData.selectedProduct = Product.products[(tblProducts.indexPathForSelectedRow?.row)!]
        //print("setted \(Product.products[tblProducts.indexPathForSelectedRow!.row])")
        }
    }
}
