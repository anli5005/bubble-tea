import SceneKit

public class DispenserNode: MovableNode {
    public static let cylinderSideMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.2, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    public static let cylinderBaseMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor(gray: 0.5, alpha: 1.0)
        material.metalness.contents = 0.7
        material.roughness.contents = 0.5
        return material
    }()
    
    public static let blackMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = CGColor.black
        material.shininess = 0.7
        return material
    }()
    
    let liquid: LiquidType
    private let particleNode = SCNNode()
    
    public override init() {
        liquid = LiquidType(color: .clear)
        
        super.init()
    }
    
    public init(liquid: LiquidType, isLabelled: Bool = true) {
        self.liquid = liquid
        
        super.init()
        
        let sideMaterial = DispenserNode.cylinderSideMaterial.copy() as! SCNMaterial
        
        let cylinder = SCNCylinder(radius: 1, height: 3)
        cylinder.materials = [sideMaterial, DispenserNode.cylinderBaseMaterial, DispenserNode.cylinderBaseMaterial]
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
        pipe.materials = [DispenserNode.blackMaterial]
        let pipeNode = SCNNode(geometry: pipe)
        pipeNode.eulerAngles = SCNVector3Make(CGFloat.pi / 2, 0, 0)
        pipeNode.position = SCNVector3(0, -0.5, 1.2)
        addChildNode(pipeNode)
        
        let cone = SCNCone(topRadius: 0.2, bottomRadius: 0.1, height: 0.5)
        cone.materials = [DispenserNode.blackMaterial]
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, -0.55, 2)
        addChildNode(coneNode)
        
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        
        particleNode.position = SCNVector3(0, -1, 2)
        
        if let particleSystem = SCNParticleSystem(named: "Dispenser.scnp", inDirectory: nil) {
            particleSystem.particleColor = NSColor(cgColor: liquid.color)!
            particleNode.addParticleSystem(particleSystem)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        liquid = LiquidType(color: .clear)
        
        super.init(coder: aDecoder)
    }
    
    func runHitTest(in physicsWorld: SCNPhysicsWorld, liquidToAdd: Double) {
        let start = presentation.worldPosition + SCNVector3(0, -0.55, 2)
        let end = presentation.worldPosition + SCNVector3(0, -3, 2)
        
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
            let cupNode = result.node as! CupNode
            cupNode.cup.add(liquid, amount: liquidToAdd)
            cupNode.updateLiquidNode()
            if particleNode.parent == nil {
                addChildNode(particleNode)
            }
        } else {
            if particleNode.parent != nil {
                particleNode.removeFromParentNode()
            }
        }
    }
}
