import SceneKit

extension SCNVector3 {
    static func + (a: SCNVector3, b: SCNVector3) -> SCNVector3 {
        return SCNVector3(a.x + b.x, a.y + b.y, a.z + b.z)
    }
}
