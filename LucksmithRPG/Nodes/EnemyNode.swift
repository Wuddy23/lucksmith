import SpriteKit

class EnemyNode: SKNode {

    let instance: EnemyInstance

    private let body:      SKShapeNode
    private let label:     SKLabelNode
    private let hpBarBG:   SKShapeNode
    private var hpBarFill: SKShapeNode
    private let nameLabel: SKLabelNode

    var isDying = false
    var attackTimer: Double = 0  // counts up; attack when >= instance.attackInterval

    private var hpBarWidth: CGFloat { instance.type.isBoss ? 80 : 50 }

    init(instance: EnemyInstance) {
        self.instance = instance

        let size = instance.type.size
        let isBoss = instance.type.isBoss

        // Body
        body = isBoss
            ? SKShapeNode(ellipseOf: size)
            : SKShapeNode(rectOf: size, cornerRadius: 5)
        body.fillColor   = instance.type.color
        body.strokeColor = instance.type.color.withAlphaComponent(0.5)
        body.lineWidth   = isBoss ? 3 : 2
        body.position    = CGPoint(x: 0, y: size.height / 2)

        // Emoji label
        label = SKLabelNode(text: instance.type.emoji)
        label.fontSize = isBoss ? 26 : 20
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.position = body.position

        // HP bar bg
        let bw = isBoss ? 80.0 : 50.0
        hpBarBG = SKShapeNode(rectOf: CGSize(width: bw, height: 6), cornerRadius: 3)
        hpBarBG.fillColor   = SKColor(red: 0.25, green: 0.05, blue: 0.05, alpha: 0.85)
        hpBarBG.strokeColor = .clear
        hpBarBG.position    = CGPoint(x: 0, y: size.height + 16)

        // HP bar fill
        hpBarFill = SKShapeNode(rectOf: CGSize(width: bw, height: 6), cornerRadius: 3)
        hpBarFill.fillColor   = SKColor(red: 0.9, green: 0.2, blue: 0.15, alpha: 1)
        hpBarFill.strokeColor = .clear
        hpBarFill.position    = hpBarBG.position

        // Name label
        nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text      = isBoss ? "⚠️ \(instance.type.rawValue)" : instance.type.rawValue
        nameLabel.fontSize  = isBoss ? 14 : 11
        nameLabel.fontColor = isBoss ? SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1) : .lightGray
        nameLabel.verticalAlignmentMode   = .center
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.position  = CGPoint(x: 0, y: size.height + 28)

        super.init()

        addChild(hpBarBG)
        addChild(hpBarFill)
        addChild(body)
        addChild(label)
        addChild(nameLabel)

        startIdleAnimation()
        if isBoss { addBossGlow() }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - HP update

    func updateHP() {
        let pct     = CGFloat(instance.hpPercent)
        let newWidth = hpBarWidth * pct
        hpBarFill.removeFromParent()

        let fill = SKShapeNode(rectOf: CGSize(width: max(0, newWidth), height: 6), cornerRadius: 3)
        fill.fillColor   = pct > 0.5
            ? SKColor(red: 0.9, green: 0.2, blue: 0.15, alpha: 1)
            : SKColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1)
        fill.strokeColor = .clear
        fill.position    = CGPoint(x: -(hpBarWidth - newWidth) / 2, y: hpBarBG.position.y)

        hpBarFill = fill
        addChild(hpBarFill)
    }

    // MARK: - Animations

    private func startIdleAnimation() {
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.6),
            SKAction.moveBy(x: 0, y: -3, duration: 0.6),
        ])
        body.run(SKAction.repeatForever(bob))
    }

    private func addBossGlow() {
        body.glowWidth = 12
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8),
        ])
        body.run(SKAction.repeatForever(pulse))
    }

    func playHitAnimation() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.9, duration: 0.05),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.08),
        ])
        body.run(flash)
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.04),
            SKAction.moveBy(x:  5, y: 0, duration: 0.04),
            SKAction.moveBy(x:  0, y: 0, duration: 0),
        ])
        run(shake)
    }

    func playAttackAnimation(toward targetX: CGFloat, completion: @escaping () -> Void) {
        let dir: CGFloat = targetX < position.x ? -1 : 1
        let lunge = SKAction.sequence([
            SKAction.moveBy(x: dir * 22, y: 0, duration: 0.1),
            SKAction.run(completion),
            SKAction.moveBy(x: dir * -22, y: 0, duration: 0.1),
        ])
        run(lunge)
    }

    func playDeathAnimation(completion: @escaping () -> Void) {
        isDying = true
        let explode = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.4, duration: 0.15),
                SKAction.colorize(with: SKColor(red: 1, green: 0.4, blue: 0, alpha: 1),
                                  colorBlendFactor: 0.8, duration: 0.15),
            ]),
            SKAction.group([
                SKAction.scale(to: 0, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25),
            ]),
            SKAction.run(completion),
            SKAction.removeFromParent(),
        ])
        body.run(explode)
        let fadeOut = SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.fadeOut(withDuration: 0.2),
        ])
        label.run(fadeOut)
        nameLabel.run(fadeOut.copy() as! SKAction)
        hpBarBG.run(fadeOut.copy() as! SKAction)
        hpBarFill.run(fadeOut.copy() as! SKAction)
    }
}
