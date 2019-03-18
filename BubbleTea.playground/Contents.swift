//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import SceneKit

public class FoodType: Hashable {
    public static func ==(a: FoodType, b: FoodType) -> Bool {
        return a === b
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public class LiquidType: FoodType {
    public var name: String?
    public let color: CGColor
    public let viscosity: Double
    
    public init(color: CGColor, viscosity: Double = 0) {
        self.color = color
        self.viscosity = viscosity
    }
}

public class BubbleType: FoodType {
    public var name: String?
}

public class Cup {
    static let cupGeometry: SCNGeometry = {
        let cylinder = SCNCylinder(radius: 0.6, height: 0.2)
        
        let glassMaterial = cylinder.firstMaterial!
        glassMaterial.transparent.contents = CGColor(gray: 0.0, alpha: 0.1)
        glassMaterial.diffuse.contents = CGColor.white
        glassMaterial.lightingModel = SCNMaterial.LightingModel.constant
        
        let tube = SCNTube(innerRadius: 0.52, outerRadius: 0.6, height: 2)
        
        let node = SCNNode(geometry: cylinder)
        let tubeNode = SCNNode(geometry: tube)
        tubeNode.position.y = 1.1
        node.addChildNode(tubeNode)
        
        let geometry = node.flattenedClone().geometry!
        geometry.materials = [glassMaterial]
        
        return geometry
    }()
    
    public struct Liquid {
        let types: [LiquidType: Double]
        var amount: Double
        let color: CGColor
        
        var type: LiquidType? {
            return types.count == 1 ? types.keys.first! : nil
        }
        
        init(type: LiquidType, amount: Double) {
            self.init(types: [type: 1.0], amount: amount)
        }
        
        init(types: [LiquidType: Double], amount: Double) {
            self.types = types
            self.amount = amount
            
            if self.types.count == 1 {
                color = types.keys.first!.color
            } else {
                var components = [CGFloat](repeating: 0.0, count: 4)
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let colors = types.map { pair in
                    return (key: pair.key, value: pair.value, color: pair.key.color.converted(to: colorSpace, intent: .defaultIntent, options: nil)!)
                }
                for i in 0..<4 {
                    let total = colors.reduce(0.0, { $0 + $1.value })
                    let sumOfSquares = colors.reduce(0.0, { pow(Double($1.color.components![i]), 2) * $1.value + $0 })
                    let result = min(max(sqrt(sumOfSquares / total), 0.0), 1.0)
                    components[i] = CGFloat(result)
                }
                
                color = CGColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
            }
        }
        
        public static func blend(_ liquids: [Liquid]) -> Liquid {
            let total = liquids.reduce(0.0) { $0 + $1.amount }
            var types = [LiquidType: Double]()
            
            liquids.forEach { liquid in
                let liquidTotal = liquid.types.reduce(0.0) { $0 + $1.value }
                liquid.types.forEach { type in
                    let toAdd = (type.value / liquidTotal) * liquid.amount
                    types[type.key] = (types[type.key] ?? 0) + toAdd
                }
            }
            
            return Liquid(types: types, amount: total)
        }
    }
    
    let node = SCNNode(geometry: nil)
    private let liquidNode = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 0))
    
    private var _liquids = [Liquid]()
    public var liquids: [Liquid] {
        return _liquids
    }
    
    private var _needsLiquidNodeUpdate = false
    var needsLiquidNodeUpdate: Bool {
        return _needsLiquidNodeUpdate
    }
    
    private let gradientContext = CGContext(data: nil, width: 512, height: 512, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    func updateLiquidNode() {
        let total = liquids.reduce(0.0) { $0 + $1.amount }
        let height = total * 1.9
        (liquidNode.geometry as? SCNCylinder)?.height = CGFloat(height)
        liquidNode.position.y = CGFloat(height) / 2 + 0.12
        liquidNode.isHidden = height <= 0
        
        let gradientMaterial = liquidNode.geometry!.materials[0]
        
        let colors = liquids.map { $0.color }
        let locations = liquids.reduce([Double](), { locations, liquid in
            let location = (locations.last ?? 0.0) + liquid.amount
            return locations + [min(location / total, 1.0)]
        }).map({ CGFloat($0) })
        
        gradientContext!.clear(CGRect(x: 0, y: 0, width: 512, height: 512))
        if let gradient = CGGradient(colorsSpace: gradientContext!.colorSpace!, colors: colors as CFArray, locations: locations) {
            gradientContext?.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: 512), options: [])
        }
        
