import Foundation

// MARK: - Equipment Blueprints

private struct Blueprint {
    let name: String
    let slot: EquipmentSlot
    let base: EquipmentStats
    let flavorText: String
    let minCastle: Int   // first castle level where this blueprint can appear
}

private let allBlueprints: [Blueprint] = [

    // ── WEAPONS ──────────────────────────────────────────────────────────────
    Blueprint(name: "Rusty Sword",
              slot: .weapon,
              base: EquipmentStats(attack: 5,  defense: 0, maxHP: 0,  speed: 0,   attackSpeed: 0),
              flavorText: "Older than the castle itself.",
              minCastle: 1),

    Blueprint(name: "Iron Blade",
              slot: .weapon,
              base: EquipmentStats(attack: 10, defense: 1, maxHP: 0,  speed: 0,   attackSpeed: 0.1),
              flavorText: "Standard issue for castle guards.",
              minCastle: 1),

    Blueprint(name: "Steel Sabre",
              slot: .weapon,
              base: EquipmentStats(attack: 18, defense: 2, maxHP: 0,  speed: 0,   attackSpeed: 0.15),
              flavorText: "Forged in the lower smithy.",
              minCastle: 2),

    Blueprint(name: "Shadow Reaper",
              slot: .weapon,
              base: EquipmentStats(attack: 28, defense: 0, maxHP: 0,  speed: 1.5, attackSpeed: 0.3),
              flavorText: "Moves faster than your shadow.",
              minCastle: 3),

    Blueprint(name: "Thunder Blade",
              slot: .weapon,
              base: EquipmentStats(attack: 35, defense: 0, maxHP: 0,  speed: 0,   attackSpeed: 0.5),
              flavorText: "Crackles with stored lightning.",
              minCastle: 3),

    Blueprint(name: "Soul Harvester",
              slot: .weapon,
              base: EquipmentStats(attack: 55, defense: 8, maxHP: 20, speed: 0,   attackSpeed: 0.25),
              flavorText: "Each kill feeds its hunger.",
              minCastle: 4),

    Blueprint(name: "Excalibur",
              slot: .weapon,
              base: EquipmentStats(attack: 90, defense: 20, maxHP: 50, speed: 1,  attackSpeed: 0.5),
              flavorText: "Only the worthy may lift it.",
              minCastle: 5),

    Blueprint(name: "Void Cleaver",
              slot: .weapon,
              base: EquipmentStats(attack: 120, defense: 5, maxHP: 0, speed: 0,   attackSpeed: 0.8),
              flavorText: "It rends reality itself.",
              minCastle: 5),

    // ── ARMOR ─────────────────────────────────────────────────────────────────
    Blueprint(name: "Leather Vest",
              slot: .armor,
              base: EquipmentStats(attack: 0, defense: 5,  maxHP: 25,  speed: 0,    attackSpeed: 0),
              flavorText: "Better than nothing.",
              minCastle: 1),

    Blueprint(name: "Chain Mail",
              slot: .armor,
              base: EquipmentStats(attack: 0, defense: 12, maxHP: 50,  speed: 0,    attackSpeed: 0),
              flavorText: "Clinks with every step.",
              minCastle: 1),

    Blueprint(name: "Plate Armor",
              slot: .armor,
              base: EquipmentStats(attack: 0, defense: 24, maxHP: 90,  speed: -0.5, attackSpeed: 0),
              flavorText: "Heavy, but reassuring.",
              minCastle: 2),

    Blueprint(name: "Dragon Scale",
              slot: .armor,
              base: EquipmentStats(attack: 5, defense: 40, maxHP: 130, speed: 0,    attackSpeed: 0),
              flavorText: "Shed by the great red dragon.",
              minCastle: 4),

    Blueprint(name: "Celestial Robe",
              slot: .armor,
              base: EquipmentStats(attack: 18, defense: 32, maxHP: 160, speed: 0.5, attackSpeed: 0.2),
              flavorText: "Woven from starlight.",
              minCastle: 5),

    Blueprint(name: "Abyssal Plate",
              slot: .armor,
              base: EquipmentStats(attack: 10, defense: 55, maxHP: 200, speed: 0,   attackSpeed: 0),
              flavorText: "Forged at the bottom of the abyss.",
              minCastle: 5),

    // ── HELMETS ───────────────────────────────────────────────────────────────
    Blueprint(name: "Leather Cap",
              slot: .helmet,
              base: EquipmentStats(attack: 0, defense: 3,  maxHP: 15,  speed: 0, attackSpeed: 0),
              flavorText: "Basic head protection.",
              minCastle: 1),

    Blueprint(name: "Iron Helm",
              slot: .helmet,
              base: EquipmentStats(attack: 0, defense: 8,  maxHP: 30,  speed: 0, attackSpeed: 0),
              flavorText: "Dented, but sturdy.",
              minCastle: 1),

    Blueprint(name: "Crown of Thorns",
              slot: .helmet,
              base: EquipmentStats(attack: 12, defense: 15, maxHP: 50, speed: 0, attackSpeed: 0),
              flavorText: "Pain sharpens the mind.",
              minCastle: 3),

    Blueprint(name: "Helm of Destiny",
              slot: .helmet,
              base: EquipmentStats(attack: 22, defense: 28, maxHP: 100, speed: 0, attackSpeed: 0.1),
              flavorText: "Your fate is written on the inside.",
              minCastle: 4),

    Blueprint(name: "Halo of the Fallen",
              slot: .helmet,
              base: EquipmentStats(attack: 35, defense: 40, maxHP: 150, speed: 0.5, attackSpeed: 0.2),
              flavorText: "An angel once wore this.",
              minCastle: 5),

    // ── BOOTS ─────────────────────────────────────────────────────────────────
    Blueprint(name: "Leather Boots",
              slot: .boots,
              base: EquipmentStats(attack: 0, defense: 2,  maxHP: 10,  speed: 1.0, attackSpeed: 0),
              flavorText: "Comfortable for long walks.",
              minCastle: 1),

    Blueprint(name: "Swift Boots",
              slot: .boots,
              base: EquipmentStats(attack: 0, defense: 5,  maxHP: 15,  speed: 2.0, attackSpeed: 0),
              flavorText: "You almost feel weightless.",
              minCastle: 2),

    Blueprint(name: "Windwalker Boots",
              slot: .boots,
              base: EquipmentStats(attack: 5, defense: 8,  maxHP: 20,  speed: 3.5, attackSpeed: 0.1),
              flavorText: "Step where the wind steps.",
              minCastle: 3),

    Blueprint(name: "Ghost Treads",
              slot: .boots,
              base: EquipmentStats(attack: 10, defense: 12, maxHP: 30, speed: 5.0, attackSpeed: 0.2),
              flavorText: "Leave no footprints.",
              minCastle: 4),

    Blueprint(name: "Boots of the Void",
              slot: .boots,
              base: EquipmentStats(attack: 18, defense: 18, maxHP: 50, speed: 8.0, attackSpeed: 0.35),
              flavorText: "The ground doesn't deserve you.",
              minCastle: 5),

    // ── RINGS ─────────────────────────────────────────────────────────────────
    Blueprint(name: "Copper Ring",
              slot: .ring,
              base: EquipmentStats(attack: 3,  defense: 3,  maxHP: 12,  speed: 0,   attackSpeed: 0),
              flavorText: "Simple, but dependable.",
              minCastle: 1),

    Blueprint(name: "Silver Band",
              slot: .ring,
              base: EquipmentStats(attack: 7,  defense: 6,  maxHP: 22,  speed: 0,   attackSpeed: 0.05),
              flavorText: "Gleams in torchlight.",
              minCastle: 1),

    Blueprint(name: "Gold Ring",
              slot: .ring,
              base: EquipmentStats(attack: 12, defense: 10, maxHP: 35,  speed: 0,   attackSpeed: 0.1),
              flavorText: "Heavy with wealth.",
              minCastle: 2),

    Blueprint(name: "Ruby Signet",
              slot: .ring,
              base: EquipmentStats(attack: 22, defense: 12, maxHP: 45,  speed: 0,   attackSpeed: 0.15),
              flavorText: "The gem pulses like a heartbeat.",
              minCastle: 3),

    Blueprint(name: "Dragon Ring",
              slot: .ring,
              base: EquipmentStats(attack: 35, defense: 22, maxHP: 65,  speed: 0.8, attackSpeed: 0.2),
              flavorText: "Contains a sliver of dragon soul.",
              minCastle: 4),

    Blueprint(name: "Ring of Omnipotence",
              slot: .ring,
              base: EquipmentStats(attack: 70, defense: 45, maxHP: 120, speed: 1.5, attackSpeed: 0.4),
              flavorText: "\"One ring to rule them all\" felt too on-the-nose.",
              minCastle: 5),
]

