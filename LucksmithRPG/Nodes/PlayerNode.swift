import SpriteKit

class PlayerNode: SKNode {

    // Visual components
    private let body:      SKShapeNode
    private let head:      SKShapeNode
    private let hpBarBG:   SKShapeNode
    private let hpBarFill: SKShapeNode
    private let label:     SKLabelNode

    private let bodyWidth:  CGFloat = 28
    private let bodyHeight: CGFloat = 36
    private let headRadius: CGFloat = 12
    private let hpBarWidth: CGFloat = 50

    // Combat timers (managed by GameScene)
    var attackCooldown: Double = 0
    var isAttacking:    Bool   = false

    override init() {
        // Body
        body = SKShapeNode(rectOf: CGSize(width: bodyWidth, height: bodyHeight), cornerRadius: 4)
        body.fillColor   = SKColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 1)
        body.strokeColor = SKColor(red: 0.15, green: 0.3, blue: 0.7, alpha: 1)
        body.lineWidth   = 2
        body.position    = CGPoint(x: 0, y: bodyHeight / 2)

        // Head
        head = SKShapeNode(circleOfRadius: headRadius)
        head.fillColor   = SKColor(red: 0.95, green: 0.82, blue: 0.65, alpha: 1)
        head.strokeColor = SKColor(red: 0.7, green: 0.55, blue: 0.4, alpha: 1)
        head.lineWidth   = 2
        head.position    = CGPoint(x: 0, y: bodyHeight + headRadius)

        // Emoji label on body
        label = SKLabelNode(text: "🗡")
        label.fontSize = 16
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: bodyHeight / 2)

        // HP bar background
        hpBarBG = SKShapeNode(rectOf: CGSize(width: hpBarWidth, height: 6), cornerRadius: 3)
        hpBarBG.fillColor   = SKColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.8)
        hpBarBG.strokeColor = .clear
        hpBarBG.position    = CGPoint(x: 0, y: bodyHeight + headRadius * 2 + 12)

        // HP bar fill
        hpBarFill = SKShapeNode(rectOf: CGSize(width: hpBarWidth, height: 6), cornerRadius: 3)
        hpBarFill.fillColor   = SKColor(red: 0.15, green: 0.85, blue: 0.25, alpha: 1)
        hpBarFill.strokeColor = .clear
        hpBarFill.position    = hpBarBG.position

        super.init()

        addChild(hpBarBG)
        addChild(hpBarFill)
        addChild(body)
        addChild(head)
        addChild(label)

        startIdleAnimation()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - HP bar

    func updateHP(current: Int, max: Int) {
        let pct = CGFloat(current) / CGFloat(max)
        let newWidth = hpBarWidth * pct
        let newFill  = SKShapeNode(rectOf: CGSize(width: max(0, newWidth), height: 6), cornerRadius: 3)

        let green = SKColor(red: 0.15, green: 0.85, blue: 0.25, alpha: 1)
        let red   = SKColor(red: 0.9,  green: 0.15, blue: 0.1,  alpha: 1)
        newFill.fillColor   = pct > 0.3 ? green : red
        newFill.strokeColor = .clear
        newFill.position    = CGPoint(x: -(hpBarWidth - newWidth) / 2, y: hpBarFill.position.y)

        hpBarFill.removeFromParent()
        addChild(newFill)
    }

    // MARK: - Animations

    private func startIdleAnimation() {
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.5),
            SKAction.moveBy(x: 0, y: -2, duration: 0.5),
        ])
        body.run(SKAction.repeatForever(bob))
        head.run(SKAction.repeatForever(bob.copy() as! SKAction))
    }

    func playAttackAnimation(toward direction: CGFloat) {
        let lunge = SKAction.sequence([
            SKAction.moveBy(x: direction * 20, y: 0, duration: 0.12),
            SKAction.moveBy(x: direction * -20, y: 0, duration: 0.1),
        ])
        run(lunge)

        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.06),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.06),
        ])
        body.run(flash)
    }

    func playHitAnimation() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -6, y: 0, duration: 0.06),
            SKAction.moveBy(x:  6, y: 0, duration: 0.06),
            SKAction.moveBy(x: -4, y: 0, duration: 0.04),
            SKAction.moveBy(x:  4, y: 0, duration: 0.04),
            SKAction.moveBy(x:  0, y: 0, duration: 0),
        ])
        run(shake)
        let flash = SKAction.sequence([
            SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.7, duration: 0.08),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.1),
        ])
        body.run(flash)
    }

    func playDeathAnimation(completion: @escaping () -> Void) {
        let fall = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.rotate(byAngle: -.pi / 2, duration: 0.5),
                SKAction.scale(to: 0.3, duration: 0.5),
            ]),
            SKAction.run(completion),
        ])
        run(fall)
    }

    func setFacingRight(_ right: Bool) {
        xScale = right ? 1 : -1
    }
}
