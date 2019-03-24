import SpriteKit

public class Meter {
    public let node = SKNode()
    private let accentNode: SKShapeNode
    private let textNode: SKLabelNode
    private let textColor: NSColor
    private let showMaxAsText: Bool
    private let font = NSFont.systemFont(ofSize: 16, weight: .medium)
    public let formatter: NumberFormatter
    
    public var minValue: Double
    public var maxValue: Double
    
    public init(size: CGSize, value: Double = 0.0, min minValue: Double = 0.0, max maxValue: Double, backgroundColor: NSColor = .black, accentColor: NSColor, textColor: NSColor = .white, image: NSImage? = nil, showMaxAsText: Bool = false, formatter: NumberFormatter = NumberFormatter()) {
        self.minValue = minValue
        self.maxValue = maxValue
        
        let rect = CGRect(origin: CGPoint.zero, size: size)

        let backgroundNode = SKShapeNode(rect: rect)
        backgroundNode.fillColor = backgroundColor
        backgroundNode.strokeColor = .clear
        node.addChild(backgroundNode)
        
        accentNode = SKShapeNode(rect: rect)
        accentNode.fillColor = accentColor
        accentNode.strokeColor = .clear
        accentNode.xScale = 0
        node.addChild(accentNode)
        
        if let image = image {
            let spriteNode = SKSpriteNode(texture: SKTexture(image: image))
            spriteNode.scale(to: CGSize(width: size.height, height: size.height))
            spriteNode.position = CGPoint(x: size.height / 2, y: size.height / 2)
            node.addChild(spriteNode)
        }
        
        textNode = SKLabelNode()
        textNode.fontColor = textColor
        textNode.horizontalAlignmentMode = .left
        textNode.verticalAlignmentMode = .center
        textNode.position = CGPoint(x: (image != nil ? size.height : 0) + 8, y: size.height / 2)
        node.addChild(textNode)
        
        self.textColor = textColor
        self.formatter = formatter
        self.showMaxAsText = showMaxAsText
        
        updateValue(value)
    }
    
    public func updateValue(_ value: Double, duration: TimeInterval = 0) {
        accentNode.run(SKAction.scaleX(to: CGFloat(min(max((value - minValue) / (maxValue - minValue), 0.0), 1.0)), duration: duration))
        let attributedString = NSMutableAttributedString(string: formatter.string(from: NSNumber(value: value)) ?? "", attributes: [.foregroundColor: textColor, .font: font])
        if showMaxAsText {
            attributedString.append(NSAttributedString(string: "/" + (formatter.string(from: NSNumber(value: maxValue)) ?? ""), attributes: [.foregroundColor: textColor.withAlphaComponent(0.5), .font: font]))
        }
        textNode.attributedText = attributedString
    }
}
