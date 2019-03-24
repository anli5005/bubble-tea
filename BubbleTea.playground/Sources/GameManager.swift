import SceneKit
import SpriteKit

class OverlayScene: SKScene {
    internal weak var gameManager: GameManager?
    
    internal static let ordersNodeName = "orders"
    internal static let pauseNodeName = "pause"
    
    fileprivate var gameMenu: Menu?
    
    override func update(_ currentTime: TimeInterval) {
        childNode(withName: "hud")?.childNode(withName: OverlayScene.ordersNodeName)?.children.forEach { node in
            if let orderNode = node as? OrderNode {
                let order = orderNode.order
                let progress = ((gameManager?.timeElapsed ?? order.startTime) - order.startTime) / (order.endTime - order.startTime)
                orderNode.updateProgressBar(progress: min(max(1 - progress, 0.0), 1.0))
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let touchedNodes = nodes(at: event.location(in: self))
        
        if let menu = gameMenu {
            if touchedNodes.first(where: { menu.processClick(on: $0) }) != nil {
                return
            }
        }
        
        if gameManager?.isPaused == true {
        } else {
            if touchedNodes.contains(where: { $0.name == OverlayScene.pauseNodeName }) {
                gameMenu = Menu(levels: gameManager?.levels ?? [], gameManager: gameManager, type: .paused)
                gameMenu!.show(in: self)
                return
            }
            if let orderNode = touchedNodes.first(where: { $0 is OrderNode }) as? OrderNode {
                gameManager?.selectOrder(orderNode.order)
            }
        }
    }
}

public class GameManager: NSObject, SCNSceneRendererDelegate {
    let sceneView: SCNView
    let overlayScene: OverlayScene
    let hudNode = SKNode()
    
    public var isPaused = false {
        didSet {
            _level?.scene.isPaused = isPaused
            gestureRecognizer?.isEnabled = !isPaused
        }
    }
    
    private var _level: Level?
    public var currentLevel: Level? {
        return _level
    }
    
    public var levels = [Level]()
    
    private var currentOrderIndex = 0
    private var orderQueue = [Order]()
    public var currentOrders: [Order] {
        return orderQueue
    }
    
    private var currentlyMoving: Movable?
    private var lastFrame: TimeInterval?
    
    public var blendThreshold: CGFloat = 5500
    
    private var currentBubbleType: BubbleType?
    private let bubbleNodeZ: CGFloat = 0
    
    private let orderLimit = 5
    
    private let selectOrderPromptNode: SKShapeNode
    private var cupNodeToSubmit: CupNode?
    
    private let trashAlertNode: SKShapeNode
    private var trashCountdown: TimeInterval?
    
    private let moneyMeter: Meter
    private let reputationMeter: Meter
    private let timerMeter: Meter
    
    private let pauseNode = SKSpriteNode(imageNamed: "Pause.png")
    
    private var gestureRecognizer: NSGestureRecognizer?
    
    public var money = 0 {
        didSet {
            moneyMeter.updateValue(Double(money), duration: 0.3)
            if let level = _level {
                if level.timeLimit == nil {
                    if money >= level.targetMoney {
                        overlayScene.gameMenu = Menu(levels: levels, gameManager: self, type: money >= level.targetMoney ? .success : .failure)
                        overlayScene.gameMenu!.show(in: overlayScene)
                    }
                }
            }
        }
    }
    public var reputation = 3.0 {
        didSet {
            reputationMeter.updateValue(reputation, duration: 0.3)
        }
    }
    internal var timeElapsed: TimeInterval = 0 {
        didSet {
            if let limit = _level?.timeLimit {
                timerMeter.updateValue(max(limit - timeElapsed, 0))
            }
        }
    }
    
    private func calculateOrderPrice(for order: Order) -> Int {
        let base = Double(order.liquids.count) * 1.5 + Double(order.bubbles.count) * 0.5
        let multiplier = (reputation - 1) / 2
        return Int(round(base * multiplier))
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let delta = time - (lastFrame ?? time)
        
        if !isPaused {
            timeElapsed += delta

            renderer.scene?.rootNode.enumerateChildNodes { node, _ in
                if let dispenser = node as? LiquidDispenserNode {
                    dispenser.runHitTest(in: renderer.scene!.physicsWorld, liquidToAdd: Double(delta * 0.4))
                }
            }
            
            renderer.scene?.rootNode.enumerateChildNodes { node, _ in
                if let cupNode = node as? CupNode {
                    cupNode.update()
                }
            }
            
            if let level = _level {
                if orderQueue.count < orderLimit {
                    if Double.random(in: 0.0...(7.0 / level.orderFrequency)) < delta {
                        currentOrderIndex += 1
                        let order = Order(index: currentOrderIndex, randomWithPossibleLiquids: Set(level.liquids), maxLiquids: level.maxLiquidsPerOrder, needsShake: level.needsShake, bubbles: Set(level.bubbles), maxBubbles: level.maxBubblesPerOrder, timeLimit: level.orderTimeRange, startTime: timeElapsed, price: 0, reputation: 1)
                        order.price = calculateOrderPrice(for: order)
                        addOrder(order)
                    }
                }
                
                level.cupGenerator?.update(physicsWorld: level.scene.physicsWorld)
                
                if let cupNode = level.cupSubmitter?.cupOnNode(physicsWorld: level.scene.physicsWorld) {
                    if cupNodeToSubmit == nil {
                        selectOrderPromptNode.run(SKAction.moveTo(y: 0, duration: 0.3))
                    }
                    cupNodeToSubmit = cupNode
                } else {
                    if cupNodeToSubmit != nil {
                        selectOrderPromptNode.run(SKAction.moveTo(y: -selectOrderPromptNode.calculateAccumulatedFrame().height, duration: 0.3))
                    }
                    cupNodeToSubmit = nil
                }
                
                if let cupNode = level.cupTrash?.cupOnNode(physicsWorld: level.scene.physicsWorld) {
                    if trashCountdown == nil {
                        trashAlertNode.run(SKAction.fadeIn(withDuration: 0.4))
                        trashCountdown = 3
                    }
                    trashCountdown! -= delta
                    (trashAlertNode.childNode(withName: "countdown") as? SKLabelNode)?.text = String(max(Int(ceil(trashCountdown!)), 0))
                    let projected = sceneView.projectPoint(level.cupTrash!.node.position)
                    trashAlertNode.position = CGPoint(x: projected.x, y: projected.y)
                    
                    if trashCountdown! <= 0 {
                        cupNode.removeFromParentNode()
                    }
                } else {
                    if trashCountdown != nil {
                        trashAlertNode.run(SKAction.fadeOut(withDuration: 0.4))
                    }
                    trashCountdown = nil
                }
                
                if let limit = level.timeLimit {
                    if timeElapsed > limit {
                        overlayScene.gameMenu = Menu(levels: levels, gameManager: self, type: money >= level.targetMoney ? .success : .failure)
                        overlayScene.gameMenu!.show(in: overlayScene)
                    }
                }
            }
            
            orderQueue.removeAll(where: { order in
                if timeElapsed > order.endTime {
                    orderOverdue(order)
                    return true
                }
                
                return false
            })
        }
        
        lastFrame = time
    }
    
    private let orderContainer = SKNode()
    private var orderNodes = [OrderNode]()
    
    private func calculateOrderNodeX(index: Int) -> CGFloat {
        return CGFloat(index) * (OrderNode.width + 8.0) + 16.0
    }
    
    private func addOrder(_ order: Order) {
        orderQueue.append(order)
        
        let node = OrderNode(order: order)
        node.position = CGPoint(x: overlayScene.size.width, y: 16)
        node.run(SKAction.moveTo(x: calculateOrderNodeX(index: orderNodes.count), duration: 0.3))
        orderNodes.append(node)
        orderContainer.addChild(node)
    }
    
    private func updateOrderNodePositions() {
        for (index, node) in orderNodes.enumerated() {
            node.run(SKAction.moveTo(x: calculateOrderNodeX(index: index), duration: 0.4))
        }
    }
    
    private func orderOverdue(_ order: Order) {
        if let index = orderNodes.firstIndex(where: { $0.order === order }) {
            let node = orderNodes.remove(at: index)
            node.backgroundNode.fillColor = .red
            node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.removeFromParent()]))
            updateOrderNodePositions()
        }
        
