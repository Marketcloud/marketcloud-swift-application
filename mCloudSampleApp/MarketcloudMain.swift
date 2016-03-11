import Foundation
import Marketcloud

public class MarketcloudMain {
    
    internal static var marketcloud:Marketcloud? = nil
    
    //sets the marketcloud public key. Use it once just for initialize the SDK
    static func setMarketcloud(key:String) {
        marketcloud = Marketcloud(key:key)
        print("setted marketcloud var with key \(key)")
    }
    
    //returns the marketcloud object
    static func getMcloud() -> Marketcloud? {
        if(marketcloud != nil) {
            return marketcloud!
        }
        else {
            print("Did you forget to call setMarketcloud first? \nReturning nil")
            return nil
        }
    }
    
    //don't need to call it :)
    init?(){
        print("This class doesn't need to be initialized \nReturning nil")
        return nil
    }
    
}

//Extends the UIImageView class in order to load images from url
//usage: UIImageObject.load_image(url, imageId).
//The imageId field is to cache the image
extension UIImageView {
    
    func load_image(urlString:String, imageId:Int)
    {
        let imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if (error == nil && data != nil)
            {
                func display_image()
                {
                    self.image = UIImage(data: data!)
                    print("Finito per id \(imageId)")
                    ImageCache.push(imageId, image: self.image!)
                    print("Messo in cache id \(imageId)")
                }
                dispatch_async(dispatch_get_main_queue(), display_image)
            }
        }
        task.resume()
    }
}

//extends the String class adding a method to validate an email..
extension String {
    func isValidEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}

//Extends the UIScrollView class adding a method to scroll the view to the top.
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}