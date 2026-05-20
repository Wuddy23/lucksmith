import Foundation

// MARK: - Game State

enum GameState {
    case playing
    case blacksmith
    case inventory
    case dead
    case castleComplete
}

// MARK: - Game Manager (singleton)

class GameManager {

    static let shared = GameManager()
    private init() { load() }

    var player: PlayerData = PlayerData()
    var currentCastle: Int = 1
    var currentFloor:  Int = 1
    var state: GameState = .playing

    // Notification names for scene communication
    static let didForgeEquipment  = Notification.Name("didForgeEquipment")
    static let didEquipItem       = Notification.Name("didEquipItem")
    static let didAdvanceFloor    = Notification.Name("didAdvanceFloor")
    static let didPlayerDie       = Notification.Name("didPlayerDie")
    static let stateChanged       = Notification.Name("gameStateChanged")

    // MARK: - Floor Progression

    var floorDescription: String {
        "Castle \(currentCastle)  ·  Floor \(currentFloor) / 10"
    }

    func advanceFloor() {
        if currentFloor < 10 {
            currentFloor += 1
            player.fullHeal()
        } else {
            castleComplete()
        }
        save()
        NotificationCenter.default.post(name: GameManager.didAdvanceFloor, object: nil)
    }

    private func castleComplete() {
        currentCastle += 1
        currentFloor  = 1
        player.fullHeal()
        setState(.castleComplete)
    }

    func continueAfterCastleComplete() {
        setState(.playing)
        save()
    }

    // MARK: - Death

    func handlePlayerDeath() {
        setState(.dead)
        NotificationCenter.default.post(name: GameManager.didPlayerDie, object: nil)
    }

    func respawnAtFloorStart(costGold: Int) {
        guard player.gold >= costGold else { return }
        player.gold -= costGold
        player.fullHeal()
        setState(.playing)
        save()
    }

    func respawnAtCastleStart() {
        currentFloor = 1
        player.fullHeal()
        setState(.playing)
        save()
    }

    // MARK: - Blacksmith

    func canForge() -> Bool {
        player.metal >= BlacksmithSystem.metalCost(for: currentCastle)
    }

    @discardableResult
    func forge() -> Equipment? {
        let cost = BlacksmithSystem.metalCost(for: currentCastle)
        guard player.metal >= cost else { return nil }
        player.metal -= cost
        let item = BlacksmithSystem.forge(metalSpent: cost, castleLevel: currentCastle)
        if player.inventory.count < PlayerData.inventoryMax {
            player.inventory.append(item)
        }
        save()
        NotificationCenter.default.post(name: GameManager.didForgeEquipment, object: item)
        return item
    }

    // MARK: - State

    func setState(_ newState: GameState) {
        state = newState
        NotificationCenter.default.post(name: GameManager.stateChanged, object: newState)
    }

    // MARK: - Save / Load (UserDefaults + JSON)

    private let playerKey  = "lucksmith_player"
    private let castleKey  = "lucksmith_castle"
    private let floorKey   = "lucksmith_floor"

    func save() {
        if let data = try? JSONEncoder().encode(player) {
            UserDefaults.standard.set(data, forKey: playerKey)
        }
        UserDefaults.standard.set(currentCastle, forKey: castleKey)
        UserDefaults.standard.set(currentFloor,  forKey: floorKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: playerKey),
           let saved = try? JSONDecoder().decode(PlayerData.self, from: data) {
            player = saved
        }
        currentCastle = UserDefaults.standard.integer(forKey: castleKey)
        currentFloor  = UserDefaults.standard.integer(forKey: floorKey)
        if currentCastle < 1 { currentCastle = 1 }
        if currentFloor  < 1 { currentFloor  = 1 }
    }

    func resetGame() {
        player        = PlayerData()
        currentCastle = 1
        currentFloor  = 1
        state         = .playing
        save()
    }
}
