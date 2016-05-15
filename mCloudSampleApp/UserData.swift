import Foundation

//keeps tracks of the user data in order to share between the views
public class UserData {
    
    private static var lastRegisteredUser = ["email":"", "password":""]
    private static var lastLoggedUser = ["email":"", "password":""]

    public static var lastAddressId:Int = -1
    public static var lastAddressInfos:String? = nil
    
    public static var selectedProduct:Product? = nil
    
    public static let defaults = NSUserDefaults.standardUserDefaults()
    
    public static func setLastRegisteredUser(email:String, password:String) {
        lastRegisteredUser = ["email":email, "password":password]
        
    }
    
    public static func setLastLoggedUser(email:String, password:String) {
        lastLoggedUser = ["email":email, "password":password]
        defaults.setObject(email, forKey: "email")
        defaults.setObject(password, forKey: "password")
    }

    
    public static func getLastRegistedUserEmail() -> String {
        return lastRegisteredUser["email"]!
    }
    
    public static func getLastRegisteredUserPassword() -> String {
        return lastRegisteredUser["password"]!
    }
    
    public static func getLastLoggedUserEmail() -> String {
        return lastLoggedUser["email"]!
    }
    
    public static func getLastLoggedUserPassword() -> String {
        return lastLoggedUser["password"]!
    }

    
    public static func getData() -> [String:String]? {
        let email:String = defaults.objectForKey("email") as? String ?? String()
        let password:String = defaults.objectForKey("password") as? String ?? String()
        
        if(email == "" || password == "") {
           return nil
        }
        else {
            return ["email":email, "password":password]
        }
    }
    

}
