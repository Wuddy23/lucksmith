import SpriteKit

class InventoryScene: SKScene {

    var onClose: (() -> Void)?

    private let gm = GameManager.shared
    private var pd: PlayerData { gm.player }

    private var selectedItem: Equipment?
    private var itemNodes: [SKNode] = []
    private var detailPanel: SKNode?
    private var scrollOffset: CGFloat = 0
    private var lastTouchY: CGFloat?

    private let rowHeight: CGFloat  = 68
    private let panelTop:  CGFloat  = 320   // y in scene coords from center

    override func didMove(to view: SKView) {
        size = view.frame.size
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1)
        buildEquippedPanel()
        buildInventoryList()
    }

    // MARK: - Equipped gear panel (top)

    private func buildEquippedPanel() {
        let panelH: CGFloat = 200
        let bg = SKShapeNode(rectOf: CGSize(width: size.width - 20, height: panelH), cornerRadius: 12)
        bg.fillColor   = SKColor(white: 0.08, alpha: 0.9)
        bg.strokeColor = SKColor(white: 0.3, alpha: 0.5)
        bg.lineWidth   = 1
        bg.position    = CGPoint(x: 0, y: size.height / 2 - panelH / 2 - 10)
        addChild(bg)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text      = "Equipped"
        title.fontSize  = 16
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -size.width / 2 + 24, y: bg.position.y + panelH / 2 - 22)
        addChild(title)

        let slots = EquipmentSlot.allCases
        let spacing = (size.width - 40) / CGFloat(slots.count)
        for (i, slot) in slots.enumerated() {
            let x = -size.width / 2 + 20 + spacing * CGFloat(i) + spacing / 2
            let y = bg.position.y - 8
            addEquippedSlot(slot: slot, x: x, y: y)
        }
    }

    private func addEquippedSlot(slot: EquipmentSlot, x: CGFloat, y: CGFloat) {
        let slotBG = SKShapeNode(rectOf: CGSize(width: 58, height: 70), cornerRadius: 8)
        slotBG.fillColor   = SKColor(white: 0.12, alpha: 0.8)
        slotBG.strokeColor = SKColor(white: 0.3, alpha: 0.5)
        slotBG.lineWidth   = 1
        slotBG.position    = CGPoint(x: x, y: y)
        addChild(slotBG)

        let slotIcon = SKLabelNode(text: slot.icon)
        slotIcon.fontSize = 24
        slotIcon.verticalAlignmentMode   = .center
        slotIcon.horizontalAlignmentMode = .center
        slotIcon.position = CGPoint(x: x, y: y + 14)
        addChild(slotIcon)

        if let equipped = pd.equipped(slot: slot) {
            let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nameLbl.text      = equipped.name
            nameLbl.fontSize  = 8
            nameLbl.fontColor = equipped.rarity.color
            nameLbl.verticalAlignmentMode   = .center
            nameLbl.horizontalAlignmentMode = .center
            nameLbl.preferredMaxLayoutWidth = 56
            nameLbl.numberOfLines = 2
            nameLbl.position = CGPoint(x: x, y: y - 20)
            addChild(nameLbl)
        } else {
            let emptyLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            emptyLbl.text      = slot.rawValue
            emptyLbl.fontSize  = 8
            emptyLbl.fontColor = SKColor(white: 0.35, alpha: 1)
            emptyLbl.verticalAlignmentMode   = .center
            emptyLbl.horizontalAlignmentMode = .center
            emptyLbl.position = CGPoint(x: x, y: y - 20)
            addChild(emptyLbl)
        }
    }

    // MARK: - Stats summary

    private func addStatsSummary() {
        let yBase: CGFloat = size.height / 2 - 225

        let statsText = "ATK \(pd.totalAttack)  DEF \(pd.totalDefense)  HP \(pd.totalMaxHP)  SPD \(Int(pd.totalSpeed))  ASPD \(String(format: "%.1f", pd.totalAttackSpeed))/s"
        let statsLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statsLbl.text      = statsText
        statsLbl.fontSize  = 12
        statsLbl.fontColor = SKColor(white: 0.7, alpha: 1)
        statsLbl.verticalAlignmentMode   = .center
        statsLbl.horizontalAlignmentMode = .center
        statsLbl.position = CGPoint(x: 0, y: yBase)
        addChild(statsLbl)
    }

    // MARK: - Inventory list (scrollable)

    private func buildInventoryList() {
        addStatsSummary()

        let listTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        listTitle.text      = "Inventory (\(pd.inventory.count)/\(PlayerData.inventoryMax))"
        listTitle.fontSize  = 15
        listTitle.fontColor = .white
        listTitle.verticalAlignmentMode   = .center
        listTitle.horizontalAlignmentMode = .left
        listTitle.position = CGPoint(x: -size.width / 2 + 24, y: size.height / 2 - 250)
        addChild(listTitle)

        // Back button
        let backBtn = makeButton(text: "← Back", y: -size.height / 2 + 50)
        backBtn.name = "backBtn"
        addChild(backBtn)

        refreshInventoryRows()
    }

    private func refreshInventoryRows() {
        itemNodes.forEach { $0.removeFromParent() }
        itemNodes.removeAll()

        let listTop:  CGFloat = size.height / 2 - 278
        let rowWidth: CGFloat = size.width - 24

        for (i, item) in pd.inventory.enumerated() {
            let y = listTop - rowHeight / 2 - rowHeight * CGFloat(i) + scrollOffset
            guard y > -size.height / 2 + 80 && y < size.height / 2 - 260 else { continue }

            let row = buildItemRow(item: item, width: rowWidth, y: y)
            row.name = "item_\(item.id.uuidString)"
            addChild(row)
            itemNodes.append(row)
        }

        if pd.inventory.isEmpty {
            let empty = SKLabelNode(fontNamed: "AvenirNext-Bold")
            empty.text      = "No items in inventory"
            empty.fontSize  = 14
            empty.fontColor = SKColor(white: 0.4, alpha: 1)
            empty.verticalAlignmentMode   = .center
            empty.horizontalAlignmentMode = .center
            empty.position = CGPoint(x: 0, y: size.height / 2 - 320)
            empty.name = "emptyLabel"
            addChild(empty)
            itemNodes.append(empty)
        }
    }

    private func buildItemRow(item: Equipment, width: CGFloat, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: y)

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: rowHeight - 4), cornerRadius: 8)
        bg.fillColor   = SKColor(white: 0.1, alpha: 0.85)
        bg.strokeColor = item.rarity.color.withAlphaComponent(0.4)
        bg.lineWidth   = 1.2
        container.addChild(bg)

        // Slot icon
        let icon = SKLabelNode(text: item.slot.icon)
        icon.fontSize = 22
        icon.verticalAlignmentMode   = .center
        icon.horizontalAlignmentMode = .center
        icon.position = CGPoint(x: -width / 2 + 28, y: 0)
        container.addChild(icon)

        // Item name
        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.text      = item.name
        name.fontSize  = 14
        name.fontColor = item.rarity.color
        name.verticalAlignmentMode   = .center
        name.horizontalAlignmentMode = .left
        name.position = CGPoint(x: -width / 2 + 52, y: 12)
        container.addChild(name)

        // Stats line
        let stats = SKLabelNode(fontNamed: "AvenirNext-Bold")
        stats.text      = item.statDescription
        stats.fontSize  = 10
        stats.fontColor = SKColor(white: 0.65, alpha: 1)
        stats.verticalAlignmentMode   = .center
        stats.horizontalAlignmentMode = .left
        stats.position = CGPoint(x: -width / 2 + 52, y: -10)
        container.addChild(stats)

        // Equip button
        let btn = SKShapeNode(rectOf: CGSize(width: 60, height: 28), cornerRadius: 6)
        btn.fillColor   = SKColor(red: 0.15, green: 0.45, blue: 0.2, alpha: 1)
        btn.strokeColor = SKColor(red: 0.25, green: 0.65, blue: 0.3, alpha: 0.7)
        btn.lineWidth   = 1.2
        btn.position    = CGPoint(x: width / 2 - 38, y: 0)
        btn.name        = "equipRowBtn_\(item.id.uuidString)"
        container.addChild(btn)

        let btnLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        btnLbl.text      = "Equip"
        btnLbl.fontSize  = 12
        btnLbl.fontColor = .white
        btnLbl.verticalAlignmentMode   = .center
        btnLbl.horizontalAlignmentMode = .center
        btnLbl.position = btn.position
        btnLbl.name = btn.name
        container.addChild(btnLbl)

        return container
    }

    private func makeButton(text: String, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: y)

        let bg = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 10)
        bg.fillColor   = SKColor(white: 0.18, alpha: 0.9)
        bg.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        bg.lineWidth   = 1.5
        container.addChild(bg)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 16
        lbl.fontColor = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)

        return container
    }

    // MARK: - Touch / Scroll

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchY = touch.location(in: self).y
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let last = lastTouchY else { return }
        let pt  = touch.location(in: self)
        let dy  = pt.y - last
        lastTouchY = pt.y

        let maxScroll: CGFloat = max(0, rowHeight * CGFloat(pd.inventory.count) - 200)
        scrollOffset = max(-maxScroll, min(0, scrollOffset + dy))
        refreshInventoryRows()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt  = touch.location(in: self)
        let hit = nodes(at: pt)
        lastTouchY = nil

        for node in hit {
            let name = node.name ?? node.parent?.name ?? ""
            if name == "backBtn" {
                onClose?()
                return
            }
            if name.hasPrefix("equipRowBtn_") {
                let idStr = String(name.dropFirst("equipRowBtn_".count))
                if let item = pd.inventory.first(where: { $0.id.uuidString == idStr }) {
                    pd.equip(item)
                    gm.save()
                    rebuildAll()
                }
                return
            }
        }
    }

    private func rebuildAll() {
        removeAllChildren()
        itemNodes.removeAll()
        detailPanel = nil
        buildEquippedPanel()
        buildInventoryList()
    }
}
