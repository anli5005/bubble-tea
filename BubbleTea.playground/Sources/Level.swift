import SceneKit
  
public class Level {
    public let scene: SCNScene
    public let liquids: [LiquidType]
    public let maxLiquidsPerOrder: Int
    public let bubbles: [BubbleType]
    public let maxBubblesPerOrder: Int
    public let needsShake: Set<Bool>
    public let orderFrequency: Double
    public let orderTimeRange: ClosedRange<Double>
    public let reputationLossMultiplier: Double
    public let reputationPerCorrectOrder: Double
    public let targetMoney: Int
    public let timeLimit: TimeInterval?
    public let name: String?
    internal var cupGenerator: CupGenerator?
    internal var cupSubmitter: CupSubmitter?
    internal var cupTrash: CupTrash?
    
    public init(scene: SCNScene, liquids: [LiquidType] = [], maxLiquidsPerOrder: Int = Int.max, bubbles: [BubbleType] = [], maxBubblesPerOrder: Int = Int.max, needsShake: Set<Bool> = [true, false], orderFrequency: Double = 1.0, orderTimeRange: ClosedRange<Double> = 30.0...60.0, reputationLossMultiplier: Double = 1.0, reputationPerCorrectOrder: Double = 0.3, targetMoney: Int, timeLimit: TimeInterval? = nil, name: String? = nil) {
        self.scene = scene
        self.liquids = liquids
        self.maxLiquidsPerOrder = maxLiquidsPerOrder
        self.bubbles = bubbles
        self.maxBubblesPerOrder = maxBubblesPerOrder
        self.needsShake = needsShake
        self.orderFrequency = orderFrequency
        self.orderTimeRange = orderTimeRange
        self.reputationLossMultiplier = reputationLossMultiplier
        self.reputationPerCorrectOrder = reputationPerCorrectOrder
        self.targetMoney = targetMoney
        self.timeLimit = timeLimit
        self.name = name
    }
    
    public func generateLiquidDispensers(at position: SCNVector3, labelled: Bool = true) {
        for (index, liquid) in liquids.enumerated() {
            let dispenser = LiquidDispenserNode(liquid: liquid, isLabelled: labelled)
            dispenser.position = position + SCNVector3(2 * (Double(index) - Double(liquids.count) / 2 + 0.5), 1.5, 0)
            scene.rootNode.addChildNode(dispenser)
        }
    }
    
    public func generateBubbleDispensers(at position: SCNVector3, labelled: Bool = true) {
        for (index, bubble) in bubbles.enumerated() {
            let dispenser = BubbleDispenserNode(bubbleType: bubble, isLabelled: labelled)
            dispenser.position = position + SCNVector3(Double(index) - Double(bubbles.count) / 2 + 0.5, 0.5, 0)
            scene.rootNode.addChildNode(dispenser)
        }
    }
    
    public func generateCupGenerator(at position: SCNVector3) {
        cupGenerator = CupGenerator()
        cupGenerator!.node.position = position + SCNVector3(0, 0.1, 0)
        scene.rootNode.addChildNode(cupGenerator!.node)
    }
    
    public func generateCupSubmitter(at position: SCNVector3) {
        cupSubmitter = CupSubmitter()
        cupSubmitter!.node.position = position + SCNVector3(0, 0.15, 0)
        scene.rootNode.addChildNode(cupSubmitter!.node)
    }
    
    public func generateCupTrash(at position: SCNVector3) {
        cupTrash = CupTrash()
        cupTrash!.node.position = position + SCNVector3(0, 0.01, 0)
        scene.rootNode.addChildNode(cupTrash!.node)
    }
}