// MARK: - Blacksmith System

struct BlacksmithSystem {

    static let baseMetalCost = 10

    // Cost scales with castle level (more metal = better roll bias)
    static func metalCost(for castleLevel: Int) -> Int {
        return baseMetalCost + (castleLevel - 1) * 5
    }

    // Forge one random piece of equipment
    static func forge(metalSpent: Int, castleLevel: Int) -> Equipment {
        let rarity  = rollRarity(metalSpent: metalSpent, castleLevel: castleLevel)
        let slot    = rollSlot()
        let blueprint = rollBlueprint(slot: slot, castleLevel: castleLevel)

        let mult = rarity.multiplier
        let scaledStats = EquipmentStats(
            attack:      Int(Double(blueprint.base.attack)      * mult),
            defense:     Int(Double(blueprint.base.defense)     * mult),
            maxHP:       Int(Double(blueprint.base.maxHP)       * mult),
            speed:       blueprint.base.speed       * mult,
            attackSpeed: blueprint.base.attackSpeed * mult
        )

        return Equipment(
            id:         UUID(),
            name:       rarityPrefix(rarity) + blueprint.name,
            slot:       slot,
            rarity:     rarity,
            stats:      scaledStats,
            flavorText: blueprint.flavorText
        )
    }

    // MARK: - Private helpers