        reputation = max(1, reputation - 0.5 * (_level?.reputationLossMultiplier ?? 1))
    }
    
    private func orderFailed(_ order: Order, reason: Order.CheckResult) {
        if let index = orderNodes.firstIndex(where: { $0.order === order }) {
            let node = orderNodes.remove(at: index)
            node.backgroundNode.fillColor = .yellow
            node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.removeFromParent()]))
            updateOrderNodePositions()
        }
        
        let reputationToLose: Double
        switch reason {
        case .needsShake:
            reputationToLose = 0.3
        case .excessiveShake:
            reputationToLose = 0.1
        case .notFull:
            reputationToLose = 0.4
        case .wrongLiquids(_, _):
            reputationToLose = 0.6
        case .wrongBubbles(_, _):
            reputationToLose = 0.5
        default:
            reputationToLose = 0.2
        }
        reputation = max(1, reputation - reputationToLose * (_level?.reputationLossMultiplier ?? 1))
        money += order.price
    }
    
    private func orderFulfilled(_ order: Order) {
        if let index = orderNodes.firstIndex(where: { $0.order === order }) {
            let node = orderNodes.remove(at: index)
            node.backgroundNode.fillColor = .green
            node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.removeFromParent()]))
            updateOrderNodePositions()
        }
        
        reputation = min(5, reputation + (_level?.reputationPerCorrectOrder ?? 0))
        money += order.price
    }
    
    internal func selectOrder(_ order: Order) {
        if let cupNode = cupNodeToSubmit {
            let _ = submit(cup: cupNode.cup, for: order)
            cupNode.physicsBody = nil
            cupNodeToSubmit = nil
            selectOrderPromptNode.run(SKAction.moveTo(y: -selectOrderPromptNode.calculateAccumulatedFrame().height, duration: 0.15))
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            cupNode.position.x = 20
            SCNTransaction.completionBlock = {
                cupNode.removeFromParentNode()
            }
            SCNTransaction.commit()
        }
    }
    
    public func submit(cup: Cup, for order: Order) -> Order.CheckResult {
        orderQueue.removeAll(where: {$0 === order})
        let result = order.check(cup: cup)
        result.isValid ? orderFulfilled(order) : orderFailed(order, reason: result)
        return result
    }
    
    @objc public func pan(sender: NSPanGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        if sender.state == .began {
            let hitTest = sceneView.hitTest(location, options: nil)
            let _ = hitTest.first(where: { result in
                let node = result.node
                
                var movable: Movable?
                
                var currentNode: SCNNode? = node
                
                while currentNode != nil {
                    if let bubbleBox = currentNode as? BubbleDispenserNode {
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
                    if let currentNodeAsMovable = currentNode as? Movable {
                        if currentNodeAsMovable.isMovable {
                            movable = currentNodeAsMovable
                            break
                        }
                    }
                    currentNode = currentNode?.parent
                }
                
                if let movable = movable {
                    currentlyMoving = movable
                    movable.startMoving()
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
            current.move(to: newPos)
            
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
                if let node = currentlyMoving as? SCNNode {
                    let results = sceneView.scene?.physicsWorld.rayTestWithSegment(from: node.position + SCNVector3(0, 1.5, 0), to: node.position + SCNVector3(0, -3, 0), options: [.searchMode: SCNPhysicsWorld.TestSearchMode.all])
                    if let cupNode = results?.filter({$0.node is CupNode}).min(by: {$0.node.position |-| node.position > $1.node.position |-| node.position})?.node as? CupNode {
                        cupNode.cup.add(type, amount: 20)
                    }
                    
                    node.removeFromParentNode()
                }
            }
            
            currentlyMoving?.endMoving()
            currentlyMoving = nil
            currentBubbleType = nil
        }
    }
    
    public init(view: SCNView) {
        sceneView = view
        overlayScene = OverlayScene(size: view.frame.size)
        selectOrderPromptNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: sceneView.bounds.width, height: 200))
        trashAlertNode = SKShapeNode(rect: CGRect(x: -40, y: -54, width: 80, height: 60), cornerRadius: 8)
        
        let reputationFormatter = NumberFormatter()
        reputationFormatter.minimumFractionDigits = 1
        reputationFormatter.maximumFractionDigits = 1
        reputationFormatter.roundingMode = .halfUp
        reputationFormatter.roundingIncrement = 0.1
        reputationMeter = Meter(size: CGSize(width: 192, height: 33), value: reputation, min: 1, max: 5, accentColor: NSColor(red: 0.76, green: 0.55, blue: 0.05, alpha: 1), image: NSImage(named: "Star.png")!, formatter: reputationFormatter)
        
        moneyMeter = Meter(size: CGSize(width: 192, height: 33), value: Double(money), min: 0, max: 1, accentColor: NSColor(red: 0, green: 0.6, blue: 0.1, alpha: 1), image: NSImage(named: "Money.png")!, showMaxAsText: true)
        
        timerMeter = Meter(size: CGSize(width: 192, height: 33), value: 0, min: 0, max: 1, accentColor: NSColor(red: 0.05, green: 0.35, blue: 0.9, alpha: 1), image: NSImage(named: "Timer.png")!)
        
        super.init()
        
        sceneView.rendersContinuously = true
        
        sceneView.delegate = self
        sceneView.overlaySKScene = overlayScene
        
        overlayScene.gameManager = self
        
        gestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(GameManager.pan(sender:)))
        sceneView.addGestureRecognizer(gestureRecognizer!)
        
        hudNode.alpha = 0
        hudNode.name = "hud"
        overlayScene.addChild(hudNode)
        
        selectOrderPromptNode.fillColor = .black
        selectOrderPromptNode.strokeColor = .clear
        selectOrderPromptNode.position.y = -selectOrderPromptNode.calculateAccumulatedFrame().height
        
        let promptLabelNode = SKLabelNode(text: "Select an order:")
        promptLabelNode.fontSize = 16
        promptLabelNode.fontName = NSFont.systemFont(ofSize: promptLabelNode.fontSize, weight: .medium).fontName
        promptLabelNode.fontColor = .white
        promptLabelNode.horizontalAlignmentMode = .center
        promptLabelNode.verticalAlignmentMode = .center
        promptLabelNode.position = CGPoint(x: sceneView.bounds.width / 2, y: 177)
        selectOrderPromptNode.addChild(promptLabelNode)
        
        hudNode.addChild(selectOrderPromptNode)
        
        orderContainer.name = OverlayScene.ordersNodeName
        hudNode.addChild(orderContainer)
        
        trashAlertNode.fillColor = .black
        trashAlertNode.strokeColor = .clear
        trashAlertNode.alpha = 0
        
        let trashAlertTitle = SKLabelNode(text: "TRASH")
        trashAlertTitle.fontSize = 13
        trashAlertTitle.fontName = NSFont.systemFont(ofSize: trashAlertTitle.fontSize, weight: .bold).fontName
        trashAlertTitle.position = CGPoint(x: 0, y: -2)
        trashAlertTitle.horizontalAlignmentMode = .center
        trashAlertTitle.verticalAlignmentMode = .top
        trashAlertNode.addChild(trashAlertTitle)
        
        let trashAlertCountdown = SKLabelNode(text: "?")
        trashAlertCountdown.fontSize = 36
        trashAlertCountdown.fontName = NSFont.systemFont(ofSize: trashAlertTitle.fontSize, weight: .medium).fontName
        trashAlertCountdown.position = CGPoint(x: 0, y: -48)
        trashAlertCountdown.horizontalAlignmentMode = .center
        trashAlertCountdown.verticalAlignmentMode = .bottom
        trashAlertCountdown.name = "countdown"
        trashAlertNode.addChild(trashAlertCountdown)
        
        hudNode.addChild(trashAlertNode)
        
        moneyMeter.node.position = CGPoint(x: 16, y: 431)
        reputationMeter.node.position = CGPoint(x: 224, y: 431)
        timerMeter.node.position = CGPoint(x: 432, y: 431)
        
        hudNode.addChild(moneyMeter.node)
        hudNode.addChild(reputationMeter.node)
        hudNode.addChild(timerMeter.node)
        
        pauseNode.name = OverlayScene.pauseNodeName
        pauseNode.scale(to: CGSize(width: 24, height: 24))
        pauseNode.position = CGPoint(x: 612, y: 28)
        hudNode.addChild(pauseNode)
    }
    
    public func reset() {
        currentlyMoving?.endMoving()
        currentlyMoving = nil
        currentBubbleType = nil
        lastFrame = nil
        
        hudNode.alpha = 0
        
        var toRemove = [SCNNode]()
        _level?.scene.rootNode.enumerateChildNodes({ node, _ in
            if node is CupNode {
                toRemove.append(node)
            }
        })
        
        toRemove.forEach { $0.removeFromParentNode() }
        
        sceneView.scene = nil
        _level = nil
        
        currentOrderIndex = 0
        orderQueue = [Order]()
        orderNodes.forEach { $0.removeFromParent() }
        orderNodes = [OrderNode]()
        
        cupNodeToSubmit = nil
        selectOrderPromptNode.position.y = -selectOrderPromptNode.calculateAccumulatedFrame().height
        
        money = 0
        reputation = 3.0
        timeElapsed = 0
        
        timerMeter.node.isHidden = true
        
        isPaused = false
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
        moneyMeter.maxValue = Double(level.targetMoney)
        moneyMeter.updateValue(Double(money))
        
        timeElapsed = 0
        
        if let limit = level.timeLimit {
            timerMeter.node.isHidden = false
            timerMeter.updateValue(limit - timeElapsed)
            timerMeter.maxValue = limit
        } else {
            timerMeter.node.isHidden = true
        }
        
        isPaused = false
    }
}
