import SceneKit

class CupSubmitter {
    private static let geometry = SCNCone(topRadius: 0.75, bottomRadius: 0.9, height: 0.3)
    private static let physicsShape = SCNPhysicsShape(geometry: SCNCylinder(radius: 0.9, height: 0.3), options: nil)
    
    public let node = SCNNode(geometry: CupSubmitter.geometry)
    
    public init() {
        node.geometry!.firstMaterial?.diffuse.contents = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: CupSubmitter.physicsShape)
    }
    
    public func cupOnNode(physicsWorld: SCNPhysicsWorld) -> CupNode? {
        return physicsWorld.rayTestWithSegment(from: node.position, to: node.position + SCNVector3(0, 0.3, 0), options: [.searchMode: SCNPhysicsWorld.TestSearchMode.all]).first(where: { $0.node is CupNode })?.node as? CupNode
    }
}
