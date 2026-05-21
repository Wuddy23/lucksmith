import Foundation
import SpriteKit

// MARK: - Stats

struct EquipmentStats: Codable, Equatable {
    var attack: Int
    var defense: Int
    var maxHP: Int
    var speed: Double
    var attackSpeed: Double

    static let zero = EquipmentStats(attack: 0, defense: 0, maxHP: 0, speed: 0, attackSpeed: 0)

    static func + (lhs: EquipmentStats, rhs: EquipmentStats) -> EquipmentStats {
        EquipmentStats(
            attack:      lhs.attack      + rhs.attack,
            defense:     lhs.defense     + rhs.defense,
            maxHP:       lhs.maxHP       + rhs.maxHP,
            speed:       lhs.speed       + rhs.speed,
            attackSpeed: lhs.attackSpeed + rhs.attackSpeed
        )
    }
}

// MARK: - Rarity

enum EquipmentRarity: String, Codable, CaseIterable {
    case common    = "Common"
    case uncommon  = "Uncommon"
    case rare      = "Rare"
    case epic      = "Epic"
    case legendary = "Legendary"

    // Weighted drop pool out of 1000
    var weight: Int {
        switch self {
        case .common:    return 600
        case .uncommon:  return 250
        case .rare:      return 100
        case .epic:      return 40
        case .legendary: return 10
        }
    }

    var multiplier: Double {
        switch self {
        case .common:    return 1.0
        case .uncommon:  return 1.6
        case .rare:      return 2.5
        case .epic:      return 4.0
        case .legendary: return 7.0
        }
    }

    var color: SKColor {
        switch self {
        case .common:    return SKColor(white: 0.7, alpha: 1)
        case .uncommon:  return SKColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 1)
        case .rare:      return SKColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 1)
        case .epic:      return SKColor(red: 0.8, green: 0.0, blue: 1.0, alpha: 1)
        case .legendary: return SKColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1)
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .common:    return 0
        case .uncommon:  return 4
        case .rare:      return 8
        case .epic:      return 12
        case .legendary: return 20
        }
    }
}

// MARK: - Slot

enum EquipmentSlot: String, Codable, CaseIterable {
    case weapon = "Weapon"
    case armor  = "Armor"
    case helmet = "Helmet"
    case boots  = "Boots"
    case ring   = "Ring"

    var icon: String {
        switch self {
        case .weapon: return "⚔️"
        case .armor:  return "🛡"
        case .helmet: return "⛑"
        case .boots:  return "👢"
        case .ring:   return "💍"
        }
    }
}

// MARK: - Equipment

struct Equipment: Identifiable, Codable {
    let id: UUID
    let name: String
    let slot: EquipmentSlot
    let rarity: EquipmentRarity
    let stats: EquipmentStats
    let flavorText: String

    var statDescription: String {
        var parts: [String] = []
        if stats.attack      > 0 { parts.append("ATK +\(stats.attack)") }
        if stats.defense     > 0 { parts.append("DEF +\(stats.defense)") }
        if stats.maxHP       > 0 { parts.append("HP +\(stats.maxHP)") }
        if stats.speed       > 0 { parts.append("SPD +\(Int(stats.speed))") }
        if stats.attackSpeed > 0 { parts.append("ASPD +\(String(format: "%.1f", stats.attackSpeed))/s") }
        return parts.joined(separator: "  ")
    }
}
