import SpriteKit

class OrderNode: SKShapeNode {
    let order: Order
    let backgroundNode: SKShapeNode
    
    private let progressNode = SKShapeNode()
    private let progressWidth: CGFloat = 92
    private let progressHeight: CGFloat = 16
    
    static let width: CGFloat = 108
    
    public init(order: Order) {
        self.order = order
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: OrderNode.width, height: 140))
        
        super.init()
        
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        let effectNodeChild = SKShapeNode(path: backgroundNode.path!)
        effectNodeChild.fillColor = .black
        effectNodeChild.strokeColor = .clear
        effectNode.addChild(effectNodeChild)
        addChild(effectNode)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 4])!
        
        backgroundNode.fillColor = .white
        backgroundNode.strokeColor = .clear
        addChild(backgroundNode)
        
        if let index = order.index {
            let textNode = SKLabelNode(text: String(format: "%02d", index))
            textNode.fontSize = 18
            textNode.fontName = "Menlo Bold"
            textNode.fontColor = NSColor(white: 0, alpha: 0.7)
            textNode.horizontalAlignmentMode = .left
            textNode.verticalAlignmentMode = .bottom
            textNode.position = CGPoint(x: 4, y: 120)
            addChild(textNode)
        }
        
        let priceNode = SKLabelNode(text: "$\(order.price)")
        priceNode.fontSize = 14
        priceNode.fontName = "Menlo"
        priceNode.fontColor = NSColor(red: 0, green: 0.5, blue: 0, alpha: 1)
        priceNode.horizontalAlignmentMode = .right
        priceNode.verticalAlignmentMode = .bottom
        priceNode.position = CGPoint(x: OrderNode.width - 4, y: 120)
        addChild(priceNode)
        
        for (index, liquid) in order.liquids.enumerated() {
            let liquidNode = SKSpriteNode(texture: liquid.image != nil ? SKTexture(image: liquid.image!) : nil)
            liquidNode.scale(to: CGSize(width: 25, height: 25))
            liquidNode.position = CGPoint(x: index * 25 + 16, y: 100)
            addChild(liquidNode)
        }
        
        let fontSize: CGFloat = 12
        let shakeNode = SKLabelNode(fontNamed: NSFont.systemFont(ofSize: fontSize, weight: .medium).fontName)
        shakeNode.fontSize = fontSize
        if order.needsShake {
            shakeNode.text = "Shake"
            shakeNode.fontColor = NSColor(red: 0, green: 0.4, blue: 0, alpha: 1)
        } else {
            shakeNode.text = "Don't shake"
            shakeNode.fontColor = NSColor(red: 0.4, green: 0, blue: 0, alpha: 1)
        }
        shakeNode.horizontalAlignmentMode = .left
        shakeNode.verticalAlignmentMode = .center
        shakeNode.position = CGPoint(x: 4, y: 76)
        addChild(shakeNode)
        
        for (index, bubble) in order.bubbles.enumerated() {
            let bubbleNode = SKSpriteNode(texture: bubble.image != nil ? SKTexture(image: bubble.image!) : nil)
            bubbleNode.scale(to: CGSize(width: 25, height: 25))
            bubbleNode.position = CGPoint(x: index * 25 + 16, y: 52)
            addChild(bubbleNode)
        }
        
        let progressBackgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: progressWidth, height: progressHeight), cornerRadius: progressHeight / 2)
        progressBackgroundNode.fillColor = NSColor(white: 0, alpha: 0.2)
        progressBackgroundNode.strokeColor = .clear
        progressBackgroundNode.position = CGPoint(x: (OrderNode.width - progressWidth) / 2, y: 12)
        progressNode.strokeColor = .clear
        progressBackgroundNode.addChild(progressNode)
        addChild(progressBackgroundNode)
        
        updateProgressBar(progress: 0)
    }
    
    // I don't use instances of NSCoder in this playground, and so I've simply added a stub initializer to satisfy the init(coder:) requirement. However, if I were to continue development on this project, I would look into making each of my nodes encodable and decodable with an NSCoder.
    public required init?(coder aDecoder: NSCoder) {
        order = Order(liquids: [], needsShake: false, bubbles: [], startTime: 0, endTime: 0, price: 0, reputation: 0)
        backgroundNode = SKShapeNode()
        super.init(coder: aDecoder)
    }
    
    func updateProgressBar(progress: Double) {
        let adjustedProgress = progress * 0.85 + 0.15
        progressNode.path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: CGFloat(adjustedProgress) * progressWidth, height: progressHeight), cornerWidth: progressHeight / 2, cornerHeight: progressHeight / 2, transform: nil)
        progressNode.fillColor = NSColor(hue: CGFloat(progress) * 0.4, saturation: 1, brightness: 1, alpha: 1)
    }
}
