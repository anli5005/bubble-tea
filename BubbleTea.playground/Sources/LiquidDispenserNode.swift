import SceneKit

public class LiquidDispenserNode: SCNNode {
    static let cylinderSideMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.6, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    static let cylinderBaseMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.8, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    static let blackMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor.black
        material.shininess = 0.7
        return material
    }()
    
    let liquid: LiquidType
    private let particleNode = SCNNode()
    
    // This initializer is never used, and only exists since a fatal error occurs if this is not present.
    public override init() {
        liquid = LiquidType(color: .clear)
        
        super.init()
    }
    
    public init(liquid: LiquidType, isLabelled: Bool = true) {
        self.liquid = liquid
        
        super.init()
        
        let sideMaterial = LiquidDispenserNode.cylinderSideMaterial.copy() as! SCNMaterial
        
        let cylinder = SCNCylinder(radius: 0.9, height: 3)
        cylinder.materials = [sideMaterial, LiquidDispenserNode.cylinderBaseMaterial, LiquidDispenserNode.cylinderBaseMaterial]
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.position = SCNVector3(0, 0, 0)
        addChildNode(cylinderNode)
        
        if isLabelled {
            if let image = liquid.image {
                let ctx = CGContext(data: nil, width: Int(cylinder.radius * 2 * CGFloat.pi * 512 / cylinder.height), height: 512, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
                if let context = ctx {
                    context.setFillColor(CGColor(gray: 0.2, alpha: 1.0))
                    context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
                    
                    let rect = CGRect(origin: CGPoint(x: (CGFloat(context.width) - image.size.width) / 2, y: (CGFloat(context.height) - image.size.height)), size: image.size)
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        context.draw(cgImage, in: rect)
                    }
                    
                    if let finalImage = context.makeImage() {
                        sideMaterial.diffuse.contents = finalImage
                    }
                }
            }
        }
        
        let pipe = SCNCylinder(radius: 0.1, height: 1.5)
        pipe.materials = [LiquidDispenserNode.blackMaterial]
        let pipeNode = SCNNode(geometry: pipe)
        pipeNode.eulerAngles = SCNVector3Make(CGFloat.pi / 2, 0, 0)
        pipeNode.position = SCNVector3(0, -0.5, 1.2)
        addChildNode(pipeNode)
        
        let cone = SCNCone(topRadius: 0.2, bottomRadius: 0.1, height: 0.5)
        cone.materials = [LiquidDispenserNode.blackMaterial]
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, -0.55, 2)
        addChildNode(coneNode)
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        physicsBody!.rollingFriction = 1
        physicsBody!.friction = 0.5
        
        particleNode.position = SCNVector3(0, -1, 2)
        
        if let particleSystem = SCNParticleSystem(named: "Dispenser.scnp", inDirectory: nil) {
            particleSystem.particleColor = NSColor(cgColor: liquid.color)!
            particleNode.addParticleSystem(particleSystem)
        }
    }
    
    // I don't use instances of NSCoder in this playground, and so I've simply added a stub initializer to satisfy the init(coder:) requirement. However, if I were to continue development on this project, I would look into making each of my nodes encodable and decodable with an NSCoder.
    public required init?(coder aDecoder: NSCoder) {
        liquid = LiquidType(color: .clear)
        
        super.init(coder: aDecoder)
    }
    
    private var liquidAdded = 0.0
    private let liquidAddDelay = 0.1
    func runHitTest(in physicsWorld: SCNPhysicsWorld, liquidToAdd: Double) {
        let start = presentation.worldPosition + SCNVector3(0, 1, 2)
        let end = presentation.worldPosition + SCNVector3(0, -1, 2)
        
        let results = physicsWorld.rayTestWithSegment(from: start, to: end, options: [.searchMode: SCNPhysicsWorld.TestSearchMode.closest])
        if let result = results.first(where: { result in
            var currentNode: SCNNode? = result.node
            
            for _ in 1...2 {
                if let cup = (currentNode as? CupNode)?.cup {
                    if cup.totalLiquid < 1.0 {
                        return true
                    }
                }
                currentNode = currentNode?.parent
            }
            
            return false
        }) {
            liquidAdded += liquidToAdd
            if liquidAdded > liquidAddDelay {
                let cupNode = result.node as! CupNode
                cupNode.cup.add(liquid, amount: liquidToAdd)
                if particleNode.parent == nil {
                    addChildNode(particleNode)
                }
            }
        } else {
            liquidAdded = 0
            if particleNode.parent != nil {
                particleNode.removeFromParentNode()
            }
        }
    }
}
