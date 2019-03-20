import PlaygroundSupport
import SpriteKit
import SceneKit

// Load the SCNScene
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = SCNScene(named: "Test.scn")!
let manager = GameManager(view: sceneView)

sceneView.rendersContinuously = true
sceneView.showsStatistics = true

// Present the scene
sceneView.present(scene, with: SKTransition(), incomingPointOfView: nil, completionHandler: nil)

let gestureRecognizer = NSPanGestureRecognizer(target: manager, action: #selector(GameManager.pan(sender:)))
sceneView.addGestureRecognizer(gestureRecognizer)

let milk = LiquidType(color: .white)
let tea = LiquidType(color: CGColor(red: 0.5, green: 0.25, blue: 0, alpha: 0.95))
let water = LiquidType(color: CGColor(red: 0.8, green: 0.9, blue: 1, alpha: 0.5))
let sugar = LiquidType(color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.8))
let unicorn = LiquidType(color: CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0))
let red = LiquidType(color: CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
let yellow = LiquidType(color: CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))

func addCup() {
    let cup = CupNode()
    cup.position.y = 10
    scene.rootNode.addChildNode(cup)
}

for _ in 1...15 {
    addCup()
}

let teaDispenser = DispenserNode(liquid: tea)
teaDispenser.position = SCNVector3(-1, 4, -2)
scene.rootNode.addChildNode(teaDispenser)

let milkDispenser = DispenserNode(liquid: milk)
milkDispenser.position = SCNVector3(1, 4, -2)
scene.rootNode.addChildNode(milkDispenser)

let purpleDispenser = DispenserNode(liquid: unicorn)
purpleDispenser.position = SCNVector3(-3, 4, -2)
scene.rootNode.addChildNode(purpleDispenser)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

