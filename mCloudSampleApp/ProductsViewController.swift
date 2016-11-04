import UIKit
import Marketcloud

//Controller for the products list view
class ProductsViewController: UIViewController, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource {
    
    var marketcloud:Marketcloud? = MarketcloudMain.getMcloud()

    @IBOutlet weak var tblProducts: UITableView!
    
    //logs out, destroyes the cart and returns to the login view
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
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
        navigationController?.popToRootViewController(animated: true)
    }

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Products List"
        print("printing cart")
        print(marketcloud!.getCart())
    }
    
    //-------------TABLEVIEW
    
    override func viewWillAppear(_ animated: Bool) {
        tblProducts.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Product.getProductsCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (Product.products[indexPath.row].show == false) {
            return 0
        } else {
            return 110
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //sincronizza le celle in base alla posizione nell'array tasks
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CellProductsController
        
        cell.titleCell.text = Product.products[indexPath.row].name!
        //cell.descrCell.text = Products.products[indexPath.row].description
        cell.priceCell.text = "Price: \(String(Product.products[indexPath.row].price!))€";
    

        DispatchQueue.main.async(execute: {
            // check if the cell is still on screen, and only if it is, update the image.
            let updateCell = tableView.cellForRow(at: indexPath)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //for filtering purposes
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detail"){
        UserData.selectedProduct = Product.products[(tblProducts.indexPathForSelectedRow?.row)!]
        //print("setted \(Product.products[tblProducts.indexPathForSelectedRow!.row])")
        }
    }
}
