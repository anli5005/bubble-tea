import Foundation

public struct Order {
    public let index: Int?
    public let liquids: [LiquidType]
    public let needsShake: Bool
    public let bubbles: [BubbleType]
    public let deadline: TimeInterval
    
    public init(index: Int? = nil, liquids: [LiquidType], needsShake: Bool, bubbles: [BubbleType], deadline: TimeInterval) {
        self.index = index
        self.liquids = liquids
        self.needsShake = needsShake
        self.bubbles = bubbles
        self.deadline = deadline
    }
    
    public init(index: Int? = nil, randomWithPossibleLiquids liquids: Set<LiquidType>, maxLiquids: Int, needsShake: Set<Bool>, bubbles: Set<BubbleType>, maxBubbles: Int, deadline: TimeInterval) {
        var liquidTypes = [LiquidType]()
        var possibleLiquids = liquids
        let numLiquids = Int.random(in: 1...max(maxLiquids, liquids.count))
        for _ in 1...numLiquids {
            let liquid = possibleLiquids.randomElement()!
            liquidTypes.append(liquid)
            possibleLiquids.remove(liquid)
        }
        
        var bubbleTypes = [BubbleType]()
        var possibleBubbles = bubbles
        let numBubbles = Int.random(in: 1...max(maxBubbles, bubbles.count))
        for _ in 1...numBubbles {
            let bubbleType = possibleBubbles.randomElement()!
            bubbleTypes.append(bubbleType)
            possibleBubbles.remove(bubbleType)
        }
        
        self.init(index: index, liquids: liquidTypes, needsShake: needsShake.randomElement() ?? false, bubbles: bubbleTypes, deadline: deadline)
    }
}
