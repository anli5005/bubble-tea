import SceneKit

class CupTrash {
    private static let geometry = SCNCylinder(radius: 0.9, height: 0)
    
    let node = SCNNode(geometry: CupTrash.geometry)
    
    public init() {
        node.geometry!.firstMaterial?.diffuse.contents = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    public func cupOnNode(physicsWorld: SCNPhysicsWorld) -> CupNode? {
        return physicsWorld.rayTestWithSegment(from: node.position - SCNVector3(0, 0.1, 0), to: node.position + SCNVector3(0, 0.3, 0), options: [.searchMode: SCNPhysicsWorld.TestSearchMode.all]).first(where: { $0.node is CupNode })?.node as? CupNode
    }
}