    private static func rollRarity(metalSpent: Int, castleLevel: Int) -> EquipmentRarity {
        // Spending extra metal improves rarity chances
        let bonus = max(0, metalSpent - baseMetalCost)
        var pool: [(rarity: EquipmentRarity, weight: Int)] = []

        for rarity in EquipmentRarity.allCases {
            var weight = rarity.weight
            // Rare+ tiers get a boost based on bonus metal and castle level
            switch rarity {
            case .rare:      weight += bonus * 2 + (castleLevel - 1) * 5
            case .epic:      weight += bonus * 4 + (castleLevel - 1) * 3
            case .legendary: weight += bonus * 6 + (castleLevel - 1) * 2
            default: break
            }
            pool.append((rarity, max(1, weight)))
        }

        let total = pool.reduce(0) { $0 + $1.weight }
        var roll  = Int.random(in: 0..<total)
        for entry in pool {
            roll -= entry.weight
            if roll < 0 { return entry.rarity }
        }
        return .common
    }

    private static func rollSlot() -> EquipmentSlot {
        EquipmentSlot.allCases.randomElement()!
    }

    private static func rollBlueprint(slot: EquipmentSlot, castleLevel: Int) -> Blueprint {
        let eligible = allBlueprints.filter { $0.slot == slot && $0.minCastle <= castleLevel }
        if eligible.isEmpty { return allBlueprints.first { $0.slot == slot }! }
        // Weight toward higher-tier blueprints for later castles
        return eligible.randomElement()!
    }

    private static func rarityPrefix(_ rarity: EquipmentRarity) -> String {
        switch rarity {
        case .common:    return ""
        case .uncommon:  return "Fine "
        case .rare:      return "Ancient "
        case .epic:      return "Mythic "
        case .legendary: return "⚡ "
        }
    }
}
