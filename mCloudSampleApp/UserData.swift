import Foundation

//keeps tracks of the user data in order to share between the views
public class UserData {
    
    private static var lastRegisteredUser = ["email":"", "password":""]
    
    public static var lastAddressId:Int = -1
    public static var lastAddressInfos:String? = nil
    
    public static var selectedProduct:Product? = nil
    
    public static func setLastRegisteredUser(email:String, password:String) {
        lastRegisteredUser = ["email":email, "password":password]
    }
    
    public static func getLastRegistedUserEmail() -> String {
        return lastRegisteredUser["email"]!
    }
    
    public static func getLastRegisteredUserPassword() -> String {
        return lastRegisteredUser["password"]!
    }
    

}
