import Foundation

//keeps tracks of the user data in order to share between the views
open class UserData {
    
    fileprivate static var lastRegisteredUser:[String:String] = ["email":"", "password":""]
    fileprivate static var lastLoggedUser:[String:String] = ["email":"", "password":""]

    open static var lastAddressId:Int = -1
    open static var lastAddressInfos:String? = nil
    
    open static var selectedProduct:Product? = nil
    
    open static let defaults:UserDefaults = UserDefaults.standard
    
    open static var lastStripeToken:String = ""
    
    open static var currencies:NSDictionary? = nil
    
    open static func setLastRegisteredUser(_ email:String, password:String) {
        lastRegisteredUser = ["email":email, "password":password]
        
    }
    
    open static func setLastLoggedUser(_ email:String, password:String) {
        lastLoggedUser = ["email":email, "password":password]
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
    }

    
    open static func getLastRegistedUserEmail() -> String {
        return lastRegisteredUser["email"]!
    }
    
    open static func getLastRegisteredUserPassword() -> String {
        return lastRegisteredUser["password"]!
    }
    
    open static func getLastLoggedUserEmail() -> String {
        return lastLoggedUser["email"]!
    }
    
    open static func getLastLoggedUserPassword() -> String {
        return lastLoggedUser["password"]!
    }

    
    open static func getData() -> [String:String]? {
        let email:String = defaults.object(forKey: "email") as? String ?? String()
        let password:String = defaults.object(forKey: "password") as? String ?? String()
        
        if(email == "" || password == "") {
           return nil
        }
        else {
            return ["email":email, "password":password]
        }
    }
    

}
