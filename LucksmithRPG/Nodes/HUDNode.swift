import SpriteKit

// Heads-up display fixed to the camera.
// Call layout(size:) once after adding to camera, then updateXxx as needed.
class HUDNode: SKNode {

    // Top bar
    private let hpBarBG:    SKShapeNode = SKShapeNode()
    private var hpBarFill:  SKShapeNode = SKShapeNode()
    private let hpLabel:    SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let goldLabel:  SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let metalLabel: SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let floorLabel: SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let levelLabel: SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")

    // Bottom buttons
    private(set) var blacksmithButton: SKNode = SKNode()
    private(set) var inventoryButton:  SKNode = SKNode()

    var onBlacksmith: (() -> Void)?
    var onInventory:  (() -> Void)?

    private var hpBarWidth: CGFloat = 200

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) { fatalError() }

    func layout(size: CGSize) {
        removeAllChildren()
        hpBarWidth = size.width * 0.55

        let topY    = size.height / 2 - 30
        let bottomY = -size.height / 2 + 22
        let pad: CGFloat = 14

        // ── HP Bar ────────────────────────────────────────────────────────────
        let barH: CGFloat = 18
        hpBarBG.path      = CGPath(roundedRect: CGRect(x: -hpBarWidth / 2, y: -barH / 2,
                                                        width: hpBarWidth, height: barH),
                                    cornerWidth: barH / 2, cornerHeight: barH / 2, transform: nil)
        hpBarBG.fillColor   = SKColor(white: 0.1, alpha: 0.8)
        hpBarBG.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        hpBarBG.lineWidth   = 1
        hpBarBG.position    = CGPoint(x: 0, y: topY)
        addChild(hpBarBG)

        hpBarFill = makeFill(pct: 1.0)
        addChild(hpBarFill)

        hpLabel.text      = "HP"
        hpLabel.fontSize  = 11
        hpLabel.fontColor = .white
        hpLabel.verticalAlignmentMode   = .center
        hpLabel.horizontalAlignmentMode = .center
        hpLabel.position  = CGPoint(x: 0, y: topY)
        addChild(hpLabel)

        // ── Gold / Metal ──────────────────────────────────────────────────────
        goldLabel.fontSize  = 15
        goldLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0, alpha: 1)
        goldLabel.verticalAlignmentMode   = .center
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position  = CGPoint(x: -size.width / 2 + pad, y: topY - 26)
        addChild(goldLabel)

        metalLabel.fontSize  = 15
        metalLabel.fontColor = SKColor(red: 0.65, green: 0.8, blue: 0.9, alpha: 1)
        metalLabel.verticalAlignmentMode   = .center
        metalLabel.horizontalAlignmentMode = .left
        metalLabel.position  = CGPoint(x: -size.width / 2 + pad, y: topY - 44)
        addChild(metalLabel)

        // ── Floor + Level ─────────────────────────────────────────────────────
        floorLabel.fontSize  = 13
        floorLabel.fontColor = SKColor(white: 0.85, alpha: 1)
        floorLabel.verticalAlignmentMode   = .center
        floorLabel.horizontalAlignmentMode = .right
        floorLabel.position  = CGPoint(x: size.width / 2 - pad, y: topY - 26)
        addChild(floorLabel)

        levelLabel.fontSize  = 13
        levelLabel.fontColor = SKColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1)
        levelLabel.verticalAlignmentMode   = .center
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.position  = CGPoint(x: size.width / 2 - pad, y: topY - 44)
        addChild(levelLabel)

        // ── Bottom Buttons ────────────────────────────────────────────────────
        blacksmithButton = makeButton(icon: "🔨", label: "FORGE", xPos: -size.width / 4, y: bottomY)
        addChild(blacksmithButton)

        inventoryButton = makeButton(icon: "🎒", label: "GEAR", xPos: size.width / 4, y: bottomY)
        addChild(inventoryButton)
    }

    // MARK: - Updates

    func updateHP(current: Int, max: Int) {
        let pct = CGFloat(current) / CGFloat(max)
        hpBarFill.removeFromParent()
        hpBarFill = makeFill(pct: pct)
        addChild(hpBarFill)
        hpLabel.text = "\(current) / \(max)"
    }

    func updateGold(_ gold: Int)   { goldLabel.text  = "🪙 \(gold)" }
    func updateMetal(_ metal: Int) { metalLabel.text = "⚙️ \(metal)" }
    func updateFloor(_ text: String) { floorLabel.text = text }
    func updateLevel(_ level: Int)   { levelLabel.text = "Lv.\(level)" }

    // MARK: - Touch forwarding

    func handleTouch(at point: CGPoint) {
        if blacksmithButton.contains(point) { onBlacksmith?() }
        if inventoryButton.contains(point)  { onInventory?()  }
    }

    // MARK: - Private helpers

    private func makeFill(pct: CGFloat) -> SKShapeNode {
        let w    = max(0, hpBarWidth * pct)
        let barH: CGFloat = 18
        let topY = children.first { $0 === hpBarBG }.map { $0.position.y } ?? 0
        let fill = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -hpBarWidth / 2, y: -barH / 2,
                                                                 width: w, height: barH),
                                             cornerWidth: barH / 2, cornerHeight: barH / 2, transform: nil))
        fill.fillColor   = pct > 0.3
            ? SKColor(red: 0.15, green: 0.85, blue: 0.25, alpha: 1)
            : SKColor(red: 0.9,  green: 0.15, blue: 0.1,  alpha: 1)
        fill.strokeColor = .clear
        fill.position    = CGPoint(x: 0, y: topY)
        return fill
    }

    private func makeButton(icon: String, label: String, xPos: CGFloat, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: xPos, y: y)

        let bg = SKShapeNode(rectOf: CGSize(width: 110, height: 38), cornerRadius: 10)
        bg.fillColor   = SKColor(white: 0.12, alpha: 0.9)
        bg.strokeColor = SKColor(white: 0.4, alpha: 0.7)
        bg.lineWidth   = 1.5
        container.addChild(bg)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = "\(icon) \(label)"
        lbl.fontSize  = 15
        lbl.fontColor = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)

        return container
    }
}
