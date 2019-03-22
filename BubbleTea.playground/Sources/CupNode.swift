import SceneKit

public class CupNode: MovableNode {
    static let cupGeometry: SCNGeometry = {
        let cylinder = SCNCylinder(radius: 0.6, height: 0.2)
        
        let glassMaterial = cylinder.firstMaterial!
        glassMaterial.transparent.contents = CGColor(gray: 0.0, alpha: 0.1)
        glassMaterial.diffuse.contents = CGColor.white
        glassMaterial.lightingModel = SCNMaterial.LightingModel.constant
        
        let tube = SCNTube(innerRadius: 0.52, outerRadius: 0.6, height: 2)
        
        let node = SCNNode(geometry: cylinder)
        let tubeNode = SCNNode(geometry: tube)
        tubeNode.position.y = 1.1
        node.addChildNode(tubeNode)
        
        let geometry = node.flattenedClone().geometry!
        geometry.materials = [glassMaterial]
        
        return geometry
    }()
    
    public let cup: Cup
    
    private let liquidNode = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 0))
    private var lastLiquid: CGColor? = nil
    
    public func updateLiquidNode() {
        let total = cup.liquids.reduce(0.0) { $0 + $1.amount }
        let height = total * 1.9
        (liquidNode.geometry as? SCNCylinder)?.height = CGFloat(height)
        liquidNode.position.y = CGFloat(height) / 2 + 0.12
        liquidNode.isHidden = height <= 0
        
        let gradientMaterial = liquidNode.geometry!.materials[0]
        if cup.liquids.count != 1 || lastLiquid != cup.liquids.first?.color {
            let gradientContext = CGContext(data: nil, width: 512, height: 512, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            let colors = cup.liquids.map { $0.color }
            let locations = cup.liquids.reduce([Double](), { locations, liquid in
                let location = (locations.last ?? 0.0) + liquid.amount
                return locations + [min(location / total, 1.0)]
            }).map({ CGFloat($0) })
            
            gradientContext!.clear(CGRect(x: 0, y: 0, width: 512, height: 512))
            if let gradient = CGGradient(colorsSpace: gradientContext!.colorSpace!, colors: colors as CFArray, locations: locations) {
                gradientContext?.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: 512), options: [])
            }
            
            let image = gradientContext!.makeImage()!
            gradientMaterial.diffuse.contents = image
            gradientMaterial.transparent.contents = image
        }
        
        let topMaterial = liquidNode.geometry!.materials[1]
        let topColor = cup.liquids.last?.color ?? CGColor.clear
        topMaterial.diffuse.contents = topColor
        topMaterial.transparent.contents = topColor
        
        let bottomMaterial = liquidNode.geometry!.materials[2]
        let bottomColor = cup.liquids.first?.color ?? CGColor.clear
        bottomMaterial.diffuse.contents = bottomColor
        bottomMaterial.transparent.contents = bottomColor
        
        lastLiquid = cup.liquids.count == 1 ? cup.liquids[0].color : nil
        cup.liquidsUpdated = false
    }
    
    private let bubbleNode = SCNNode()
    private var bubblesAdded = [BubbleType: Int]()
    
    public func updateBubbleNode() {
        cup.bubbles.forEach { pair in
            let toAdd = pair.value - (bubblesAdded[pair.key] ?? 0)
            for _ in 0..<toAdd {
                let node = SCNNode(geometry: pair.key.geometry)
                let x = Double.random(in: -0.49...0.49)
                
                let z = sqrt(pow(0.49, 2) - pow(x, 2)) * (Bool.random() ? 1 : -1)
                
                node.position = SCNVector3(x, Double.random(in: 0.2...1.2), z)
                
                let rotationRange = (-Double.pi)...Double.pi
                node.eulerAngles = SCNVector3(Double.random(in: rotationRange), Double.random(in: rotationRange), Double.random(in: rotationRange))
                
                bubbleNode.addChildNode(node)
            }
        }
        
        bubblesAdded = cup.bubbles
        cup.bubblesUpdated = false
    }
    
    public func update() {
        if cup.liquidsUpdated {
            updateLiquidNode()
        }
        
        if cup.bubblesUpdated {
            updateBubbleNode()
        }
    }
    
    public override convenience init() {
        self.init(cup: Cup())
    }
    
    public init(cup: Cup) {
        self.cup = cup
        super.init()
        
        let cupNode = SCNNode(geometry: CupNode.cupGeometry)
        addChildNode(cupNode)
        
        liquidNode.geometry!.materials = [SCNMaterial(), SCNMaterial(), SCNMaterial()]
        
        addChildNode(liquidNode)
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: CupNode.cupGeometry, options: nil))
        
        addChildNode(bubbleNode)
        
        cupNode.renderingOrder = 1
        
        updateLiquidNode()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        cup = Cup()
        super.init(coder: aDecoder)
    }
}
