import SceneKit

public class FoodType: Hashable {
    public static func ==(a: FoodType, b: FoodType) -> Bool {
        return a === b
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public class LiquidType: FoodType {
    public var name: String?
    public let color: CGColor
    public var image: NSImage?
    
    public init(color: CGColor, image: NSImage? = nil) {
        self.color = color
        self.image = image
    }
}

public class BubbleType: FoodType {
    public var name: String?
    public let geometry: SCNGeometry
    public let physicsGeometry: SCNGeometry
    
    public init(geometry: SCNGeometry, physicsGeometry: SCNGeometry? = nil) {
        self.geometry = geometry
        self.physicsGeometry = physicsGeometry ?? geometry
    }
}
