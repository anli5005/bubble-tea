import Foundation

public class Order {
    public let index: Int?
    public let liquids: [LiquidType]
    public let needsShake: Bool
    public let bubbles: [BubbleType]
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public var price: Int
    
    public init(index: Int? = nil, liquids: [LiquidType], needsShake: Bool, bubbles: [BubbleType], startTime: TimeInterval, endTime: TimeInterval, price: Int) {
        self.index = index
        self.liquids = liquids
        self.needsShake = needsShake
        self.bubbles = bubbles
        self.startTime = startTime
        self.endTime = endTime
        self.price = price
    }
    
    public convenience init(index: Int? = nil, randomWithPossibleLiquids liquids: Set<LiquidType>, maxLiquids: Int, needsShake: Set<Bool>, bubbles: Set<BubbleType>, maxBubbles: Int, timeLimit: ClosedRange<TimeInterval>, startTime: TimeInterval, price: Int) {
        var liquidTypes = [LiquidType]()
        var possibleLiquids = liquids
        let numLiquids = Int.random(in: 1...min(maxLiquids, liquids.count))
        for _ in 1...numLiquids {
            let liquid = possibleLiquids.randomElement()!
            liquidTypes.append(liquid)
            possibleLiquids.remove(liquid)
        }
        
        var bubbleTypes = [BubbleType]()
        var possibleBubbles = bubbles
        let numBubbles = Int.random(in: 1...min(maxBubbles, bubbles.count))
        for _ in 1...numBubbles {
            let bubbleType = possibleBubbles.randomElement()!
            bubbleTypes.append(bubbleType)
            possibleBubbles.remove(bubbleType)
        }
        
        self.init(index: index, liquids: liquidTypes, needsShake: needsShake.randomElement() ?? false, bubbles: bubbleTypes, startTime: startTime, endTime: startTime + Double.random(in: timeLimit), price: price)
    }
    
    public enum CheckResult {
        case notFull
        case excessiveShake
        case needsShake
        case wrongLiquids(missing: Set<LiquidType>, excessive: Set<LiquidType>)
        case wrongBubbles(missing: Set<BubbleType>, excessive: Set<BubbleType>)
        case other
        case valid
        
        var isValid: Bool {
            switch self {
            case .valid:
                return true
            default:
                return false
            }
        }
    }
    
    public func check(cup: Cup) -> CheckResult {
        guard cup.totalLiquid >= 0.9 else {
            return .notFull
        }
        
        let cupLiquids: Set<LiquidType>
        let orderLiquids = Set(liquids)
        
        if needsShake {
            guard cup.liquids.count == 1 else {
                return .needsShake
            }
            
            cupLiquids = Set(cup.liquids.first!.types.keys)
        } else {
            guard cup.liquids.allSatisfy({ $0.type != nil }) else {
                return .excessiveShake
            }
            
            cupLiquids = Set(cup.liquids.lazy.map { $0.type! })
        }
        
        guard cupLiquids == orderLiquids else {
            return .wrongLiquids(missing: orderLiquids.subtracting(cupLiquids), excessive: cupLiquids.subtracting(orderLiquids))
        }
        
        let cupBubbles = Set(cup.bubbles.keys)
        let orderBubbles = Set(bubbles)
        guard cupBubbles == orderBubbles else {
            return .wrongBubbles(missing: orderBubbles.subtracting(cupBubbles), excessive: cupBubbles.subtracting(orderBubbles))
        }
        
        return .valid
    }
}
