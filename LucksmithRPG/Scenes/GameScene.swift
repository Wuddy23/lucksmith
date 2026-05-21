import SpriteKit
import GameplayKit

// MARK: - Loot drop

private struct LootDrop {
    enum Kind { case gold(Int), metal(Int) }
    let kind: Kind
    var node: SKNode
    var xPos: CGFloat
}

// MARK: - Player state machine

private enum PlayerState {
    case walkingToEnemy
    case fighting
    case walkingToLoot
    case idle
    case dead
    case transitioning
}

// MARK: - GameScene

class GameScene: SKScene {

    // ── World ─────────────────────────────────────────────────────────────────
    private let worldNode   = SKNode()
    private let cameraNode  = SKCameraNode()
    private var floorLength: CGFloat = 2200

    // Floor decoration nodes (reused)
    private var floorTiles: [SKShapeNode] = []
    private var wallTorches: [SKNode]     = []

    // ── Game objects ──────────────────────────────────────────────────────────
    private var playerNode = PlayerNode()
    private var enemyNodes: [EnemyNode]  = []
    private var lootDrops:  [LootDrop]   = []

    // ── State ─────────────────────────────────────────────────────────────────
    private var playerState: PlayerState = .walkingToEnemy
    private var targetEnemy: EnemyNode?  = nil
    private var gm: GameManager          { GameManager.shared }
    private var pd: PlayerData           { gm.player }

    // ── HUD ───────────────────────────────────────────────────────────────────
    private let hud = HUDNode()

    // ── Timing ────────────────────────────────────────────────────────────────
    private var lastUpdateTime: TimeInterval = 0

