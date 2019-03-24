import SpriteKit

internal class Menu {
    internal static let size = CGSize(width: 600, height: 400)
    
    internal let node = SKShapeNode(rect: CGRect(origin: CGPoint(x: -Menu.size.width / 2, y: -Menu.size.height / 2), size: Menu.size), cornerRadius: 16)
    private weak var gameManager: GameManager?
    internal let levels: [Level]
    internal let type: MenuType
    private let closeAction: CloseAction
    
    internal let levelNodes: [SKNode]
    internal let closeNode: SKShapeNode
    
    private enum CloseAction: CustomStringConvertible {
        case resume
        case next(level: Level)
        case restart
        
        public var description: String {
            switch self {
            case .resume:
                return "Resume"
            case .next(_):
                return "Next level"
            case .restart:
                return "Restart"
            }
        }
    }
    
    internal enum MenuType {
        case paused
        case success
        case failure
    }
    
    internal init(levels: [Level], gameManager: GameManager?, type: MenuType) {
        self.levels = levels
        self.type = type
        self.gameManager = gameManager
        
        switch type {
        case .paused:
            closeAction = .resume
        case .success:
            if let level = gameManager?.currentLevel {
                if let index = levels.firstIndex(where: { $0 === level }) {
                    if index + 1 < levels.count {
                        closeAction = .next(level: levels[index + 1])
                        break
                    }
                }
            }
            closeAction = .restart
        case .failure:
            closeAction = .restart
        }
        
        node.fillColor = .black
        node.strokeColor = .clear
        
        let titleNode = SKLabelNode(fontNamed: NSFont.systemFont(ofSize: 18, weight: .medium).fontName)
        titleNode.fontSize = 26
        titleNode.horizontalAlignmentMode = .center
        titleNode.verticalAlignmentMode = .bottom
        titleNode.position = CGPoint(x: 0, y: 160)
        node.addChild(titleNode)
        
        let descriptionNode = SKLabelNode(fontNamed: NSFont.systemFont(ofSize: 12, weight: .regular).fontName)
        descriptionNode.fontSize = 12
        descriptionNode.fontColor = .lightGray
        descriptionNode.horizontalAlignmentMode = .center
        descriptionNode.verticalAlignmentMode = .top
        descriptionNode.position = CGPoint(x: 0, y: 156)
        node.addChild(descriptionNode)
        
        switch type {
        case .paused:
            titleNode.text = "Paused"
            titleNode.fontColor = .white
            if let name = gameManager?.currentLevel?.name {
                descriptionNode.text = "Current level: \(name)"
            }
        case .success:
            titleNode.text = "Success!"
            titleNode.fontColor = NSColor(red: 0.9, green: 1, blue: 0.9, alpha: 1)
            descriptionNode.text = "You have reached your goal for this level."
        case .failure:
            titleNode.text = "Failure"
            titleNode.fontColor = NSColor(red: 1, green: 0.9, blue: 0.9, alpha: 1)
            descriptionNode.text = "You have failed to reach your goal for this level."
        }
        
        var nodes = [SKNode]()
        let pos = -72
        
        for (index, level) in levels.enumerated() {
            let y = pos - 28 * index
            let shapeNode = SKShapeNode(rect: CGRect(x: -100, y: y - 12, width: 200, height: 24), cornerRadius: 12)
            shapeNode.fillColor = NSColor.white.withAlphaComponent(0.2)
            shapeNode.strokeColor = .clear
            let textNode = SKLabelNode(text: "Restart \(level.name ?? "Unknown Level")")
            textNode.fontSize = 14
            textNode.fontColor = .white
            textNode.fontName = NSFont.systemFont(ofSize: textNode.fontSize, weight: .medium).fontName
            textNode.horizontalAlignmentMode = .center
            textNode.verticalAlignmentMode = .center
            textNode.position = CGPoint(x: 0, y: y)
            shapeNode.addChild(textNode)
            nodes.append(shapeNode)
        }
        
        levelNodes = nodes
        
        closeNode = SKShapeNode(rect: CGRect(x: -100, y: -192, width: 200, height: 48), cornerRadius: 24)
        closeNode.fillColor = NSColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        closeNode.strokeColor = .clear
        let closeTextNode = SKLabelNode(text: closeAction.description)
        closeTextNode.fontSize = 24
        closeTextNode.fontColor = .white
        closeTextNode.fontName = NSFont.systemFont(ofSize: closeTextNode.fontSize, weight: .bold).fontName
        closeTextNode.horizontalAlignmentMode = .center
        closeTextNode.verticalAlignmentMode = .center
        closeTextNode.position = CGPoint(x: 0, y: -168)
        closeNode.addChild(closeTextNode)
        node.addChild(closeNode)
        
        levelNodes.forEach { node.addChild($0) }
    }
    
    internal func show(in scene: SKScene) {
        gameManager?.isPaused = true
        node.setScale(0)
        node.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        scene.addChild(node)
        node.run(SKAction.scale(to: 1, duration: 0.2))
    }
    
    internal func hide() {
        node.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.2), SKAction.removeFromParent()]))
        gameManager?.isPaused = false
    }
    
    internal func processClick(on clickedNode: SKNode) -> Bool {
        if clickedNode == closeNode {
            switch closeAction {
            case .restart:
                let gameManager = self.gameManager
                node.run(SKAction.group([SKAction.removeFromParent(), SKAction.customAction(withDuration: 0, actionBlock: { _, _ in
                    gameManager!.loadLevel(gameManager!.currentLevel!)
                })]))
            case .next(let level):
                let gameManager = self.gameManager
                node.run(SKAction.group([SKAction.removeFromParent(), SKAction.customAction(withDuration: 0, actionBlock: { _, _ in
                    gameManager?.loadLevel(level)
                })]))
            default:
                hide()
                break
            }
        } else if let index = levelNodes.firstIndex(of: clickedNode) {
            let gameManager = self.gameManager
            let levels = self.levels
            node.run(SKAction.group([SKAction.removeFromParent(), SKAction.customAction(withDuration: 0, actionBlock: { _, _ in
                gameManager?.loadLevel(levels[index])
            })]))
        }
        
        return false
    }
}
