import SceneKit

class CupGenerator {
    private static let geometry = SCNTube(innerRadius: 0, outerRadius: 0.9, height: 0.2)
    private static let physicsShape = SCNPhysicsShape(geometry: SCNCylinder(radius: 0.9, height: 0.2), options: nil)
    
    private var isGeneratingCup = false
    
    public let node = SCNNode(geometry: CupGenerator.geometry)
    
    public init() {
        node.geometry!.firstMaterial?.diffuse.contents = CGColor(gray: 0.5, alpha: 1.0)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: CupGenerator.physicsShape)
    }
    
    private func generateCup() {
        assert(node.parent != nil)
        if let parent = node.parent {
            print("Generating cup")
            isGeneratingCup = true
            
            let startAnimation = CABasicAnimation(keyPath: "geometry.innerRadius")
            startAnimation.fromValue = CGFloat(0.0)
            startAnimation.toValue = CGFloat(0.7)
            startAnimation.byValue = startAnimation.toValue
            startAnimation.duration = 1.0
            node.addAnimation(startAnimation, forKey: "cupGenerationStart")
            
            SCNTransaction.begin()
            
            let cupNode = CupNode()
            cupNode.position = node.position - SCNVector3(0, 3, 0)
            cupNode.movable = false
            
            let body = cupNode.physicsBody
            cupNode.physicsBody = nil
            
            parent.addChildNode(cupNode)
            let finalPosition = node.position + SCNVector3(0, 0.2, 0)
            
            let cupRiseAnimation = CABasicAnimation(keyPath: "position")
            cupRiseAnimation.fromValue = cupNode.position
            cupRiseAnimation.toValue = finalPosition
            cupRiseAnimation.duration = 0.5
            cupRiseAnimation.beginTime = CACurrentMediaTime() + 0.5
            cupNode.addAnimation(cupRiseAnimation, forKey: "cupGeneration")
            
            SCNTransaction.completionBlock = {
                cupNode.position = finalPosition
            }
            SCNTransaction.commit()
            
            SCNTransaction.begin()
            
            let endAnimation = CABasicAnimation(keyPath: "geometry.innerRadius")
            endAnimation.fromValue = CGFloat(0.7)
            endAnimation.toValue = CGFloat(0.0)
            endAnimation.duration = 0.5
            endAnimation.beginTime = CACurrentMediaTime() + 1.0
            node.addAnimation(endAnimation, forKey: "cupGenerationEnd")
            
            SCNTransaction.completionBlock = { [weak self] in
                self?.isGeneratingCup = false
                cupNode.physicsBody = body
                cupNode.movable = true
            }
            SCNTransaction.commit()
        }
    }
    
    public func update(physicsWorld: SCNPhysicsWorld) {
        if !isGeneratingCup {
            if let body = node.physicsBody {
                let contactResults = physicsWorld.contactTest(with: body, options: [.searchMode: SCNPhysicsWorld.TestSearchMode.all]).map({ result in
                    return result.nodeB === node ? result.nodeA : result.nodeB
                })
                if !contactResults.contains(where: {$0 is CupNode}) {
                    generateCup()
                }
            }
        }
    }
}
