import UIKit
import Marketcloud

//Product class
public class Product {
    
    var id: Int?
    var description: String?
    var name: String?
    var images: [String]?
    var price: Double?
    var stock_level:Int?
    var quantity:Int?
    var hasVariants:Bool?
    var show:Bool
    
    //keeps track of the downloaded products
    public static var products = [Product]()
    
    
    
    
    //initialize a Product object taken from the API. (not for user's cart)
    internal init(id:Int, description:String, name:String, images:[String], price:Double, stock_level:Int, hasVariants:Bool) {
        self.id = id
        self.description = description
        self.name = name
        self.images = images
        self.price = price
        self.stock_level = stock_level
        self.hasVariants = hasVariants
        self.show = true
    }
    
    //Initialize a Product object for the user's cart
    internal init(id:Int, description:String, name:String, images:[String], price:Double, quantity:Int, hasVariants:Bool) {
        self.id = id
        self.description = description
        self.name = name
        self.images = images
        self.price = price
        self.quantity = quantity
        self.hasVariants = hasVariants
        self.show = true
    }

    //Method for filtering the products (not used yet...)
    public static func getProductsByFilters(marketcloud:Marketcloud, filter:Int, filterField:Int){
        switch filter {
        case 1  :
            let mainList = marketcloud.getProductById(filterField)
            print(mainList)
            if (mainList["errors"] == nil) {
                elabProducts(mainList)
            } else {
                print("no results")
                return
            }
        case 2  :
            let mainList = marketcloud.getProductsByCategory(filterField)
            if (mainList["count"]! as! Int != 0) {
                elabProducts(mainList)
            }
            else {
                print("no results")
                return
            }
        default :
            print("error: set 1 for getProductById, 2 for getProductsByCategory")
        }
    }
    
    //counts how many products have been downloaded
    public static func getProductsCount() -> Int {
        return products.count
    }
    

    
    //downloads the products then calls elabProducts in order to make objects from them
    public static func getProducts(marketcloud:Marketcloud) -> Bool{
        let productList = marketcloud.getProducts()
        return(elabProducts(productList))
    }
    
    /*
    Elaborates the downloaded products and creates objects from them.
    If some fields are missing the object won't be created (there will be
    only valid objects...)
    */
    private static func elabProducts(mainList:NSDictionary) -> Bool {
        products = [Product]()
        //print(mainList["data"]!.count)
        
        //check for a single filtered object
        guard (mainList["count"] != nil && mainList["data"] != nil) else {
            return elabOneProduct(mainList)
        }
        let items = mainList["data"]!.count
        
        for var i = 0; i < items; i++ {
            //print("Cycle \(i)")
            let temp = mainList["data"]![i]
            //print(temp)
            
            guard temp["id"]! != nil else {
                //print("id is nil - Skipping Object")
                continue
            }
            let tempId:Int = temp["id"]!! as! Int
            
            var tempDescription:String = "No description available"
            if(temp["description"]! == nil) {
                //print("temp[description]!!  == nil - Replacing Description")
            } else
                if(temp["description"]!!.isKindOfClass(NSNull)) {
                   // print("temp[description]!! isKindOfClass(NSNull)  - Replacing Description")
            }
            if (temp["description"]! != nil && !temp["description"]!!.isKindOfClass(NSNull)) {
                tempDescription = temp["description"]! as! String
            }
            
            guard temp["name"]! != nil else {
                //print("name is nil - Skipping Object")
                continue
            }
            let tempName:String = temp["name"]!! as! String
            
            var hasVariants:Bool = false
            if (temp["has_variants"]! != nil) {
                hasVariants = temp["has_variants"] as! Bool
            }
            
            var tempImages = [String]()
            if (temp["images"]! == nil) {
                //print("IMAGES IS NIL")
            } else {
                tempImages = temp["images"]! as! [String]
            }
            
            guard temp["price"]! != nil else {
                //print("price is nil")
                continue
            }
            let tempPrice:Double = temp["price"]! as! Double
            
            guard temp["stock_level"]! != nil else {
                //print("stock_level is nil")
                continue
            }
            
            var stock_level:Int = 100
            if(!(temp["stock_level"] is NSNull)) {
             stock_level = temp["stock_level"]! as! Int
            }

            let product = Product(id: tempId, description: tempDescription, name: tempName, images: tempImages, price: tempPrice, stock_level: stock_level, hasVariants: hasVariants)
           // print("Finished")
            products.append(product)
        }
        print("elabProducts is over! \n collected \(products.count) items!")
        return true
    }
    
    //Elaborates only one product
    private static func elabOneProduct(mainList:NSDictionary) -> Bool {
        print("Did I crash? count -> \(mainList["count"])")
        if (mainList["data"] == nil) {
            print("Connection error")
            return false
        }
        let temp = mainList["data"]!
        guard temp["id"] != nil else {
            return false
        }
        let tempId:Int = temp["id"]!! as! Int
        // print(tempId)
        
        var tempDescription:String = "No description available"
        if(temp["description"]! == nil) {
            //  print("temp[description]!!  == nil")
        } else
            if(temp["description"]!!.isKindOfClass(NSNull)) {
                //print("temp[description]!! isKindOfClass(NSNull)")
        }
        if (temp["description"]! != nil && !temp["description"]!!.isKindOfClass(NSNull)) {
            tempDescription = temp["description"]! as! String
        }
        
        guard temp["name"]! != nil else {
            //print("name is nil -> returning\n------------------\n")
            return false
        }
        let tempName:String = temp["name"]!! as! String
        
        var tempImages = [String]()
        if (temp["images"]! == nil) {
            //print("images is nil")
        } else {
            tempImages = temp["images"]! as! [String]
        }
        
        guard temp["price"]! != nil else {
            //print("price is nil")
            return false
        }
        let tempPrice:Double = temp["price"]! as! Double
        
        var hasVariants:Bool = false
        if (temp["has_variants"]! != nil) {
            hasVariants = temp["has_variants"] as! Bool
        }
        
        guard temp["stock_level"]! != nil else {
            //print("stock_quantity is nil")
            return false
        }
        let stock_level:Int = temp["stock_level"]! as! Int
        
        let product = Product(id: tempId, description: tempDescription, name: tempName, images: tempImages, price: tempPrice, stock_level:stock_level, hasVariants: hasVariants)
        products.append(product)
        return true
    }
    
    static func filter(var filter: String) {
        filter = filter.lowercaseString
        print("Filter method for \(filter)")
        let itemsTotal = products.count
        for var i = 0; i < itemsTotal; i++ {
            if products[i].name!.lowercaseString.rangeOfString(filter) == nil {
                products[i].show = false
            }
            else {
                print("Ok for \(products[i].name!)")
                products[i].show = true
            }
        }
    }
    
    static func removeFilters() {
        let itemsTotal = products.count
        for var i = 0; i < itemsTotal; i++ {
            products[i].show = true
        }
    }
    
}