import CoreGraphics

/// Represents a cup made in-game.
public class Cup {
    /// A homogenous liquid mixture of one or more types of liquids.
    public struct Liquid {
        /// Types of liquids represented in the mixutre and their proportions.
        let types: [LiquidType: Double]
        
        /// Amount of liquid represented.
        var amount: Double
        
        /// Color of the liquid represented.
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
        
    private var _liquids = [Liquid]()
    public var liquids: [Liquid] {
        return _liquids
    }
    
    public var liquidsUpdated = false
    public var bubblesUpdated = false
    
    private var _bubbles = [BubbleType: Int]()
    public var bubbles: [BubbleType: Int] {
        return _bubbles
    }
    
    public func add(_ liquid: LiquidType, amount: Double) {
        if liquids.last?.type == liquid {
            _liquids[liquids.count - 1].amount += amount
        } else {
            _liquids.append(Liquid(type: liquid, amount: amount))
        }
        
        liquidsUpdated = true
    }
    
    public func add(_ types: [LiquidType: Double], amount: Double) {
        if liquids.last?.types == types {
            _liquids[liquids.count - 1].amount += amount
        } else {
            _liquids.append(Liquid(types: types, amount: amount))
        }
        
        liquidsUpdated = true
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
        
        liquidsUpdated = true
    }  
    
    public func blend() {
        _liquids = [Liquid.blend(liquids)]
        liquidsUpdated = true
    }
    
    public var totalLiquid: Double {
        return liquids.reduce(0.0) { $0 + $1.amount }
    }
    
    public func add(_ bubbles: BubbleType, amount: Int = 1) {
        _bubbles[bubbles] = (_bubbles[bubbles] ?? 0) + amount
        bubblesUpdated = true
    }
    
    public var bubbleCount: Int {
        return bubbles.reduce(0) { $0 + $1.value }
    }
    
    public init() {}
}
