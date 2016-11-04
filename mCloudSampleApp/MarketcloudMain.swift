import Foundation
import Marketcloud

open class MarketcloudMain {
    
    internal static var marketcloud:Marketcloud? = nil
    fileprivate static let publicKey:String = "2cd15ec1-833c-4713-afbf-b7510e357bc8"
        
    //sets the marketcloud public key and returns the marketcloud object
    static func getMcloud() -> Marketcloud? {
        
        if(marketcloud != nil) {
            return marketcloud!
        }
        else {
            marketcloud = Marketcloud(key:publicKey)
            print("setted marketcloud var with key \(publicKey)")
            return marketcloud!
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
    
    func load_image(_ urlString:String, imageId:Int)
    {
        let imgURL: URL = URL(string: urlString)!
        let request: URLRequest = URLRequest(url: imgURL)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {
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
                DispatchQueue.main.async(execute: display_image)
            }
        })
        task.resume()
    }
}

//extends the String class adding a method to validate an email..
extension String {
    func isValidEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    func stripHtmlTags() -> String {
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.caseInsensitive])
        
        let range = NSMakeRange(0, self.characters.count)
        let htmlLessString :String = regex.stringByReplacingMatches(in: self, options: [],
            range:range ,
            withTemplate: "")
        
        return htmlLessString
    }
}


//Extends the UIScrollView class adding a method to scroll the view to the top.
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
