import SceneKit

public class BubbleBoxNode: SCNNode {
    static let boxMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.3, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    static let topMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.5, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    let bubbleType: BubbleType
    
    public override init() {
        bubbleType = BubbleType(geometry: SCNGeometry())
        
        super.init()
    }
    
    public init(bubbleType: BubbleType, isLabelled: Bool = true) {
        self.bubbleType = bubbleType
        
        super.init()
        
        let topMaterial = BubbleBoxNode.topMaterial.copy() as! SCNMaterial
        
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.materials = [SCNMaterial](repeating: BubbleBoxNode.boxMaterial, count: 6)
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
    
    public required init?(coder aDecoder: NSCoder) {
        bubbleType = BubbleType(geometry: SCNGeometry())
        
        super.init(coder: aDecoder)
    }
}
