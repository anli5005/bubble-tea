import PlaygroundSupport
import SpriteKit
import SceneKit

// Load the SCNScene
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = SCNScene(named: "Test.scn")!
let manager = GameManager(view: sceneView)

sceneView.showsStatistics = true

// Present the scene
sceneView.present(scene, with: SKTransition(), incomingPointOfView: nil, completionHandler: nil)

let gestureRecognizer = NSPanGestureRecognizer(target: manager, action: #selector(GameManager.pan(sender:)))
sceneView.addGestureRecognizer(gestureRecognizer)

let cup = Cup()
cup.node.position.y = 10
scene.rootNode.addChildNode(cup.node)

let milk = LiquidType(color: .white)
let tea = LiquidType(color: CGColor(red: 0.5, green: 0.25, blue: 0, alpha: 0.95))
let water = LiquidType(color: CGColor(red: 0.8, green: 0.9, blue: 1, alpha: 0.5))
let sugar = LiquidType(color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.8))
let unicorn = LiquidType(color: CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0))
let red = LiquidType(color: CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
let yellow = LiquidType(color: CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))

cup.add(red, amount: 0.4)
cup.add(yellow, amount: 0.4)
cup.updateLiquidNode()

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
