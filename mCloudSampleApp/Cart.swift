import Foundation
import Marketcloud

public class Cart {
    
    public static var lastCart:NSDictionary? = nil
    public static var products = [Product]()
    public static var cartId:Int = -1

    public static func elabCartItems() {
        print("Starting elabCartItems")
        print("Before crash : lastCart is \(lastCart)")
        let cartItems = lastCart!["data"]!["items"]
        let itemsCount = cartItems!!.count
        
        for var i = 0; i < itemsCount; i++ {
            let temp = cartItems!![i]!
            
            guard temp["id"]! != nil else {
                continue
            }
            let tempId:Int = temp["id"]!! as! Int
            
            var tempDescription:String = "No description available"
            if(temp["description"]! == nil) {
            } else
                if(temp["description"]!!.isKindOfClass(NSNull)) {
            }
            if (temp["description"]! != nil && !temp["description"]!!.isKindOfClass(NSNull)) {
                tempDescription = temp["description"]! as! String
            }
            
            guard temp["name"]! != nil else {
                continue
            }
            let tempName:String = temp["name"]!! as! String
            
            var tempImages = [String]()
            if (temp["images"]! == nil) {
            } else {
                tempImages = temp["images"]! as! [String]
            }
            
            var hasVariants:Bool = false
            if (temp["has_variants"]! != nil) {
                hasVariants = temp["has_variants"] as! Bool
            }

            
            guard temp["price"]! != nil else {
                continue
            }
            let tempPrice:Double = temp["price"]! as! Double
            
            guard temp["quantity"]! != nil else {
                continue
            }
            let quantity:Int = temp["quantity"]! as! Int
            
            let product = Product(id: tempId, description: tempDescription, name: tempName, images: tempImages, price: tempPrice, quantity: quantity, hasVariants: hasVariants)
            products.append(product)
        }
        print("Products in cart")
        dump(products)
    }
    
    public static func refreshCart(cart:NSDictionary) {
        print("Refreshing cart. New Cart is :")
        print(cart)
        lastCart = cart;
        products.removeAll()
        guard (lastCart!["id"] != nil) else {
            cartId = lastCart!["data"]!["id"] as! Int
            elabCartItems()
            return
        }
        cartId = lastCart!["id"] as! Int
        elabCartItems()
    }
    
    public static func getCart() {
        lastCart = (MarketcloudMain.getMcloud()?.getCart())!
        guard (lastCart!["errors"] == nil) else {
            print("users had no cart. Creating one...")
            lastCart =  (MarketcloudMain.getMcloud()?.createEmptyCart())!
            let cartDatas:NSDictionary = lastCart!["data"]! as! NSDictionary
            cartId = cartDatas["id"] as! Int
            print("cart id is \(cartId)")
            return
        }
        let cartDatas:NSDictionary = lastCart!["data"]! as! NSDictionary
        cartId = cartDatas["id"] as! Int
        print("cart id is \(cartId)")
        print("Calling elabCartItems")
        print("But first, let me call lastCart!")
    
        elabCartItems()
    }
    
    public static func calcTotal() -> Double {
        print("calc Total")
        let itemsTotal = products.count
        print("Items total is \(itemsTotal)")
        var total:Double = 0
        for var i = 0; i < itemsTotal; i++ {
            total += (products[i].price! * Double(products[i].quantity!))
        }
        return total
    }
    
    public static func generateTextRecap() -> String {
        var ret:String = ""
        let itemsTotal = products.count
        for var i = 0; i < itemsTotal; i++ {
            ret += "Item: \(products[i].name!) - Quantity \(products[i].quantity!)\n"
            ret += "price: \(products[i].price! * Double(products[i].quantity!))\n\n"
        }
        return ret
    }
    
    public static func emptyCart() {
        var itemArray = [AnyObject]()
        let itemsTotal = products.count
        for var i = 0; i < itemsTotal; i++ {
            if(products[i].hasVariants!) {
            itemArray.append(["product_id":products[i].id!,"variant_id":1])
            } else {
            itemArray.append(["product_id":products[i].id!])
            }
        }
        let newCart = MarketcloudMain.getMcloud()?.removeFromCart(Cart.cartId, data: itemArray)
        refreshCart(newCart!)
    }
}