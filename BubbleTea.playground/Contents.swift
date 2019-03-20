import PlaygroundSupport
import SpriteKit
import SceneKit

// Load the SCNScene
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = SCNScene(named: "Test.scn")!
let manager = GameManager(view: sceneView)

sceneView.rendersContinuously = true
sceneView.showsStatistics = true
sceneView.allowsCameraControl = true

// Present the scene
sceneView.present(scene, with: SKTransition(), incomingPointOfView: nil, completionHandler: nil)

let gestureRecognizer = NSPanGestureRecognizer(target: manager, action: #selector(GameManager.pan(sender:)))
sceneView.addGestureRecognizer(gestureRecognizer)

let milk = LiquidType(color: .white)
let tea = LiquidType(color: CGColor(red: 0.5, green: 0.25, blue: 0, alpha: 0.95), image: NSImage(named: "Tea.png"))
let sugar = LiquidType(color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.8))
let vanilla = LiquidType(color: CGColor(red: 0.3, green: 0.15, blue: 0, alpha: 0.97))
let strawberry = LiquidType(color: CGColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0))
let mango = LiquidType(color: CGColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 1.0))
let banana = LiquidType(color: CGColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0))

func addCup() -> CupNode {
    let cup = CupNode()
    cup.position.y = 10
    scene.rootNode.addChildNode(cup)
    return cup
}

var pos = -6
for liquid in [strawberry, mango, banana, tea, milk, sugar, vanilla] {
    let dispenser = DispenserNode(liquid: liquid)
    dispenser.position = SCNVector3(pos, 2, -2)
    scene.rootNode.addChildNode(dispenser)
    pos += 2
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

let cupNode = addCup()

let tapioca = BubbleType(geometry: SCNSphere(radius: 0.1))
tapioca.geometry.firstMaterial!.diffuse.contents = CGColor.black

cupNode.cup.add(tapioca, amount: 20)

let redBean = BubbleType(geometry: SCNCapsule(capRadius: 0.02, height: 0.07))
redBean.geometry.firstMaterial!.diffuse.contents = CGColor(red: 0.3, green: 0, blue: 0, alpha: 1.0)

cupNode.cup.add(redBean, amount: 20)
