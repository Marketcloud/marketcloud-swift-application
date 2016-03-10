import UIKit
import Foundation

public class ImageCache {
    
    private static var someDict = [Int: UIImage]()
    
    public static func push(id:Int, image:UIImage) {
        someDict[id] = image
    }
    
    public static func isInCache(id:Int) -> Bool {
        if someDict.indexForKey(id) != nil {
            return true
        } else {
            return false
        }
    }
    
    public static func get(id:Int) -> UIImage? {
            return someDict[id]!
    }
    
    public static func emptyCache() {
        someDict.removeAll()
    }
}