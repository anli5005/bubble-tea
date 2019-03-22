import SceneKit

public class FoodType: Hashable {
    public var name: String?
    
    public static func ==(a: FoodType, b: FoodType) -> Bool {
        return a === b
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public init(name: String?) {
        self.name = name
    }
}

public class LiquidType: FoodType {
    public let color: CGColor
    public var image: NSImage?
    
    public init(name: String? = nil, color: CGColor, image: NSImage? = nil) {
        self.color = color
        self.image = image
        super.init(name: name)
    }
}

public class BubbleType: FoodType {
    public let geometry: SCNGeometry
    public var image: NSImage?
    
    public init(name: String? = nil, geometry: SCNGeometry, image: NSImage? = nil) {
        self.geometry = geometry
        self.image = image
        super.init(name: name)
    }
}
