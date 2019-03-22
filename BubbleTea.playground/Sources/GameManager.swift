import SceneKit
import SpriteKit

public protocol Movable {}
public class MovableNode: SCNNode, Movable {}

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
}

public class GameManager: NSObject, SCNSceneRendererDelegate {
    let sceneView: SCNView
    let overlayScene: SKScene
    let hudNode = SKNode()
    
    private var _level: Level?
    
    private var currentOrderIndex = 0
    private var orderQueue = [Order]()
    
    private var currentlyMoving: SCNNode?
    private var currentPhysicsBody: SCNPhysicsBody?
    private var lastFrame: TimeInterval?
    
    public var blendThreshold: CGFloat = 5500
    
    private var currentBubbleType: BubbleType?
    private let bubbleNodeZ: CGFloat = 0
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let delta = time - (lastFrame ?? time)
        
        renderer.scene?.rootNode.enumerateChildNodes { node, _ in
            if let dispenser = node as? DispenserNode {
                dispenser.runHitTest(in: renderer.scene!.physicsWorld, liquidToAdd: Double(delta * 0.25))
            }
        }
        
        renderer.scene?.rootNode.enumerateChildNodes { node, _ in
            if let cupNode = node as? CupNode {
                cupNode.update()
            }
        }
        
        if let level = _level {
            if Double.random(in: 0.0...(7.0 / level.orderFrequency)) < delta {
                currentOrderIndex += 1
                addOrder(Order(index: currentOrderIndex, randomWithPossibleLiquids: Set(level.liquids), maxLiquids: level.maxLiquidsPerOrder, needsShake: level.needsShake, bubbles: Set(level.bubbles), maxBubbles: level.maxBubblesPerOrder, deadline: time + TimeInterval.random(in: level.orderTimeRange)))
            }
        }
        
        orderQueue.removeAll(where: { order in
            if time > order.deadline {
                failOrder(order)
                return true
            }
            
            return false
        })
        
        lastFrame = time
    }
    
    private func addOrder(_ order: Order) {
        orderQueue.append(order)
    }
    
    private func failOrder(_ order: Order) {
        // TODO: Implement
    }
    
    @objc public func pan(sender: NSPanGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        if sender.state == .began {
            let hitTest = sceneView.hitTest(location, options: nil)
            let _ = hitTest.first(where: { result in
                let node = result.node
                
                var movable: SCNNode?
                
                var currentNode: SCNNode? = node
                
                while currentNode != nil {
                    if let bubbleBox = currentNode as? BubbleBoxNode {
                        let currentBubbleNode = MovableNode()
                        currentBubbleType = bubbleBox.bubbleType
                        currentBubbleNode.position = SCNVector3(bubbleBox.position.x, bubbleBox.position.y + 0.5, bubbleNodeZ)
                        
                        for _ in 1...10 {
                            let node = SCNNode(geometry: bubbleBox.bubbleType.geometry)
                            node.position = SCNVector3(Double.random(in: -0.3...0.3), Double.random(in: -0.3...0.3), Double.random(in: -0.3...0.3))
                            
                            let rotationRange = (-Double.pi)...Double.pi
                            node.eulerAngles = SCNVector3(Double.random(in: rotationRange), Double.random(in: rotationRange), Double.random(in: rotationRange))
                            
                            currentBubbleNode.addChildNode(node)
                        }
                        
                        sceneView.scene?.rootNode.addChildNode(currentBubbleNode)
                        
                        movable = currentBubbleNode
                        
                        break
                    }
                    if currentNode is Movable {
                        movable = currentNode
                        break
                    }
                    currentNode = currentNode?.parent
                }
                
                if let movable = movable {
                    currentlyMoving = movable
                    currentPhysicsBody = movable.physicsBody
                    movable.physicsBody = nil
                    print("Now moving \(movable)")
                    
                    return true
                }
                
                return false
            })
        }
        
        if let current = currentlyMoving {
            let z = sceneView.projectPoint(current.position).z
            var newPos = sceneView.unprojectPoint(SCNVector3(location.x, location.y, z))
            newPos.z = current.position.z
            current.position = newPos
            
            if let cupNode = current as? CupNode {
                let velocity = sender.velocity(in: sceneView)
                let scalarVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
                if scalarVelocity > blendThreshold {
                    cupNode.cup.blend()
                    cupNode.updateLiquidNode()
                }
            }
        }
        
        if sender.state != .began && sender.state != .changed {
            if let type = currentBubbleType {
                if let node = currentlyMoving {
                    let results = sceneView.scene?.physicsWorld.rayTestWithSegment(from: node.position + SCNVector3(0, 1, 0), to: node.position + SCNVector3(0, -2.5, 0), options: [.searchMode: SCNPhysicsWorld.TestSearchMode.all])
                    if let cupNode = results?.filter({$0.node is CupNode}).min(by: {$0.node.position |-| node.position > $1.node.position |-| node.position})?.node as? CupNode {
                        cupNode.cup.add(type, amount: 20)
                    }
                    
                    node.removeFromParentNode()
                }
            }
            
            currentlyMoving?.physicsBody = currentPhysicsBody
            currentlyMoving = nil
            currentPhysicsBody = nil
            currentBubbleType = nil
        }
    }
    
    public init(view: SCNView) {
        sceneView = view
        overlayScene = SKScene(size: view.frame.size)
        
        super.init()
        
        sceneView.rendersContinuously = true
        
        sceneView.delegate = self
        sceneView.overlaySKScene = overlayScene
        
        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(GameManager.pan(sender:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        hudNode.alpha = 0
        overlayScene.addChild(hudNode)
    }
    
    public func reset() {
        currentlyMoving = nil
        currentPhysicsBody = nil
        currentBubbleType = nil
        lastFrame = nil
        
        hudNode.alpha = 0
        
        sceneView.scene = nil
        _level = nil
        
        currentOrderIndex = 0
        orderQueue = [Order]()
    }
    
    public func loadLevel(_ level: Level) {
        reset()
        _level = level
        sceneView.present(level.scene, with: SKTransition.fade(with: .black, duration: 2), incomingPointOfView: nil, completionHandler: nil)
        
        if let name = level.name {
            let textNode = SKLabelNode(text: name)
            textNode.fontName = NSFont.systemFont(ofSize: textNode.fontSize, weight: .medium).fontName
            textNode.position = CGPoint.zero
            
            let rect = textNode.calculateAccumulatedFrame().insetBy(dx: -48, dy: -16)
            
            let titleBoxNode = SKShapeNode(rect: rect, cornerRadius: 16)
            titleBoxNode.fillColor = .black
            titleBoxNode.strokeColor = .clear
            titleBoxNode.position = CGPoint(x: overlayScene.size.width / 2, y: overlayScene.size.height / 2)
            titleBoxNode.yScale = 0
            titleBoxNode.addChild(textNode)
            
            titleBoxNode.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.scaleY(to: 1, duration: 0.2), SKAction.wait(forDuration: 1), SKAction.scaleY(to: 0, duration: 0.2), SKAction.removeFromParent()]))
                        
            overlayScene.addChild(titleBoxNode)
        }
        
        hudNode.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.fadeIn(withDuration: 1.0)]))
    }
}
