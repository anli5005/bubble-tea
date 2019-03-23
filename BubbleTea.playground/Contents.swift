import PlaygroundSupport
import SpriteKit
import SceneKit

let tea = LiquidType(name: "Tea", color: CGColor(red: 0.5, green: 0.25, blue: 0, alpha: 0.95), image: NSImage(named: "Tea.png"))
let milk = LiquidType(name: "Milk", color: .white, image: NSImage(named: "Milk.png"))
let sugar = LiquidType(name: "Sugar Water", color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.8), image: NSImage(named: "Sugar.png"))
let vanilla = LiquidType(name: "Vanilla Extract", color: CGColor(red: 0.3, green: 0.15, blue: 0, alpha: 0.97), image: NSImage(named: "Vanilla.png"))
let strawberry = LiquidType(name: "Strawberry Juice", color: CGColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0), image: NSImage(named: "Strawberry.png"))
let mango = LiquidType(name: "Mango Juice", color: CGColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 1.0), image: NSImage(named: "Mango.png"))
let banana = LiquidType(name: "Banana Slush", color: CGColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0), image: NSImage(named: "Banana.png"))

let tapioca = BubbleType(geometry: SCNSphere(radius: 0.1), image: NSImage(named: "Tapioca.png"))
tapioca.geometry.firstMaterial!.diffuse.contents = CGColor.black

let redBean = BubbleType(geometry: SCNCapsule(capRadius: 0.02, height: 0.07), image: NSImage(named: "Red Bean.png"))
redBean.geometry.firstMaterial!.diffuse.contents = CGColor(red: 0.3, green: 0, blue: 0, alpha: 1.0)

let aloe = BubbleType(geometry: SCNBox(width: 0.2, height: 0.05, length: 0.05, chamferRadius: 0), image: NSImage(named: "Aloe.png"))
aloe.geometry.firstMaterial!.diffuse.contents = CGColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
aloe.geometry.firstMaterial!.transparent.contents = CGColor(gray: 1.0, alpha: 0.6)

// Load the SCNScene
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = SCNScene(named: "Test.scn")!
let manager = GameManager(view: sceneView)

sceneView.showsStatistics = true

let level = Level(scene: scene, liquids: [tea, milk, sugar, vanilla, strawberry, mango, banana], maxLiquidsPerOrder: 4, bubbles: [tapioca, redBean, aloe], maxBubblesPerOrder: 3, orderFrequency: 5, orderTimeRange: 60.0...90.0, name: "Test Level")
level.generateLiquidDispensers(at: scene.rootNode.childNode(withName: "liquiddispensers", recursively: false)!.position)
level.generateBubbleDispensers(at: scene.rootNode.childNode(withName: "bubbledispensers", recursively: false)!.position)
level.generateCupGenerator(at: scene.rootNode.childNode(withName: "cupgenerator", recursively: false)!.position)
level.generateCupSubmitter(at: scene.rootNode.childNode(withName: "cupsubmitter", recursively: false)!.position)
manager.loadLevel(level)
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
