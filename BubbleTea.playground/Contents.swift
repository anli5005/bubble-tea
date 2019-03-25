// HOW TO PLAY:
// 1. Start off by dragging and grabbing a cup, which should be on the left side of the level.
// 2. Look at the bottom. These are your pending orders, which you will have to make.
// 3. Dispense liquids. To do this, drag the cup under a dispenser and hold it until the desired amount of liquid is dispensed. Any proportion of liquid is fine as long as the cup is full. Don't worry about overfilling the cup - the dispenser will automatically stop when the cup is full.
// 4. Dispense bubbles. To do this, drag from a bubble dispenser to the top of the cup. Bubble dispensers are small cubes with the image of a bubble displayed on top.
// 5. Shake the cup if the order tells you to do so. To do this, drag the cup and move it quickly back and forth.
// 6. Submit the cup. Place it on the green pad, and select the order.

// If the playground does not work for some reason, try running it again.

import PlaygroundSupport
import SpriteKit
import SceneKit

// At this point, you may be wondering where each class is coming from. Since using complex data structures in playgrounds causes massive memory leaks (it was using 18 GB at one point, I have placed my classes in the Sources folder of this playground.
// To access it, open the Project Navigator, expand BubbleTea, and expand the Sources folder.
// Enjoy!

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
let manager = GameManager(view: sceneView)

let levels = [
    Level(scene: SCNScene(named: "Tutorial.scn")!, liquids: [tea, milk, sugar], maxLiquidsPerOrder: 2, bubbles: [tapioca, redBean], maxBubblesPerOrder: 1, orderFrequency: 1, orderTimeRange: 60.0...90.0, targetMoney: 5, timeLimit: 30, name: "Level 1"),
    Level(scene: SCNScene(named: "Level 1.scn")!, liquids: [tea, milk, sugar, strawberry, mango], maxLiquidsPerOrder: 3, bubbles: [tapioca, redBean], maxBubblesPerOrder: 1, orderFrequency: 2, orderTimeRange: 30.0...60.0, targetMoney: 20, timeLimit: 60, name: "Level 2"),
    Level(scene: SCNScene(named: "Level 2.scn")!, liquids: [tea, milk, sugar, strawberry, mango, banana, vanilla], maxLiquidsPerOrder: 4, bubbles: [tapioca, redBean, aloe], maxBubblesPerOrder: 3, orderFrequency: 3, orderTimeRange: 50.0...80.0, targetMoney: 40, timeLimit: 90, name: "Level 3")
]

levels.forEach { level in
    let rootNode = level.scene.rootNode
    level.generateLiquidDispensers(at: rootNode.childNode(withName: "liquiddispensers", recursively: false)!.position)
    level.generateBubbleDispensers(at: rootNode.childNode(withName: "bubbledispensers", recursively: false)!.position)
    level.generateCupGenerator(at: rootNode.childNode(withName: "cupgenerator", recursively: false)!.position)
    level.generateCupSubmitter(at: rootNode.childNode(withName: "cupsubmitter", recursively: false)!.position)
    level.generateCupTrash(at: rootNode.childNode(withName: "cuptrash", recursively: false)!.position)
}

manager.levels = levels
manager.loadLevel(levels[0])
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
