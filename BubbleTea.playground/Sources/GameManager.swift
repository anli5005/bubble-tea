import SceneKit

public protocol Movable {}
public class MovableNode: SCNNode, Movable {}

public class GameManager {
    let sceneView: SCNView
    private var currentlyMoving: SCNNode?
    private var currentPhysicsBody: SCNPhysicsBody?
    
    public var blendThreshold: CGFloat = 8000
    
    @objc public func pan(sender: NSPanGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        if sender.state == .began {
            let hitTest = sceneView.hitTest(location, options: nil)
            let _ = hitTest.first(where: { result in
                let node = result.node
                
                var movable: SCNNode?
                
                var currentNode: SCNNode? = node
                
                while currentNode != nil {
                    if currentNode is Movable {
                        movable = currentNode
                        break
                    }
                    currentNode = currentNode!.parent
                }
                
                if let movable = movable {
                    currentlyMoving = movable
                    currentPhysicsBody = movable.physicsBody
                    movable.physicsBody = nil
                    print("Now moving \(movable)")
                    
                    return true
                }
                
                return false
            })
        }
        
        if let current = currentlyMoving {
            let z = sceneView.projectPoint(current.position).z
            var newPos = sceneView.unprojectPoint(SCNVector3(location.x, location.y, z))
            newPos.z = current.position.z
            current.position = newPos
            
            if let cup = (current as? Cup.Node)?.cup {
                let velocity = sender.velocity(in: sceneView)
                if sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) > blendThreshold {
                    cup.blend()
                    cup.updateLiquidNode()
                }
            }
        }
        
        if sender.state != .began && sender.state != .changed {
            currentlyMoving?.physicsBody = currentPhysicsBody
            currentlyMoving = nil
            currentPhysicsBody = nil
        }
    }
    
    public init(view: SCNView) {
        sceneView = view
    }
}
