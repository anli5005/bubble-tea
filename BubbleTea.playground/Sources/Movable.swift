import SceneKit

public protocol Movable {
    var isMovable: Bool { get }
    var position: SCNVector3 { get }
    func move(to: SCNVector3)
    func startMoving()
    func endMoving()
}

public class MovableNode: SCNNode, Movable {
    private var lastPhysicsBodyType: SCNPhysicsBodyType?
    
    public var isMovable: Bool {
        return true
    }
    
    public func move(to pos: SCNVector3) {
        position = pos
    }
    
    public func startMoving() {
        lastPhysicsBodyType = physicsBody?.type
        physicsBody?.type = .static
    }
    
    public func endMoving() {
        if let type = lastPhysicsBodyType {
            physicsBody?.type = type
        }
        lastPhysicsBodyType = nil
    }
}
