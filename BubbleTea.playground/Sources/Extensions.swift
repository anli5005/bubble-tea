import SceneKit

infix operator |-|: AdditionPrecedence

extension SCNVector3 {
    static func + (a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        return SCNVector3(a.x + b.x, a.y + b.y, a.z + b.z)
    }
    
    static func - (a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        return SCNVector3(a.x - b.x, a.y - b.y, a.z - b.z)
    }
    
    static func |-| (a: SCNVector3, b: SCNVector3) -> CGFloat {
        let diff = a - b
        return sqrt(pow(diff.x, 2) + pow(diff.y, 2) + pow(diff.z, 2))
    }
}
