import SceneKit
  
public struct Level {
    public let scene: SCNScene
    public let liquids: [LiquidType]
    public let maxLiquidsPerOrder: Int
    public let bubbles: [BubbleType]
    public let maxBubblesPerOrder: Int
    public let needsShake: Set<Bool>
    public let orderFrequency: Double
    public let orderTimeRange: ClosedRange<Double>
    public let name: String?
    
    public init(scene: SCNScene, liquids: [LiquidType] = [], maxLiquidsPerOrder: Int = Int.max, bubbles: [BubbleType] = [], maxBubblesPerOrder: Int = Int.max, needsShake: Set<Bool> = [true, false], orderFrequency: Double = 1.0, orderTimeRange: ClosedRange<Double> = 30.0...60.0, name: String? = nil) {
        self.scene = scene
        self.liquids = liquids
        self.maxLiquidsPerOrder = maxLiquidsPerOrder
        self.bubbles = bubbles
        self.maxBubblesPerOrder = maxBubblesPerOrder
        self.needsShake = needsShake
        self.orderFrequency = orderFrequency
        self.orderTimeRange = orderTimeRange
        self.name = name
    }
    
    public func generateLiquidDispensers(in node: SCNNode, labelled: Bool = true) {
        for (index, liquid) in liquids.enumerated() {
            let dispenser = LiquidDispenserNode(liquid: liquid, isLabelled: labelled)
            dispenser.position = node.position + SCNVector3(2 * (Double(index) - Double(liquids.count) / 2 + 0.5), 1.5, 0)
            dispenser.yMoveLimit = dispenser.position.y - 1.5
            scene.rootNode.addChildNode(dispenser)
        }
    }
    
    public func generateBubbleDispensers(in node: SCNNode, labelled: Bool = true) {
        for (index, bubble) in bubbles.enumerated() {
            let dispenser = BubbleDispenserNode(bubbleType: bubble, isLabelled: labelled)
            dispenser.position = node.position + SCNVector3(Double(index) - Double(bubbles.count) / 2 + 0.5, 1.5, 0)
            scene.rootNode.addChildNode(dispenser)
        }
    }
}
