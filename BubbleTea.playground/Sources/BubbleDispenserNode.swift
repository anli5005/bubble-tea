import SceneKit

/// Node from which bubbles (drink toppings) are dispensed.
public class BubbleDispenserNode: SCNNode {
    /// Material for the sides and bottom of bubble dispensers.
    static let boxMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.3, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    /// Initial material for the top of bubble dispensers.
    static let topMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.5, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    /// The type of bubble dispensed by this bubble dispenser.
    let bubbleType: BubbleType
    
    // This initializer is never used, and only exists since a fatal error occurs if this is not present.
    public override init() {
        bubbleType = BubbleType(geometry: SCNGeometry())
        
        super.init()
    }
    
    /// Initializes a bubble dispenser with a given bubble type.
    ///
    /// - Parameters:
    ///   - bubbleType: Type of bubble to dispense.
    ///   - isLabelled: Whether the dispenser should be labelled with an image and/or a tooltip.
    public init(bubbleType: BubbleType, isLabelled: Bool = true) {
        self.bubbleType = bubbleType
        
        super.init()
        
        let topMaterial = BubbleDispenserNode.topMaterial.copy() as! SCNMaterial
        
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.materials = [SCNMaterial](repeating: BubbleDispenserNode.boxMaterial, count: 6)
        box.materials[4] = topMaterial
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0, 0, 0)
        addChildNode(boxNode)
        
        if isLabelled {
            if let image = bubbleType.image {
                let ctx = CGContext(data: nil, width: 512, height: 512, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
                if let context = ctx {
                    context.setFillColor(CGColor(gray: 0.5, alpha: 1.0))
                    context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
                    
                    let rect = CGRect(origin: CGPoint(x: (CGFloat(context.width) - image.size.width) / 2, y: (CGFloat(context.height) - image.size.height) / 2), size: image.size)
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        context.draw(cgImage, in: rect)
                    }
                    
                    if let finalImage = context.makeImage() {
                        topMaterial.diffuse.contents = finalImage
                    }
                }
            }
        }
        
        let shape = SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0), options: nil)
        physicsBody = SCNPhysicsBody(type: .static, shape: shape)
    }
    
    // I don't use instances of NSCoder in this playground, and so I've simply added a stub initializer to satisfy the init(coder:) requirement. However, if I were to continue development on this project, I would look into making each of my nodes encodable and decodable with an NSCoder.
    public required init?(coder aDecoder: NSCoder) {
        bubbleType = BubbleType(geometry: SCNGeometry())
        
        super.init(coder: aDecoder)
    }
}