    // ── Floor exit ────────────────────────────────────────────────────────────
    private var exitDoorNode:    SKNode?  = nil
    private var exitDoorVisible: Bool     = false

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.06, blue: 0.12, alpha: 1)
        physicsWorld.gravity = .zero

        setupCamera()
        setupWorld()
        spawnFloor()
        setupHUD()
        refreshHUD()

        NotificationCenter.default.addObserver(self, selector: #selector(onStateChanged),
                                               name: GameManager.stateChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupWorld() {
        addChild(worldNode)
    }

    private func setupHUD() {
        hud.layout(size: size)
        hud.onBlacksmith = { [weak self] in self?.openBlacksmith() }
        hud.onInventory  = { [weak self] in self?.openInventory()  }
        cameraNode.addChild(hud)
    }

    // MARK: - Floor construction

    private func spawnFloor() {
        worldNode.removeAllChildren()
        enemyNodes.removeAll()
        lootDrops.removeAll()
        exitDoorNode    = nil
        exitDoorVisible = false

        let tileSize: CGFloat  = 80
        let floorY: CGFloat    = -size.height * 0.15
        let floorH: CGFloat    = 60

        // Ground
        let ground = SKShapeNode(rectOf: CGSize(width: floorLength + 400, height: floorH))
        ground.fillColor   = SKColor(red: 0.22, green: 0.18, blue: 0.14, alpha: 1)
        ground.strokeColor = SKColor(red: 0.35, green: 0.28, blue: 0.22, alpha: 1)
        ground.lineWidth   = 2
        ground.position    = CGPoint(x: floorLength / 2, y: floorY - floorH / 2)
        worldNode.addChild(ground)

        // Stone tiles along the ground
        var tileX: CGFloat = 0
        while tileX <= floorLength + 200 {
            let tile = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: floorH - 4))
            tile.fillColor   = Bool.random()
                ? SKColor(red: 0.26, green: 0.22, blue: 0.18, alpha: 1)
                : SKColor(red: 0.20, green: 0.17, blue: 0.14, alpha: 1)
            tile.strokeColor = SKColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 0.6)
            tile.lineWidth   = 1
            tile.position    = CGPoint(x: tileX, y: floorY - floorH / 2)
            worldNode.addChild(tile)
            tileX += tileSize
        }

        // Ceiling
        let ceilY = size.height * 0.42
        let ceil  = SKShapeNode(rectOf: CGSize(width: floorLength + 400, height: 30))
        ceil.fillColor   = SKColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1)
        ceil.strokeColor = .clear
        ceil.position    = CGPoint(x: floorLength / 2, y: ceilY)
        worldNode.addChild(ceil)

        // Pillars every 300pts
        var pillarX: CGFloat = 150
        while pillarX < floorLength {
            addPillar(x: pillarX, groundY: floorY, ceilY: ceilY)
            pillarX += 300
        }

        // Torch lights every 400pts
        var torchX: CGFloat = 200
        while torchX < floorLength {
            addTorch(x: torchX, y: ceilY - 20)
            torchX += 400
        }

        // Player spawn
        let spawnX: CGFloat = 60
        playerNode = PlayerNode()
        playerNode.position = CGPoint(x: spawnX, y: floorY)
        worldNode.addChild(playerNode)
        playerState = .walkingToEnemy
        pd.fullHeal()

        // Camera start
        cameraNode.position = CGPoint(x: spawnX, y: 0)

        // Enemies
        spawnEnemies(floorY: floorY)
    }

    private func addPillar(x: CGFloat, groundY: CGFloat, ceilY: CGFloat) {
        let height = ceilY - groundY
        let pillar = SKShapeNode(rectOf: CGSize(width: 22, height: height))
        pillar.fillColor   = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1)
        pillar.strokeColor = SKColor(red: 0.4, green: 0.34, blue: 0.26, alpha: 0.7)
        pillar.lineWidth   = 1.5
        pillar.position    = CGPoint(x: x, y: groundY + height / 2)
        worldNode.addChild(pillar)
    }

    private func addTorch(x: CGFloat, y: CGFloat) {
        let base = SKShapeNode(rectOf: CGSize(width: 8, height: 14))
        base.fillColor   = SKColor(red: 0.5, green: 0.35, blue: 0.1, alpha: 1)
        base.strokeColor = .clear
        base.position    = CGPoint(x: x, y: y)
        worldNode.addChild(base)

        let flame = SKLabelNode(text: "🔥")
        flame.fontSize = 14
        flame.verticalAlignmentMode = .center
        flame.position = CGPoint(x: x, y: y + 12)
        worldNode.addChild(flame)

        // Flicker
        let flicker = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.15),
            SKAction.scale(to: 0.85, duration: 0.15),
        ])
        flame.run(SKAction.repeatForever(flicker))
    }

    private func spawnEnemies(floorY: CGFloat) {
        let types = FloorSpawnTable.enemies(floor: gm.currentFloor, castle: gm.currentCastle)
        var xPos: CGFloat = 320

        for type in types {
            let enemy = EnemyInstance(type: type, castle: gm.currentCastle)
            let node  = EnemyNode(instance: enemy)
            node.position = CGPoint(x: xPos, y: floorY)
            worldNode.addChild(node)
            enemyNodes.append(node)

            // Idle patrol wobble
            let wobble = SKAction.sequence([
                SKAction.moveBy(x: -8, y: 0, duration: 1.2),
                SKAction.moveBy(x:  8, y: 0, duration: 1.2),
            ])
            node.run(SKAction.repeatForever(wobble), withKey: "patrol")

            xPos += type.isBoss ? 260 : 200
        }

        // Exit door at the end
        exitDoorNode = makeExitDoor(x: xPos + 100, y: floorY)
        worldNode.addChild(exitDoorNode!)
        exitDoorNode?.alpha = 0  // hidden until enemies cleared
    }

    private func makeExitDoor(x: CGFloat, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: x, y: y)

        let door = SKShapeNode(rectOf: CGSize(width: 50, height: 80), cornerRadius: 4)
        door.fillColor   = SKColor(red: 0.55, green: 0.38, blue: 0.18, alpha: 1)
        door.strokeColor = SKColor(red: 0.7, green: 0.5, blue: 0.25, alpha: 1)
        door.lineWidth   = 3
        door.position    = CGPoint(x: 0, y: 40)
        container.addChild(door)

        let arrow = SKLabelNode(text: "➡️")
        arrow.fontSize = 22
        arrow.position = CGPoint(x: 0, y: 40)
        container.addChild(arrow)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 0.9, duration: 0.5),
        ])
        arrow.run(SKAction.repeatForever(pulse))

        let sign = SKLabelNode(fontNamed: "AvenirNext-Bold")
        sign.text      = "NEXT FLOOR"
        sign.fontSize  = 11
        sign.fontColor = SKColor(red: 1, green: 0.9, blue: 0.6, alpha: 1)
        sign.position  = CGPoint(x: 0, y: 92)
        container.addChild(sign)

        return container
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        guard gm.state == .playing else { return }

        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.1)
        lastUpdateTime = currentTime

        switch playerState {
        case .walkingToEnemy:   updateWalkToEnemy(dt)
        case .fighting:         updateFighting(dt)
        case .walkingToLoot:    updateWalkToLoot(dt)
        case .idle:             updateIdle()
        case .dead:             break
        case .transitioning:    break
        }

        updateEnemyTimers(dt)
        followCamera()
    }

    // Walking toward the nearest live enemy
    private func updateWalkToEnemy(_ dt: Double) {
        guard let enemy = nearestLivingEnemy() else {
            // No enemies left — pick up loot or idle/proceed
            if !lootDrops.isEmpty {
                playerState = .walkingToLoot
            } else {
                playerState = .idle
                showExitDoor()
            }
            return
        }

        targetEnemy = enemy
        let dist = enemy.position.x - playerNode.position.x
        let range = pd.totalAttackRange

        if abs(dist) <= range {
            playerState = .fighting
        } else {
            let dir: CGFloat = dist > 0 ? 1 : -1
            playerNode.setFacingRight(dir > 0)
            playerNode.position.x += dir * CGFloat(pd.totalSpeed) * CGFloat(dt)
        }
    }

    // In-combat: player attacks
    private func updateFighting(_ dt: Double) {
        guard let enemy = targetEnemy, enemy.instance.isAlive, !enemy.isDying else {
            playerState = .walkingToEnemy
            targetEnemy = nil
            return
        }

        // Keep facing enemy
        playerNode.setFacingRight(enemy.position.x > playerNode.position.x)

        // Advance player attack cooldown
        playerNode.attackCooldown += dt
        let attackInterval = 1.0 / pd.totalAttackSpeed

        if playerNode.attackCooldown >= attackInterval {
            playerNode.attackCooldown = 0
            performPlayerAttack(on: enemy)
        }

        // Check if enemy still alive after attack
        if !enemy.instance.isAlive {
            killEnemy(enemy)
        }
    }

    private func performPlayerAttack(on enemy: EnemyNode) {
        let damage = enemy.instance.takeDamage(pd.totalAttack)
        enemy.updateHP()
        enemy.playHitAnimation()

        let dir: CGFloat = enemy.position.x > playerNode.position.x ? 1 : -1
        playerNode.playAttackAnimation(toward: dir)

        let floater = FloatingTextNode.damage(damage)
        floater.position = CGPoint(x: enemy.position.x,
                                   y: enemy.position.y + 80)
        worldNode.addChild(floater)
        floater.animate()
    }

    // Enemies auto-attack the player
    private func updateEnemyTimers(_ dt: Double) {
        guard playerState == .fighting, let target = targetEnemy, !target.isDying else { return }
        target.attackTimer += dt
        if target.attackTimer >= target.instance.attackInterval {
            target.attackTimer = 0
            performEnemyAttack(from: target)
        }
    }

    private func performEnemyAttack(from enemy: EnemyNode) {
        let damage = pd.takeDamage(enemy.instance.attack)
        playerNode.playHitAnimation()
        refreshHPBar()

        let floater = FloatingTextNode.damage(damage)
        floater.position = CGPoint(x: playerNode.position.x,
                                   y: playerNode.position.y + 80)
        worldNode.addChild(floater)
        floater.animate()

        if !pd.isAlive {
            handlePlayerDeath()
        }
    }

    private func killEnemy(_ enemy: EnemyNode) {
        enemy.removeAction(forKey: "patrol")
        playerState = .walkingToEnemy
        targetEnemy = nil

        let gold  = enemy.instance.goldReward
        let metal = enemy.instance.metalReward

        pd.gold  += gold
        pd.metal += metal
        pd.addExperience(enemy.instance.type.expReward)
        refreshHUD()

        let dropY = enemy.position.y + 30
        spawnLoot(gold: gold, metal: metal, x: enemy.position.x, y: dropY)

        enemy.playDeathAnimation { }
        enemyNodes.removeAll { $0 === enemy }

        // Show floating resource text
        if gold > 0 {
            let g = FloatingTextNode.gold(gold)
            g.position = CGPoint(x: enemy.position.x - 15, y: enemy.position.y + 60)
            worldNode.addChild(g)
            g.animate()
        }
        if metal > 0 {
            let m = FloatingTextNode.metal(metal)
            m.position = CGPoint(x: enemy.position.x + 15, y: enemy.position.y + 60)
            worldNode.addChild(m)
            m.animate()
        }
    }

    // Walk toward the closest loot
    private func updateWalkToLoot(_ dt: Double) {
        if lootDrops.isEmpty {
            playerState = .idle
            showExitDoor()
            return
        }

        let closest = lootDrops.min(by: {
            abs($0.xPos - playerNode.position.x) < abs($1.xPos - playerNode.position.x)
        })!
        let dist = closest.xPos - playerNode.position.x
        let collectRadius: CGFloat = 30

        if abs(dist) <= collectRadius {
            collectLoot(closest)
        } else {
            let dir: CGFloat = dist > 0 ? 1 : -1
            playerNode.setFacingRight(dir > 0)
            playerNode.position.x += dir * CGFloat(pd.totalSpeed * 0.7) * CGFloat(dt)
        }
    }

    private func collectLoot(_ drop: LootDrop) {
        drop.node.run(SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.07),
            SKAction.fadeOut(withDuration: 0.12),
            SKAction.removeFromParent(),
        ]))
        lootDrops.removeAll { $0.node === drop.node }
        refreshHUD()
    }

    private func spawnLoot(gold: Int, metal: Int, x: CGFloat, y: CGFloat) {
        if gold > 0 {
            let coin = makeCoinNode(color: SKColor(red: 1, green: 0.85, blue: 0.1, alpha: 1), text: "G")
            coin.position = CGPoint(x: x - 12, y: y)
            worldNode.addChild(coin)
            lootDrops.append(LootDrop(kind: .gold(gold), node: coin, xPos: x - 12))
        }
        if metal > 0 {
            let shard = makeCoinNode(color: SKColor(red: 0.6, green: 0.78, blue: 0.88, alpha: 1), text: "M")
            shard.position = CGPoint(x: x + 12, y: y)
            worldNode.addChild(shard)
            lootDrops.append(LootDrop(kind: .metal(metal), node: shard, xPos: x + 12))
        }
    }

    private func makeCoinNode(color: SKColor, text: String) -> SKNode {
        let container = SKNode()
        let circle    = SKShapeNode(circleOfRadius: 10)
        circle.fillColor   = color
        circle.strokeColor = color.withAlphaComponent(0.5)
        circle.lineWidth   = 1.5
        container.addChild(circle)

        let label = SKLabelNode(text: text)
        label.fontSize  = 9
        label.fontColor = SKColor(white: 0.1, alpha: 1)
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)

        // Bounce in
        container.setScale(0)
        container.run(SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.07),
        ]))
        return container
    }

    // Floor cleared — show door
    private func updateIdle() {
        if !exitDoorVisible && enemyNodes.isEmpty {
            showExitDoor()
        }
        // Check if player reached the exit door
        if let door = exitDoorNode {
            let dist = abs(door.position.x - playerNode.position.x)
            if dist < 55 && exitDoorVisible {
                playerState = .transitioning
                advanceToNextFloor()
            } else if exitDoorVisible {
                let dt = 1.0 / 60.0  // approximate
                let dir: CGFloat = door.position.x > playerNode.position.x ? 1 : -1
                playerNode.setFacingRight(dir > 0)
                playerNode.position.x += dir * CGFloat(pd.totalSpeed) * CGFloat(dt)
            }
        }
    }

    private func showExitDoor() {
        guard !exitDoorVisible else { return }
        exitDoorVisible = true
        exitDoorNode?.run(SKAction.fadeIn(withDuration: 0.4))

        let banner = FloatingTextNode.status("Floor \(gm.currentFloor) Cleared! ✓")
        banner.position = CGPoint(x: playerNode.position.x + 80, y: playerNode.position.y + 100)
        worldNode.addChild(banner)
        banner.animate(riseDistance: 30, duration: 1.8)
    }

    private func advanceToNextFloor() {
        let flash = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.run { [weak self] in
                guard let self else { return }
                GameManager.shared.advanceFloor()
                if GameManager.shared.state != .castleComplete {
                    self.spawnFloor()
                    self.refreshHUD()
                    self.playerState = .walkingToEnemy
                }
            },
            SKAction.fadeIn(withDuration: 0.3),
        ])
        run(flash)
    }

    // MARK: - Camera

    private func followCamera() {
        let target = playerNode.position.x
        let current = cameraNode.position.x
        cameraNode.position.x = current + (target - current) * 0.12
    }

    // MARK: - Player death

    private func handlePlayerDeath() {
        playerState = .dead
        playerNode.playDeathAnimation { }
        gm.handlePlayerDeath()
        showDeathOverlay()
    }

    private func showDeathOverlay() {
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor   = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        overlay.strokeColor = .clear
        overlay.position    = .zero
        overlay.zPosition   = 100
        cameraNode.addChild(overlay)

        overlay.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeAlpha(to: 0.65, duration: 0.4),
        ]))

        // Death title
        let deathLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        deathLabel.text      = "YOU DIED"
        deathLabel.fontSize  = 42
        deathLabel.fontColor = SKColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)
        deathLabel.verticalAlignmentMode   = .center
        deathLabel.horizontalAlignmentMode = .center
        deathLabel.position = CGPoint(x: 0, y: 60)
        deathLabel.zPosition = 101
        deathLabel.alpha = 0
        cameraNode.addChild(deathLabel)
        deathLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.3),
        ]))

        // Revive button
        let reviveCost = gm.currentFloor * 20
        let reviveBtn  = makeOverlayButton(text: "Revive (🪙 \(reviveCost))", y: -20, color: SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1))
        reviveBtn.zPosition = 101
        reviveBtn.alpha = 0
        reviveBtn.name = "reviveBtn_\(reviveCost)"
        cameraNode.addChild(reviveBtn)

        let restartBtn = makeOverlayButton(text: "Restart Floor 1", y: -75, color: SKColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 1))
        restartBtn.zPosition = 101
        restartBtn.alpha = 0
        restartBtn.name = "restartBtn"
        cameraNode.addChild(restartBtn)

        let showAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeIn(withDuration: 0.3),
        ])
        reviveBtn.run(showAction)
        restartBtn.run(showAction.copy() as! SKAction)
    }

    private func makeOverlayButton(text: String, y: CGFloat, color: SKColor) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: y)

        let bg = SKShapeNode(rectOf: CGSize(width: 240, height: 44), cornerRadius: 12)
        bg.fillColor   = color
        bg.strokeColor = color.withAlphaComponent(0.7)
        bg.lineWidth   = 2
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

    // MARK: - Overlays: Blacksmith & Inventory

    private func openBlacksmith() {
        guard gm.state == .playing else { return }
        let scene = BlacksmithScene(size: size)
        scene.scaleMode = .resizeFill
        scene.onClose = { [weak self] in
            guard let self = self else { return }
            self.view?.presentScene(self, transition: SKTransition.push(with: .right, duration: 0.3))
            self.refreshHUD()
        }
        view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: 0.3))
    }

    private func openInventory() {
        guard gm.state == .playing else { return }
        let scene = InventoryScene(size: size)
        scene.scaleMode = .resizeFill
        scene.onClose = { [weak self] in
            guard let self = self else { return }
            self.view?.presentScene(self, transition: SKTransition.push(with: .right, duration: 0.3))
            self.refreshHUD()
        }
        view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: 0.3))
    }

    // MARK: - HUD helpers

    private func refreshHUD() {
        refreshHPBar()
        hud.updateGold(pd.gold)
        hud.updateMetal(pd.metal)
        hud.updateFloor(gm.floorDescription)
        hud.updateLevel(pd.level)
    }

    private func refreshHPBar() {
        hud.updateHP(current: pd.currentHP, max: pd.totalMaxHP)
        playerNode.updateHP(current: pd.currentHP, maxHP: pd.totalMaxHP)
    }

    // MARK: - Nearest enemy helper

    private func nearestLivingEnemy() -> EnemyNode? {
        enemyNodes
            .filter { $0.instance.isAlive && !$0.isDying }
            .min(by: { abs($0.position.x - playerNode.position.x) < abs($1.position.x - playerNode.position.x) })
    }

    // MARK: - Notifications

    @objc private func onStateChanged(_ note: Notification) {
        guard let state = note.object as? GameState else { return }
        if state == .castleComplete {
            showCastleCompleteOverlay()
        }
    }

    private func showCastleCompleteOverlay() {
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor   = SKColor(white: 0, alpha: 0.7)
        overlay.strokeColor = .clear
        overlay.position    = .zero
        overlay.zPosition   = 100
        cameraNode.addChild(overlay)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text      = "🏰 Castle \(gm.currentCastle - 1) Complete!"
        title.fontSize  = 30
        title.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
        title.verticalAlignmentMode   = .center
        title.horizontalAlignmentMode = .center
        title.position  = CGPoint(x: 0, y: 50)
        title.zPosition = 101
        cameraNode.addChild(title)

        let sub = SKLabelNode(fontNamed: "AvenirNext-Bold")
        sub.text      = "Castle \(gm.currentCastle) awaits..."
        sub.fontSize  = 18
        sub.fontColor = .lightGray
        sub.verticalAlignmentMode   = .center
        sub.horizontalAlignmentMode = .center
        sub.position  = CGPoint(x: 0, y: 10)
        sub.zPosition = 101
        cameraNode.addChild(sub)

        let continueBtn = makeOverlayButton(text: "Continue ▶", y: -50, color: SKColor(red: 0.15, green: 0.4, blue: 0.75, alpha: 1))
        continueBtn.name      = "continueBtn"
        continueBtn.zPosition = 101
        cameraNode.addChild(continueBtn)
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let hudPoint   = touch.location(in: cameraNode)
        // HUD buttons
        hud.handleTouch(at: hudPoint)

        // Death / overlay buttons
        let nodes = cameraNode.nodes(at: hudPoint)
        for node in nodes {
            guard let name = node.parent?.name ?? node.name else { continue }
            if name.hasPrefix("reviveBtn_") {
                let cost = Int(name.split(separator: "_").last ?? "0") ?? 0
                handleRevive(cost: cost)
            } else if name == "restartBtn" {
                handleRestart()
            } else if name == "continueBtn" {
                handleContinue()
            }
        }
    }

    private func handleRevive(cost: Int) {
        if pd.gold >= cost {
            pd.gold -= cost
            pd.fullHeal()
            gm.setState(.playing)
            playerState = .walkingToEnemy
            cameraNode.removeAllChildren()
            setupHUD()
            refreshHUD()
            spawnFloor()
        }
    }

    private func handleRestart() {
        gm.respawnAtCastleStart()
        cameraNode.removeAllChildren()
        setupHUD()
        spawnFloor()
        refreshHUD()
        playerState = .walkingToEnemy
    }

    private func handleContinue() {
        gm.continueAfterCastleComplete()
        cameraNode.removeAllChildren()
        setupHUD()
        spawnFloor()
        refreshHUD()
        playerState = .walkingToEnemy
    }
}
