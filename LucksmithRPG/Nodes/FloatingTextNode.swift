import SpriteKit

// Floating damage / loot / status text that rises and fades.
class FloatingTextNode: SKNode {

    private let label: SKLabelNode

    init(text: String, color: SKColor, fontSize: CGFloat = 22) {
        label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text      = text
        label.fontSize  = fontSize
        label.fontColor = color
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        super.init()
        addChild(label)
    }

    required init?(coder: NSCoder) { fatalError() }

    // Animate the node: rise, then fade out, then remove
    func animate(riseDistance: CGFloat = 50, duration: TimeInterval = 1.0) {
        let rise  = SKAction.moveBy(x: 0, y: riseDistance, duration: duration)
        let fade  = SKAction.fadeOut(withDuration: duration * 0.6)
        let group = SKAction.group([rise, fade])
        run(SKAction.sequence([group, .removeFromParent()]))
    }

    // Convenience factory methods

    static func damage(_ amount: Int, isCritical: Bool = false) -> FloatingTextNode {
        let text  = isCritical ? "‼ \(amount)" : "\(amount)"
        let color = isCritical ? SKColor(red: 1, green: 0.3, blue: 0, alpha: 1) : SKColor(red: 1, green: 0.9, blue: 0.1, alpha: 1)
        let size: CGFloat = isCritical ? 28 : 20
        return FloatingTextNode(text: text, color: color, fontSize: size)
    }

    static func gold(_ amount: Int) -> FloatingTextNode {
        FloatingTextNode(text: "+\(amount)G", color: SKColor(red: 1, green: 0.85, blue: 0, alpha: 1), fontSize: 18)
    }

    static func metal(_ amount: Int) -> FloatingTextNode {
        FloatingTextNode(text: "+\(amount)M", color: SKColor(red: 0.6, green: 0.75, blue: 0.85, alpha: 1), fontSize: 18)
    }

    static func levelUp() -> FloatingTextNode {
        FloatingTextNode(text: "LEVEL UP!", color: SKColor(red: 1, green: 0.9, blue: 0, alpha: 1), fontSize: 26)
    }

    static func status(_ text: String) -> FloatingTextNode {
        FloatingTextNode(text: text, color: .white, fontSize: 20)
    }
}
