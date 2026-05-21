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

    private let rowHeight: CGFloat = 62
    private var panelW: CGFloat = 0

    override func didMove(to view: SKView) {
        size       = view.frame.size
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        panelW     = size.width - 20
        backgroundColor = SKColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1)
        buildEquippedPanel()
        buildInventoryList()
    }

    // MARK: - Equipped gear panel

    private func buildEquippedPanel() {
        let panelH: CGFloat = 190
        let bg = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 12)
        bg.fillColor   = SKColor(white: 0.08, alpha: 0.9)
        bg.strokeColor = SKColor(white: 0.3, alpha: 0.5)
        bg.lineWidth   = 1
        bg.position    = CGPoint(x: 0, y: size.height / 2 - panelH / 2 - 10)
        addChild(bg)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text      = "Equipped"
        title.fontSize  = 15
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -panelW / 2 + 20, y: bg.position.y + panelH / 2 - 20)
        addChild(title)

        let slots   = EquipmentSlot.allCases
        let spacing = (panelW - 20) / CGFloat(slots.count)
        for (i, slot) in slots.enumerated() {
            let x = -panelW / 2 + 10 + spacing * CGFloat(i) + spacing / 2
            addEquippedSlot(slot: slot, x: x, y: bg.position.y - 12)
        }
    }

    private func addEquippedSlot(slot: EquipmentSlot, x: CGFloat, y: CGFloat) {
        let slotBG = SKShapeNode(rectOf: CGSize(width: 56, height: 68), cornerRadius: 8)
        slotBG.fillColor   = SKColor(white: 0.12, alpha: 0.8)
        slotBG.strokeColor = SKColor(white: 0.3, alpha: 0.5)
        slotBG.lineWidth   = 1
        slotBG.position    = CGPoint(x: x, y: y)
        addChild(slotBG)

        let icon = SKLabelNode(text: slot.icon)
        icon.fontSize = 22
        icon.verticalAlignmentMode   = .center
        icon.horizontalAlignmentMode = .center
        icon.position = CGPoint(x: x, y: y + 14)
        addChild(icon)

        if let equipped = pd.equipped(slot: slot) {
            let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nameLbl.text      = equipped.name
            nameLbl.fontSize  = 7
            nameLbl.fontColor = equipped.rarity.color
            nameLbl.verticalAlignmentMode   = .center
            nameLbl.horizontalAlignmentMode = .center
            nameLbl.preferredMaxLayoutWidth = 54
            nameLbl.numberOfLines           = 2
            nameLbl.position = CGPoint(x: x, y: y - 22)
            addChild(nameLbl)
        } else {
            let emptyLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            emptyLbl.text      = "Empty"
            emptyLbl.fontSize  = 7
            emptyLbl.fontColor = SKColor(white: 0.35, alpha: 1)
            emptyLbl.verticalAlignmentMode   = .center
            emptyLbl.horizontalAlignmentMode = .center
            emptyLbl.position = CGPoint(x: x, y: y - 22)
            addChild(emptyLbl)
        }
    }

    // MARK: - Stats summary

    private func addStatsSummary() {
        let yBase: CGFloat = size.height / 2 - 215
        let statsText = "ATK \(pd.totalAttack)  DEF \(pd.totalDefense)  HP \(pd.totalMaxHP)  SPD \(Int(pd.totalSpeed))  ASPD \(String(format: "%.1f", pd.totalAttackSpeed))/s"
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = statsText
        lbl.fontSize  = 11
        lbl.fontColor = SKColor(white: 0.7, alpha: 1)
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: 0, y: yBase)
        addChild(lbl)
    }

    // MARK: - Inventory list

    private func buildInventoryList() {
        addStatsSummary()

        let listTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        listTitle.text      = "Inventory (\(pd.inventory.count)/\(PlayerData.inventoryMax))"
        listTitle.fontSize  = 14
        listTitle.fontColor = .white
        listTitle.verticalAlignmentMode   = .center
        listTitle.horizontalAlignmentMode = .left
        listTitle.position = CGPoint(x: -panelW / 2 + 10, y: size.height / 2 - 238)
        addChild(listTitle)

        let backBtn = makeButton(text: "← Back", y: -size.height / 2 + 50)
        backBtn.name = "backBtn"
        addChild(backBtn)

        refreshInventoryRows()
    }

    private func refreshInventoryRows() {
        itemNodes.forEach { $0.removeFromParent() }
        itemNodes.removeAll()

        let listTop:  CGFloat = size.height / 2 - 262
        let listBottom: CGFloat = -size.height / 2 + 70

        for (i, item) in pd.inventory.enumerated() {
            let y = listTop - rowHeight / 2 - rowHeight * CGFloat(i) + scrollOffset
            guard y > listBottom && y < listTop + rowHeight else { continue }

            let row = buildItemRow(item: item, y: y)
            row.name = "itemRow_\(item.id.uuidString)"
            addChild(row)
            itemNodes.append(row)
        }

        if pd.inventory.isEmpty {
            let empty = SKLabelNode(fontNamed: "AvenirNext-Bold")
            empty.text      = "No items in inventory"
            empty.fontSize  = 13
            empty.fontColor = SKColor(white: 0.4, alpha: 1)
            empty.verticalAlignmentMode   = .center
            empty.horizontalAlignmentMode = .center
            empty.position = CGPoint(x: 0, y: size.height / 2 - 310)
            empty.name = "emptyLabel"
            addChild(empty)
            itemNodes.append(empty)
        }
    }

    private func buildItemRow(item: Equipment, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: y)

        let isSelected = selectedItem?.id == item.id
        let bg = SKShapeNode(rectOf: CGSize(width: panelW, height: rowHeight - 4), cornerRadius: 8)
        bg.fillColor   = isSelected
            ? SKColor(white: 0.18, alpha: 0.9)
            : SKColor(white: 0.1,  alpha: 0.85)
        bg.strokeColor = isSelected
            ? item.rarity.color
            : item.rarity.color.withAlphaComponent(0.35)
        bg.lineWidth   = isSelected ? 2 : 1
        container.addChild(bg)

        let icon = SKLabelNode(text: item.slot.icon)
        icon.fontSize = 20
        icon.verticalAlignmentMode   = .center
        icon.horizontalAlignmentMode = .center
        icon.position = CGPoint(x: -panelW / 2 + 26, y: 4)
        container.addChild(icon)

        let nameLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLbl.text      = item.name
        nameLbl.fontSize  = 13
        nameLbl.fontColor = item.rarity.color
        nameLbl.verticalAlignmentMode   = .center
        nameLbl.horizontalAlignmentMode = .left
        nameLbl.position = CGPoint(x: -panelW / 2 + 48, y: 12)
        container.addChild(nameLbl)

        let statsLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statsLbl.text      = item.statDescription
        statsLbl.fontSize  = 9
        statsLbl.fontColor = SKColor(white: 0.65, alpha: 1)
        statsLbl.verticalAlignmentMode   = .center
        statsLbl.horizontalAlignmentMode = .left
        statsLbl.position = CGPoint(x: -panelW / 2 + 48, y: -8)
        container.addChild(statsLbl)

        let rarLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rarLbl.text      = item.rarity.rawValue
        rarLbl.fontSize  = 9
        rarLbl.fontColor = item.rarity.color.withAlphaComponent(0.85)
        rarLbl.verticalAlignmentMode   = .center
        rarLbl.horizontalAlignmentMode = .right
        rarLbl.position = CGPoint(x: panelW / 2 - 10, y: 0)
        container.addChild(rarLbl)

        return container
    }

    // MARK: - Detail / comparison panel

    private func showDetailPanel(for item: Equipment) {
        detailPanel?.removeFromParent()
        selectedItem = item
        refreshInventoryRows()

        let panelH: CGFloat = 230
        let panelY = -size.height / 2 + panelH / 2 + 70
        let equipped = pd.equipped(slot: item.slot)

        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 14)
        panel.fillColor   = SKColor(red: 0.07, green: 0.07, blue: 0.13, alpha: 0.97)
        panel.strokeColor = item.rarity.color
        panel.lineWidth   = 1.5
        panel.position    = CGPoint(x: 0, y: panelY)
        panel.zPosition   = 10
        panel.name        = "detailPanel"

        // Header
        let rarLbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        rarLbl.text      = "[ \(item.rarity.rawValue.uppercased()) ] \(item.slot.icon) \(item.name)"
        rarLbl.fontSize  = 13
        rarLbl.fontColor = item.rarity.color
        rarLbl.verticalAlignmentMode   = .center
        rarLbl.horizontalAlignmentMode = .center
        rarLbl.position = CGPoint(x: 0, y: panelH / 2 - 22)
        panel.addChild(rarLbl)

        // Comparison column headers
        let equippedLabel = equipped != nil ? "Equipped" : "(none)"
        addColumnHeader(equippedLabel, x: 30,  y: panelH / 2 - 44, to: panel)
        addColumnHeader("New Item",    x: 110, y: panelH / 2 - 44, to: panel)
        addColumnHeader("Change",      x: 185, y: panelH / 2 - 44, to: panel)

        // Stat rows
        let stats: [(String, Int, Int)] = [
            ("ATK",  equipped?.stats.attack      ?? 0, item.stats.attack),
            ("DEF",  equipped?.stats.defense     ?? 0, item.stats.defense),
            ("HP",   equipped?.stats.maxHP       ?? 0, item.stats.maxHP),
            ("SPD",  Int(equipped?.stats.speed   ?? 0), Int(item.stats.speed)),
            ("ASPD", 0, 0),
        ]
        // ASPD handled separately (Double)
        let aspdOld = equipped?.stats.attackSpeed ?? 0.0
        let aspdNew = item.stats.attackSpeed

        var rowY = panelH / 2 - 62
        let rowSpacing: CGFloat = 20
        for (label, oldVal, newVal) in stats where label != "ASPD" {
            guard oldVal != 0 || newVal != 0 else { continue }
            addComparisonRow(label: label,
                             oldStr: oldVal > 0 ? "+\(oldVal)" : "\(oldVal)",
                             newStr: newVal > 0 ? "+\(newVal)" : "\(newVal)",
                             diff: Double(newVal - oldVal),
                             y: rowY, to: panel)
            rowY -= rowSpacing
        }
        if aspdOld != 0 || aspdNew != 0 {
            addComparisonRow(label: "ASPD",
                             oldStr: aspdOld > 0 ? "+\(String(format: "%.1f", aspdOld))" : "—",
                             newStr: aspdNew > 0 ? "+\(String(format: "%.1f", aspdNew))" : "—",
                             diff: aspdNew - aspdOld,
                             y: rowY, to: panel)
            rowY -= rowSpacing
        }
        if item.stats == EquipmentStats.zero {
            let noneLbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
            noneLbl.text      = "No stat bonuses"
            noneLbl.fontSize  = 11
            noneLbl.fontColor = SKColor(white: 0.45, alpha: 1)
            noneLbl.verticalAlignmentMode   = .center
            noneLbl.horizontalAlignmentMode = .center
            noneLbl.position = CGPoint(x: 0, y: panelH / 2 - 72)
            panel.addChild(noneLbl)
        }

        // Action buttons
        let equipBtn  = makeSmallButton(text: "✓ Equip",  color: SKColor(red: 0.15, green: 0.5, blue: 0.2, alpha: 1))
        let recycleBtn = makeSmallButton(text: "♻ Recycle \(salvagePreview(item))",
                                         color: SKColor(red: 0.5, green: 0.25, blue: 0.05, alpha: 1))
        equipBtn.position   = CGPoint(x: -60, y: -panelH / 2 + 28)
        recycleBtn.position = CGPoint(x:  72, y: -panelH / 2 + 28)
        equipBtn.name   = "equipDetail_\(item.id.uuidString)"
        recycleBtn.name = "recycle_\(item.id.uuidString)"
        panel.addChild(equipBtn)
        panel.addChild(recycleBtn)

        addChild(panel)
        detailPanel = panel
    }

    private func addColumnHeader(_ text: String, x: CGFloat, y: CGFloat, to parent: SKNode) {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 9
        lbl.fontColor = SKColor(white: 0.5, alpha: 1)
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: x - (panelW / 2 - 10), y: y)
        parent.addChild(lbl)
    }

    private func addComparisonRow(label: String, oldStr: String, newStr: String,
                                   diff: Double, y: CGFloat, to parent: SKNode) {
        let ox = panelW / 2 - 10  // offset to convert panel-relative to local coords
        let green = SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
        let red   = SKColor(red: 0.95, green: 0.25, blue: 0.2, alpha: 1)
        let gray  = SKColor(white: 0.5, alpha: 1)

        func lbl(_ text: String, _ color: SKColor, _ align: SKLabelHorizontalAlignmentMode, _ px: CGFloat) -> SKLabelNode {
            let l = SKLabelNode(fontNamed: "AvenirNext-Bold")
            l.text = text; l.fontSize = 10; l.fontColor = color
            l.verticalAlignmentMode = .center
            l.horizontalAlignmentMode = align
            l.position = CGPoint(x: px - ox, y: y)
            return l
        }

        parent.addChild(lbl(label + ":", SKColor(white: 0.65, alpha: 1), .left,  10))
        parent.addChild(lbl(oldStr,       SKColor(white: 0.55, alpha: 1), .center, 60))
        parent.addChild(lbl("→",          gray,                           .center, 92))
        parent.addChild(lbl(newStr,        .white,                         .center, 122))
        let diffStr  = diff > 0 ? "▲\(formatDiff(diff))" : diff < 0 ? "▼\(formatDiff(-diff))" : "="
        let diffColor = diff > 0 ? green : diff < 0 ? red : gray
        parent.addChild(lbl(diffStr, diffColor, .center, 175))
    }

    private func formatDiff(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(val))" : String(format: "%.1f", val)
    }

    private func salvagePreview(_ item: Equipment) -> String {
        switch item.rarity {
        case .common:    return "⚙️1"
        case .uncommon:  return "⚙️3"
        case .rare:      return "⚙️5 🪙10"
        case .epic:      return "⚙️8 🪙25"
        case .legendary: return "⚙️15 🪙75"
        }
    }

    // MARK: - Helpers

    private func makeButton(text: String, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: y)
        let bg = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 10)
        bg.fillColor   = SKColor(white: 0.18, alpha: 0.9)
        bg.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        bg.lineWidth   = 1.5
        container.addChild(bg)
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text = text; lbl.fontSize = 16; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center; lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)
        return container
    }

    private func makeSmallButton(text: String, color: SKColor) -> SKNode {
        let container = SKNode()
        let bg = SKShapeNode(rectOf: CGSize(width: 110, height: 32), cornerRadius: 8)
        bg.fillColor   = color
        bg.strokeColor = color.withAlphaComponent(0.6)
        bg.lineWidth   = 1.5
        container.addChild(bg)
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text = text; lbl.fontSize = 11; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center; lbl.horizontalAlignmentMode = .center
        container.addChild(lbl)
        return container
    }

    private func rebuildAll() {
        removeAllChildren()
        itemNodes.removeAll()
        detailPanel = nil
        panelW = size.width - 20
        buildEquippedPanel()
        buildInventoryList()
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchY = touch.location(in: self).y
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let last = lastTouchY else { return }
        let pt = touch.location(in: self)
        let dy = pt.y - last
        lastTouchY = pt.y
        let maxScroll = max(0, rowHeight * CGFloat(pd.inventory.count) - 200)
        scrollOffset = max(-maxScroll, min(0, scrollOffset + dy))
        refreshInventoryRows()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pt  = touch.location(in: self)
        let hit = nodes(at: pt)
        lastTouchY = nil

        for node in hit {
            let name = node.name ?? node.parent?.name ?? node.parent?.parent?.name ?? ""

            if name == "backBtn" { onClose?(); return }

            if name.hasPrefix("equipDetail_") {
                let idStr = String(name.dropFirst("equipDetail_".count))
                if let item = pd.inventory.first(where: { $0.id.uuidString == idStr }) {
                    pd.equip(item)
                    gm.save()
                    selectedItem = nil
                    rebuildAll()
                }
                return
            }

            if name.hasPrefix("recycle_") {
                let idStr = String(name.dropFirst("recycle_".count))
                if let item = pd.inventory.first(where: { $0.id.uuidString == idStr }) {
                    let reward = pd.salvage(item)
                    gm.save()
                    selectedItem = nil
                    rebuildAll()
                    // Floating reward text
                    let msg = reward.gold > 0
                        ? "+⚙️\(reward.metal)  +🪙\(reward.gold)"
                        : "+⚙️\(reward.metal)"
                    let floater = FloatingTextNode(text: msg,
                                                   color: SKColor(red: 0.7, green: 0.85, blue: 0.4, alpha: 1))
                    floater.position = CGPoint(x: 0, y: -size.height / 2 + 160)
                    addChild(floater)
                    floater.animate(riseDistance: 50, duration: 1.2)
                }
                return
            }

            if name.hasPrefix("itemRow_") {
                let idStr = String(name.dropFirst("itemRow_".count))
                if let item = pd.inventory.first(where: { $0.id.uuidString == idStr }) {
                    if selectedItem?.id == item.id {
                        // Tap same item again → dismiss panel
                        selectedItem = nil
                        detailPanel?.removeFromParent()
                        detailPanel = nil
                        refreshInventoryRows()
                    } else {
                        showDetailPanel(for: item)
                    }
                }
                return
            }
        }

        // Tap outside detail panel → dismiss
        if let panel = detailPanel {
            let panelPt = convert(pt, to: panel)
            if !panel.contains(panelPt) {
                selectedItem = nil
                detailPanel?.removeFromParent()
                detailPanel = nil
                refreshInventoryRows()
            }
        }
    }
}
