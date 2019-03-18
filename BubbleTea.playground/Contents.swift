//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import SceneKit

public class FoodType: Equatable {
    public static func ==(a: FoodType, b: FoodType) -> Bool {
        return a === b
    }
}

public class LiquidType: FoodType {
    public var name: String?
    public let color: CGColor
    public let viscosity: Double
    public let transparency: Double
    
    public init(color: CGColor, viscosity: Double = 0, transparency: Double = 0) {
        self.color = color
        self.viscosity = viscosity
        self.transparency = transparency
    }
}

public class BubbleType: FoodType {
    public var name: String?
}

public class Cup {
    static let cupGeometry: SCNGeometry = {
        let cylinder = SCNCylinder(radius: 0.6, height: 0.2)
        
        let glassMaterial = cylinder.firstMaterial!
        glassMaterial.transparent.contents = CGColor(gray: 0.0, alpha: 0.2)
        glassMaterial.diffuse.contents = CGColor.white
        
        let tube = SCNTube(innerRadius: 0.5, outerRadius: 0.6, height: 2)
        
        let node = SCNNode(geometry: cylinder)
        let tubeNode = SCNNode(geometry: tube)
        tubeNode.position.y = 1.1
        node.addChildNode(tubeNode)
        
        let geometry = node.flattenedClone().geometry!
        geometry.materials = [glassMaterial]
        
        return geometry
    }()
    
    public struct Liquid {
        let type: LiquidType
        var amount: Double
    }
    
    let node = SCNNode(geometry: nil)
    private let liquidNode = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 1.5))
    private var _liquids = [Liquid]()
    
    public var liquids: [Liquid] {
        return _liquids
    }
    
    public init() {
        let cupNode = SCNNode(geometry: Cup.cupGeometry)
        node.addChildNode(cupNode)
        
        liquidNode.geometry!.firstMaterial!.diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        
        let height = liquidNode.geometry!.boundingBox.max.y - liquidNode.geometry!.boundingBox.min.y
        liquidNode.position.y = height / 2 + 0.1
        node.addChildNode(liquidNode)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: Cup.cupGeometry, options: nil))
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = SCNScene(named: "Test.scn")!

sceneView.showsStatistics = true
    
// Present the scene
sceneView.present(scene, with: SKTransition(), incomingPointOfView: nil, completionHandler: nil)

let cup = Cup()
cup.node.position.y = 2.1
scene.rootNode.addChildNode(cup.node)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
