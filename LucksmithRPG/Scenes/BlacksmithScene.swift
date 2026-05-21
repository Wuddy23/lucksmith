import SpriteKit

class BlacksmithScene: SKScene {

    var onClose: (() -> Void)?

    private let gm = GameManager.shared
    private var pd: PlayerData { gm.player }

    private var metalLabel:     SKLabelNode!
    private var costLabel:      SKLabelNode!
    private var forgeButton:    SKNode!
    private var resultPanel:    SKNode?
    private var hammerLabel:    SKLabelNode!
    private var isForging       = false

    override func didMove(to view: SKView) {
        size = view.frame.size
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.1, green: 0.07, blue: 0.05, alpha: 1)
        buildUI()
    }

    // MARK: - UI

    private func buildUI() {
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text      = "🔨 The Blacksmith"
        title.fontSize  = 30
        title.fontColor = SKColor(red: 1, green: 0.7, blue: 0.2, alpha: 1)
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: size.height / 2 - 60)
        addChild(title)

        // Anvil decoration
        let anvil = SKLabelNode(text: "⚒")
        anvil.fontSize = 64
        anvil.verticalAlignmentMode   = .center
        anvil.horizontalAlignmentMode = .center
        anvil.position = CGPoint(x: 0, y: size.height / 2 - 150)
        addChild(anvil)

        // Hammer that animates during forging
        hammerLabel = SKLabelNode(text: "🔨")
        hammerLabel.fontSize = 36
        hammerLabel.verticalAlignmentMode   = .center
        hammerLabel.horizontalAlignmentMode = .center
        hammerLabel.position = CGPoint(x: -60, y: size.height / 2 - 150)
        hammerLabel.alpha = 0
        addChild(hammerLabel)

        // Metal count
        metalLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        metalLabel.fontSize  = 22
        metalLabel.fontColor = SKColor(red: 0.65, green: 0.8, blue: 0.9, alpha: 1)
        metalLabel.verticalAlignmentMode   = .center
        metalLabel.horizontalAlignmentMode = .center
        metalLabel.position = CGPoint(x: 0, y: size.height / 2 - 220)
        addChild(metalLabel)

        // Cost label
        costLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        costLabel.fontSize  = 17
        costLabel.fontColor = .lightGray
        costLabel.verticalAlignmentMode   = .center
        costLabel.horizontalAlignmentMode = .center
        costLabel.position = CGPoint(x: 0, y: size.height / 2 - 250)
        addChild(costLabel)

        // Forge button
        forgeButton = makeForgeButton()
        forgeButton.position = CGPoint(x: 0, y: 0)
        addChild(forgeButton)

        // Back button
        let backBtn = makeTextButton(text: "← Back", color: SKColor(white: 0.25, alpha: 1))
        backBtn.position = CGPoint(x: 0, y: -size.height / 2 + 55)
        backBtn.name = "backBtn"
        addChild(backBtn)

        // Rarity odds info panel
        addRarityInfo()

        updateLabels()
    }

    private func makeForgeButton() -> SKNode {
        let container = SKNode()
        container.name = "forgeBtn"

        let bg = SKShapeNode(rectOf: CGSize(width: 220, height: 60), cornerRadius: 14)
        bg.fillColor   = SKColor(red: 0.65, green: 0.35, blue: 0.0, alpha: 1)
        bg.strokeColor = SKColor(red: 0.9, green: 0.55, blue: 0.1, alpha: 0.8)
        bg.lineWidth   = 2
        container.addChild(bg)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        lbl.text      = "⚒ FORGE"
        lbl.fontSize  = 24
        lbl.fontColor = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)

        return container
    }

    private func makeTextButton(text: String, color: SKColor) -> SKNode {
        let container = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 10)
        bg.fillColor   = color
        bg.strokeColor = color.withAlphaComponent(0.6)
        bg.lineWidth   = 1.5
        container.addChild(bg)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 17
        lbl.fontColor = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)

        return container
    }

    private func addRarityInfo() {
        let panel = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: 110), cornerRadius: 12)
        panel.fillColor   = SKColor(white: 0.08, alpha: 0.9)
        panel.strokeColor = SKColor(white: 0.3, alpha: 0.5)
        panel.lineWidth   = 1
        panel.position    = CGPoint(x: 0, y: -size.height / 2 + 150)
        addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text      = "Drop Rates"
        title.fontSize  = 13
        title.fontColor = SKColor(white: 0.7, alpha: 1)
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: panel.position.y + 40)
        addChild(title)

        let rarities: [(String, String)] = [
            ("Common",    "60%"),
            ("Uncommon",  "25%"),
            ("Rare",      "10%"),
            ("Epic",       "4%"),
            ("Legendary",  "1%"),
        ]
        let spacing: CGFloat = (size.width - 60) / CGFloat(rarities.count)
        for (i, (name, pct)) in rarities.enumerated() {
            let rarity = EquipmentRarity(rawValue: name)!
            let x = -size.width / 2 + 30 + spacing * CGFloat(i) + spacing / 2

            let nLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nLbl.text      = name
            nLbl.fontSize  = 10
            nLbl.fontColor = rarity.color
            nLbl.verticalAlignmentMode   = .center
            nLbl.horizontalAlignmentMode = .center
            nLbl.position = CGPoint(x: x, y: panel.position.y + 10)
            addChild(nLbl)

            let pLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            pLbl.text      = pct
            pLbl.fontSize  = 12
            pLbl.fontColor = .white
            pLbl.verticalAlignmentMode   = .center
            pLbl.horizontalAlignmentMode = .center
            pLbl.position = CGPoint(x: x, y: panel.position.y - 15)
            addChild(pLbl)
        }
    }

    // MARK: - Forge animation + result

    private func startForge() {
        guard !isForging, gm.canForge() else {
            shakeForgeButton()
            return
        }
        isForging = true
        forgeButton.alpha = 0.5

        // Hammer animation
        hammerLabel.alpha = 1
        let hammer = SKAction.sequence([
            SKAction.rotate(byAngle: -.pi / 4, duration: 0.1),
            SKAction.rotate(byAngle:  .pi / 4, duration: 0.1),
        ])
        hammerLabel.run(SKAction.sequence([
            SKAction.repeat(hammer, count: 6),
            SKAction.run { [weak self] in self?.revealForgeResult() },
        ]))
    }

    private func revealForgeResult() {
        guard let item = gm.forge() else {
            isForging = false
            forgeButton.alpha = 1
            hammerLabel.alpha = 0
            updateLabels()
            return
        }

        hammerLabel.alpha = 0
        updateLabels()
        showItemResult(item)
        isForging = false
        forgeButton.alpha = 1
    }

    private func showItemResult(_ item: Equipment) {
        resultPanel?.removeFromParent()

        let equipped  = gm.player.equipped(slot: item.slot)
        let statRows  = buildStatRows(item: item, equipped: equipped)
        let panelW    = size.width - 40
        let rowH: CGFloat  = 17
        let panelHeight: CGFloat = 188 + CGFloat(statRows.count) * rowH

        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelHeight), cornerRadius: 16)
        panel.fillColor   = SKColor(white: 0.1, alpha: 0.97)
        panel.strokeColor = item.rarity.color
        panel.lineWidth   = item.rarity == .legendary ? 3 : 2
        panel.position    = CGPoint(x: 0, y: size.height / 2 - 380)
        panel.alpha       = 0
        panel.name        = "resultPanel"
        panel.zPosition   = 10

        if item.rarity.glowRadius > 0 { panel.glowWidth = item.rarity.glowRadius }

        var curY = panelHeight / 2 - 22

        // Rarity badge
        let rarityLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        rarityLbl.text      = "[ \(item.rarity.rawValue.uppercased()) ]"
        rarityLbl.fontSize  = 15
        rarityLbl.fontColor = item.rarity.color
        rarityLbl.verticalAlignmentMode   = .center
        rarityLbl.horizontalAlignmentMode = .center
        rarityLbl.position = CGPoint(x: 0, y: curY)
        panel.addChild(rarityLbl)
        curY -= 24

        // Item name
        let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        nameLbl.text      = "\(item.slot.icon) \(item.name)"
        nameLbl.fontSize  = 18
        nameLbl.fontColor = .white
        nameLbl.verticalAlignmentMode   = .center
        nameLbl.horizontalAlignmentMode = .center
        nameLbl.position = CGPoint(x: 0, y: curY)
        panel.addChild(nameLbl)
        curY -= 22

        // Column headers
        if equipped != nil {
            addForgeHeader("Equipped", x: -28, y: curY, to: panel, panelW: panelW)
            addForgeHeader("New",      x:  60, y: curY, to: panel, panelW: panelW)
            addForgeHeader("Change",   x: 130, y: curY, to: panel, panelW: panelW)
        } else {
            addForgeHeader("Stats",    x: 0,   y: curY, to: panel, panelW: panelW)
        }
        curY -= 4

        // Stat comparison rows
        let green = SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
        let red   = SKColor(red: 0.95, green: 0.25, blue: 0.2, alpha: 1)
        let gray  = SKColor(white: 0.5, alpha: 1)
        for row in statRows {
            curY -= rowH
            let diffStr   = row.diff > 0 ? "▲\(row.diffStr)" : row.diff < 0 ? "▼\(row.diffStr)" : "="
            let diffColor = row.diff > 0 ? green : row.diff < 0 ? red : gray

            let nameLbl = makeForgeLbl(row.label + ":", color: SKColor(white: 0.6, alpha: 1), align: .left)
            nameLbl.position = CGPoint(x: -panelW / 2 + 12, y: curY)
            panel.addChild(nameLbl)

            if equipped != nil {
                let oldLbl = makeForgeLbl(row.oldStr, color: SKColor(white: 0.5, alpha: 1), align: .center)
                oldLbl.position = CGPoint(x: -panelW / 2 + panelW * 0.38, y: curY)
                panel.addChild(oldLbl)

                let arrLbl = makeForgeLbl("→", color: gray, align: .center)
                arrLbl.position = CGPoint(x: -panelW / 2 + panelW * 0.53, y: curY)
                panel.addChild(arrLbl)
            }

            let newLbl = makeForgeLbl(row.newStr, color: .white, align: .center)
            newLbl.position = CGPoint(x: -panelW / 2 + panelW * (equipped != nil ? 0.66 : 0.5), y: curY)
            panel.addChild(newLbl)

            if equipped != nil {
                let diffLbl = makeForgeLbl(diffStr, color: diffColor, align: .center)
                diffLbl.position = CGPoint(x: -panelW / 2 + panelW * 0.84, y: curY)
                panel.addChild(diffLbl)
            }
        }
        curY -= 14

        // Flavor text
        let flavorLbl = SKLabelNode(fontNamed: "AvenirNext-Italic")
        flavorLbl.text      = "\"\(item.flavorText)\""
        flavorLbl.fontSize  = 10
        flavorLbl.fontColor = SKColor(white: 0.5, alpha: 1)
        flavorLbl.verticalAlignmentMode   = .center
        flavorLbl.horizontalAlignmentMode = .center
        flavorLbl.position = CGPoint(x: 0, y: curY)
        panel.addChild(flavorLbl)

        // Equip / Store buttons
        let equipBtn = makeSmallButton(text: "✓ Equip", color: SKColor(red: 0.15, green: 0.5, blue: 0.2, alpha: 1))
        equipBtn.position = CGPoint(x: -65, y: -panelHeight / 2 + 30)
        equipBtn.name = "equipBtn_\(item.id.uuidString)"
        panel.addChild(equipBtn)

        let keepBtn = makeSmallButton(text: "Store", color: SKColor(white: 0.2, alpha: 1))
        keepBtn.position = CGPoint(x: 65, y: -panelHeight / 2 + 30)
        keepBtn.name = "keepBtn"
        panel.addChild(keepBtn)

        addChild(panel)
        resultPanel = panel

        panel.setScale(0.4)
        panel.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.05, duration: 0.2),
                SKAction.fadeIn(withDuration: 0.2),
            ]),
            SKAction.scale(to: 1.0, duration: 0.08),
        ]))

        if item.rarity == .legendary { addLegendarySparkle(at: panel.position) }
    }

    // MARK: - Comparison helpers

    private struct StatRow {
        let label: String
        let oldStr: String
        let newStr: String
        let diff: Double
        let diffStr: String
    }

    private func buildStatRows(item: Equipment, equipped: Equipment?) -> [StatRow] {
        func fmt(_ v: Double) -> String {
            v.truncatingRemainder(dividingBy: 1) == 0 ? "+\(Int(v))" : "+\(String(format: "%.1f", v))"
        }
        func fmtDiff(_ v: Double) -> String {
            let a = abs(v)
            return a.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(a))" : String(format: "%.1f", a)
        }

        var rows: [StatRow] = []
        let e = equipped?.stats
        let n = item.stats

        func row(_ label: String, old: Double, new: Double) {
            guard old != 0 || new != 0 else { return }
            rows.append(StatRow(label: label,
                                oldStr: old > 0 ? fmt(old) : "—",
                                newStr: new > 0 ? fmt(new) : "—",
                                diff: new - old,
                                diffStr: fmtDiff(new - old)))
        }
        row("ATK",  old: Double(e?.attack      ?? 0), new: Double(n.attack))
        row("DEF",  old: Double(e?.defense     ?? 0), new: Double(n.defense))
        row("HP",   old: Double(e?.maxHP       ?? 0), new: Double(n.maxHP))
        row("SPD",  old: e?.speed       ?? 0,         new: n.speed)
        row("ASPD", old: e?.attackSpeed ?? 0,         new: n.attackSpeed)
        return rows
    }

    private func addForgeHeader(_ text: String, x: CGFloat, y: CGFloat, to parent: SKNode, panelW: CGFloat) {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 9
        lbl.fontColor = SKColor(white: 0.45, alpha: 1)
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position  = CGPoint(x: x, y: y)
        parent.addChild(lbl)
    }

    private func makeForgeLbl(_ text: String, color: SKColor,
                               align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 11
        lbl.fontColor = color
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = align
        return lbl
    }

    private func makeSmallButton(text: String, color: SKColor) -> SKNode {
        let container = SKNode()
        let bg = SKShapeNode(rectOf: CGSize(width: 100, height: 36), cornerRadius: 8)
        bg.fillColor   = color
        bg.strokeColor = color.withAlphaComponent(0.6)
        bg.lineWidth   = 1.5
        container.addChild(bg)
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 14
        lbl.fontColor = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)
        return container
    }

    private func addLegendarySparkle(at pos: CGPoint) {
        let sparks = ["✨", "⭐", "💫", "🌟"]
        for i in 0..<12 {
            let spark = SKLabelNode(text: sparks.randomElement()!)
            spark.fontSize = CGFloat.random(in: 10...20)
            let angle = Double(i) * (2 * .pi / 12)
            let radius = CGFloat.random(in: 60...120)
            spark.position = CGPoint(x: pos.x + cos(angle) * radius,
                                     y: pos.y + sin(angle) * radius)
            spark.alpha = 0
            addChild(spark)
            spark.run(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...0.4)),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.3),
                    SKAction.scale(to: 1.3, duration: 0.3),
                ]),
                SKAction.group([
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 20...60), duration: 0.5),
                ]),
                SKAction.removeFromParent(),
            ]))
        }
    }

    private func shakeForgeButton() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.05),
            SKAction.moveBy(x:  8, y: 0, duration: 0.05),
            SKAction.moveBy(x: -6, y: 0, duration: 0.04),
            SKAction.moveBy(x:  6, y: 0, duration: 0.04),
            SKAction.moveBy(x:  0, y: 0, duration: 0),
        ])
        forgeButton.run(shake)

        let noMetal = FloatingTextNode(text: "Not enough ⚙️", color: SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1))
        noMetal.position = CGPoint(x: 0, y: 30)
        addChild(noMetal)
        noMetal.animate(riseDistance: 35, duration: 1.0)
    }

    // MARK: - Labels

    private func updateLabels() {
        metalLabel.text = "⚙️ Metal: \(pd.metal)"
        let cost = BlacksmithSystem.metalCost(for: gm.currentCastle)
        costLabel.text  = "Cost: \(cost) metal  (Castle \(gm.currentCastle))"
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt = touch.location(in: self)
        let hit = nodes(at: pt)

        for node in hit {
            let name = node.name ?? node.parent?.name ?? ""
            if name == "forgeBtn"  { startForge(); return }
            if name == "backBtn"   { onClose?(); return }
            if name == "keepBtn"   {
                resultPanel?.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent(),
                ]))
                resultPanel = nil
                return
            }
            if name.hasPrefix("equipBtn_") {
                let idStr = String(name.dropFirst("equipBtn_".count))
                if let item = pd.inventory.first(where: { $0.id.uuidString == idStr }) {
                    pd.equip(item)
                    gm.save()
                    resultPanel?.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.15),
                        SKAction.removeFromParent(),
                    ]))
                    resultPanel = nil
                    let equipped = FloatingTextNode(text: "Equipped!", color: SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1))
                    equipped.position = CGPoint(x: 0, y: 60)
                    addChild(equipped)
                    equipped.animate()
                }
                return
            }
        }
    }
}
