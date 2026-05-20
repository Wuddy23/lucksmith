import Foundation
import SpriteKit

// MARK: - Enemy Types

enum EnemyType: String, Codable, CaseIterable {
    case slime      = "Slime"
    case goblin     = "Goblin"
    case orc        = "Orc"
    case skeleton   = "Skeleton"
    case vampire    = "Vampire"
    case golem      = "Golem"
    case darkKnight = "Dark Knight"
    case dragon     = "Dragon"
    case lich       = "Lich"
    case demonLord  = "Demon Lord"  // floor 10 boss

    var baseHP: Int {
        switch self {
        case .slime:      return 35
        case .goblin:     return 60
        case .orc:        return 110
        case .skeleton:   return 85
        case .vampire:    return 140
        case .golem:      return 240
        case .darkKnight: return 300
        case .dragon:     return 420
        case .lich:       return 380
        case .demonLord:  return 900
        }
    }

    var baseAttack: Int {
        switch self {
        case .slime:      return 4
        case .goblin:     return 9
        case .orc:        return 16
        case .skeleton:   return 13
        case .vampire:    return 20
        case .golem:      return 28
        case .darkKnight: return 36
        case .dragon:     return 45
        case .lich:       return 42
        case .demonLord:  return 65
        }
    }

    var baseDefense: Int {
        switch self {
        case .slime:      return 0
        case .goblin:     return 2
        case .orc:        return 8
        case .skeleton:   return 5
        case .vampire:    return 10
        case .golem:      return 22
        case .darkKnight: return 20
        case .dragon:     return 18
        case .lich:       return 14
        case .demonLord:  return 28
        }
    }

    var attackInterval: Double {  // seconds between attacks
        switch self {
        case .slime:      return 2.0
        case .goblin:     return 1.6
        case .orc:        return 2.2
        case .skeleton:   return 1.8
        case .vampire:    return 1.3
        case .golem:      return 3.0
        case .darkKnight: return 1.5
        case .dragon:     return 2.4
        case .lich:       return 1.4
        case .demonLord:  return 1.8
        }
    }

    var goldRange: ClosedRange<Int> {
        switch self {
        case .slime:      return 1...4
        case .goblin:     return 3...7
        case .orc:        return 5...10
        case .skeleton:   return 4...9
        case .vampire:    return 8...15
        case .golem:      return 12...20
        case .darkKnight: return 15...25
        case .dragon:     return 20...35
        case .lich:       return 18...30
        case .demonLord:  return 40...70
        }
    }

    var metalRange: ClosedRange<Int> {
        switch self {
        case .slime:      return 0...1
        case .goblin:     return 0...2
        case .orc:        return 1...3
        case .skeleton:   return 1...3
        case .vampire:    return 1...4
        case .golem:      return 4...7
        case .darkKnight: return 3...7
        case .dragon:     return 5...10
        case .lich:       return 4...8
        case .demonLord:  return 10...18
        }
    }

    var expReward: Int {
        switch self {
        case .slime:      return 12
        case .goblin:     return 20
        case .orc:        return 35
        case .skeleton:   return 28
        case .vampire:    return 45
        case .golem:      return 70
        case .darkKnight: return 85
        case .dragon:     return 110
        case .lich:       return 100
        case .demonLord:  return 220
        }
    }

    var color: SKColor {
        switch self {
        case .slime:      return SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1)
        case .goblin:     return SKColor(red: 0.5, green: 0.75, blue: 0.1, alpha: 1)
        case .orc:        return SKColor(red: 0.3, green: 0.55, blue: 0.1, alpha: 1)
        case .skeleton:   return SKColor(red: 0.9, green: 0.88, blue: 0.75, alpha: 1)
        case .vampire:    return SKColor(red: 0.45, green: 0.0, blue: 0.28, alpha: 1)
        case .golem:      return SKColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)
        case .darkKnight: return SKColor(red: 0.1, green: 0.1, blue: 0.28, alpha: 1)
        case .dragon:     return SKColor(red: 0.85, green: 0.15, blue: 0.1, alpha: 1)
        case .lich:       return SKColor(red: 0.4, green: 0.0, blue: 0.65, alpha: 1)
        case .demonLord:  return SKColor(red: 0.9, green: 0.05, blue: 0.05, alpha: 1)
        }
    }

    var emoji: String {
        switch self {
        case .slime:      return "🟢"
        case .goblin:     return "👺"
        case .orc:        return "👹"
        case .skeleton:   return "💀"
        case .vampire:    return "🧛"
        case .golem:      return "🗿"
        case .darkKnight: return "🖤"
        case .dragon:     return "🐉"
        case .lich:       return "🦴"
        case .demonLord:  return "😈"
        }
    }

    var size: CGSize {
        switch self {
        case .slime:      return CGSize(width: 36, height: 28)
        case .goblin:     return CGSize(width: 32, height: 40)
        case .orc:        return CGSize(width: 46, height: 52)
        case .skeleton:   return CGSize(width: 34, height: 50)
        case .vampire:    return CGSize(width: 36, height: 52)
        case .golem:      return CGSize(width: 56, height: 60)
        case .darkKnight: return CGSize(width: 46, height: 56)
        case .dragon:     return CGSize(width: 70, height: 60)
        case .lich:       return CGSize(width: 40, height: 56)
        case .demonLord:  return CGSize(width: 80, height: 80)
        }
    }

    var isBoss: Bool { self == .demonLord }
}

// MARK: - Floor Spawn Tables

struct FloorSpawnTable {
    static func enemies(floor: Int, castle: Int) -> [EnemyType] {
        // Offset enemy tier by castle progression
        let tier = min(floor + (castle - 1) * 2, 10)
        switch tier {
        case 1:       return [.slime,  .slime,      .goblin]
        case 2:       return [.slime,  .goblin,     .goblin]
        case 3:       return [.goblin, .goblin,     .orc]
        case 4:       return [.goblin, .orc,        .skeleton]
        case 5:       return [.orc,    .skeleton,   .skeleton]
        case 6:       return [.skeleton, .vampire,  .vampire]
        case 7:       return [.vampire, .golem,     .darkKnight]
        case 8:       return [.golem,  .dragon,     .darkKnight]
        case 9:       return [.dragon, .lich,       .darkKnight]
        case 10:      return [.lich,   .demonLord]
        default:      return [.demonLord, .demonLord, .lich]  // beyond castle 5
        }
    }
}

// MARK: - Live Enemy Instance

class EnemyInstance {
    let type: EnemyType
    let maxHP: Int
    var currentHP: Int
    let attack: Int
    let defense: Int
    let attackInterval: Double

    init(type: EnemyType, castle: Int) {
        self.type = type
        let hpMult  = pow(1.45, Double(castle - 1))
        let atkMult = pow(1.30, Double(castle - 1))
        self.maxHP         = Int(Double(type.baseHP) * hpMult)
        self.currentHP     = self.maxHP
        self.attack        = Int(Double(type.baseAttack) * atkMult)
        self.defense       = type.baseDefense + (castle - 1) * 2
        self.attackInterval = type.attackInterval
    }

    var isAlive: Bool { currentHP > 0 }
    var hpPercent: Double { Double(currentHP) / Double(maxHP) }

    @discardableResult
    func takeDamage(_ rawDamage: Int) -> Int {
        let actual = max(1, rawDamage - defense)
        currentHP  = max(0, currentHP - actual)
        return actual
    }

    var goldReward:  Int { Int.random(in: type.goldRange) }
    var metalReward: Int { Int.random(in: type.metalRange) }
}