        let image = gradientContext!.makeImage()!
        gradientMaterial.diffuse.contents = image
        gradientMaterial.transparent.contents = image
        
        let topMaterial = liquidNode.geometry!.materials[1]
        let topColor = liquids.last?.color ?? CGColor.clear
        topMaterial.diffuse.contents = topColor
        topMaterial.transparent.contents = topColor
        
        let bottomMaterial = liquidNode.geometry!.materials[2]
        let bottomColor = liquids.first?.color ?? CGColor.clear
        bottomMaterial.diffuse.contents = bottomColor
        bottomMaterial.transparent.contents = bottomColor
        
        _needsLiquidNodeUpdate = false
    }
    
    public init() {
        let cupNode = SCNNode(geometry: Cup.cupGeometry)
        node.addChildNode(cupNode)
        
        liquidNode.geometry!.materials = [SCNMaterial(), SCNMaterial(), SCNMaterial()]
        
        node.addChildNode(liquidNode)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: Cup.cupGeometry, options: nil))
        
        cupNode.renderingOrder = 1
        
        updateLiquidNode()
    }
    
    public func add(_ liquid: LiquidType, amount: Double) {
        if liquids.last?.type == liquid {
            _liquids[liquids.count - 1].amount += amount
        } else {
            _liquids.append(Liquid(type: liquid, amount: amount))
        }
        
        _needsLiquidNodeUpdate = true
    }
    
    public func add(_ types: [LiquidType: Double], amount: Double) {
        if liquids.last?.types == types {
            _liquids[liquids.count - 1].amount += amount
        } else {
            _liquids.append(Liquid(types: types, amount: amount))
        }
        
        _needsLiquidNodeUpdate = true
    }
    
    public func removeLiquid(amount: Double) {
        var amountLeft = amount
        for i in stride(from: liquids.count - 1, to: -1, by: -1) {
            if _liquids[i].amount > amountLeft {
                _liquids[i].amount -= amountLeft
                amountLeft = 0
            } else {
                amountLeft -= _liquids[i].amount
                _liquids.removeLast()
            }
            
            if amountLeft <= 0 {
                break
            }
        }
        
        _needsLiquidNodeUpdate = true
    }
    
    public func blend() {
        _liquids = [Liquid.blend(liquids)]
        _needsLiquidNodeUpdate = true
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SCNView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = SCNScene(named: "Test.scn")!

sceneView.showsStatistics = true
    
// Present the scene
sceneView.present(scene, with: SKTransition(), incomingPointOfView: nil, completionHandler: nil)

let cup = Cup()
cup.node.position.y = 10
scene.rootNode.addChildNode(cup.node)

let milk = LiquidType(color: .white)
let tea = LiquidType(color: CGColor(red: 0.5, green: 0.25, blue: 0, alpha: 0.95))
let water = LiquidType(color: CGColor(red: 0.8, green: 0.9, blue: 1, alpha: 0.5))
let sugar = LiquidType(color: CGColor(red: 1, green: 1, blue: 1, alpha: 0.8))
cup.add([tea: 0.8, milk: 0.2], amount: 0.6)
cup.add(water, amount: 0.3)
cup.add(sugar, amount: 0.1)
cup.updateLiquidNode()

sceneView.allowsCameraControl = true
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

let unicorn = LiquidType(color: CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0))
let red = LiquidType(color: CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
let yellow = LiquidType(color: CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0))

cup.removeLiquid(amount: 1.0)
cup.add(red, amount: 0.4)
cup.add(red, amount: 0.4)
cup.add(unicorn, amount: 0.2)
cup.updateLiquidNode()

cup.blend()
cup.updateLiquidNode()

cup.removeLiquid(amount: 1.0)
cup.add(red, amount: 0.4)
cup.add(red, amount: 0.4)
cup.add(unicorn, amount: 0.2)
cup.updateLiquidNode()
