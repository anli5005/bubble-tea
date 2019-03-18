import CoreGraphics

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
    public let viscosity: Double
    
    public init(color: CGColor, viscosity: Double = 0) {
        self.color = color
        self.viscosity = viscosity
    }
}

public class BubbleType: FoodType {
    public var name: String?
}
