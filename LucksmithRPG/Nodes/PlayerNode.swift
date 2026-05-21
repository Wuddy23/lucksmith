import SpriteKit

class PlayerNode: SKNode {

    // Visual components
    private let body:      SKShapeNode
    private let head:      SKShapeNode
    private let hpBarBG:   SKShapeNode
    private let hpBarFill: SKShapeNode
    private let sword      = SKNode()

    private let bodyWidth:  CGFloat = 28
    private let bodyHeight: CGFloat = 36
    private let headRadius: CGFloat = 12
    private let hpBarWidth: CGFloat = 50

    private let swordRestAngle: CGFloat = -.pi / 6

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
        buildSword()

        startIdleAnimation()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Sword

    private func buildSword() {
        // Blade
        let blade = SKShapeNode(rectOf: CGSize(width: 4, height: 20), cornerRadius: 1)
        blade.fillColor   = SKColor(red: 0.78, green: 0.84, blue: 0.95, alpha: 1)
        blade.strokeColor = SKColor(red: 0.5, green: 0.56, blue: 0.72, alpha: 1)
        blade.lineWidth   = 1
        blade.position    = CGPoint(x: 0, y: 12)

        // Crossguard
        let crossguard = SKShapeNode(rectOf: CGSize(width: 11, height: 3), cornerRadius: 1)
        crossguard.fillColor   = SKColor(red: 0.75, green: 0.62, blue: 0.22, alpha: 1)
        crossguard.strokeColor = SKColor(red: 0.52, green: 0.42, blue: 0.12, alpha: 1)
        crossguard.lineWidth   = 1
        crossguard.position    = CGPoint(x: 0, y: 3)

        // Handle
        let handle = SKShapeNode(rectOf: CGSize(width: 3, height: 7), cornerRadius: 1)
        handle.fillColor   = SKColor(red: 0.48, green: 0.28, blue: 0.12, alpha: 1)
        handle.strokeColor = SKColor(red: 0.32, green: 0.18, blue: 0.08, alpha: 1)
        handle.lineWidth   = 0.5
        handle.position    = CGPoint(x: 0, y: -2)

        sword.addChild(blade)
        sword.addChild(crossguard)
        sword.addChild(handle)

        // Position at player's right hand, mid-body height
        sword.position  = CGPoint(x: bodyWidth / 2 + 2, y: bodyHeight * 0.4)
        sword.zRotation = swordRestAngle
        addChild(sword)
    }

    // MARK: - HP bar

    func updateHP(current: Int, maxHP: Int) {
        let pct = CGFloat(current) / CGFloat(maxHP)
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
        // Lunge forward
        let lunge = SKAction.sequence([
            SKAction.moveBy(x: direction * 20, y: 0, duration: 0.12),
            SKAction.moveBy(x: direction * -20, y: 0, duration: 0.1),
        ])
        run(lunge)

        // Sword swing: wind-up → slash → return to rest
        // xScale handles mirroring when facing left, so rotation values are the same
        let windUp = SKAction.rotate(toAngle: .pi / 5,      duration: 0.07, shortestUnitArc: true)
        let slash  = SKAction.rotate(toAngle: -.pi * 0.72,  duration: 0.09, shortestUnitArc: true)
        let ret    = SKAction.rotate(toAngle: swordRestAngle, duration: 0.11, shortestUnitArc: true)
        sword.run(SKAction.sequence([windUp, slash, ret]))

        // Body flash
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
