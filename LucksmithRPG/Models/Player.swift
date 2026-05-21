import Foundation

class PlayerData: Codable {

    // Identity
    var name: String
    var level: Int
    var experience: Int

    // Base stats
    var baseAttack: Int
    var baseDefense: Int
    var baseMaxHP: Int
    var baseSpeed: Double       // pixels per second
    var baseAttackSpeed: Double // attacks per second
    var baseAttackRange: Double // pixels

    // Current state
    var currentHP: Int

    // Resources
    var gold: Int
    var metal: Int

    // Equipment
    var equippedWeapon: Equipment?
    var equippedArmor:  Equipment?
    var equippedHelmet: Equipment?
    var equippedBoots:  Equipment?
    var equippedRing:   Equipment?

    // Inventory (unequipped items, max 30)
    var inventory: [Equipment]

    static let inventoryMax = 30

    // MARK: - Init

    init(name: String = "Hero") {
        self.name            = name
        self.level           = 1
        self.experience      = 0
        self.baseAttack      = 10
        self.baseDefense     = 3
        self.baseMaxHP       = 100
        self.baseSpeed       = 90.0
        self.baseAttackSpeed = 1.0
        self.baseAttackRange = 65.0
        self.currentHP       = 100
        self.gold            = 0
        self.metal           = 0
        self.inventory       = []
    }

    // MARK: - Computed total stats

    var equipmentBonus: EquipmentStats {
        var s = EquipmentStats.zero
        if let e = equippedWeapon { s = s + e.stats }
        if let e = equippedArmor  { s = s + e.stats }
        if let e = equippedHelmet { s = s + e.stats }
        if let e = equippedBoots  { s = s + e.stats }
        if let e = equippedRing   { s = s + e.stats }
        return s
    }

    var totalAttack:      Int    { baseAttack      + equipmentBonus.attack }
    var totalDefense:     Int    { baseDefense      + equipmentBonus.defense }
    var totalMaxHP:       Int    { baseMaxHP        + equipmentBonus.maxHP }
    var totalSpeed:       Double { baseSpeed        + equipmentBonus.speed }
    var totalAttackSpeed: Double { baseAttackSpeed  + equipmentBonus.attackSpeed }
    var totalAttackRange: Double { baseAttackRange }

    var isAlive: Bool { currentHP > 0 }
    var hpPercent: Double { Double(currentHP) / Double(totalMaxHP) }

    // MARK: - Combat helpers

    @discardableResult
    func takeDamage(_ rawDamage: Int) -> Int {
        let actual = max(1, rawDamage - totalDefense)
        currentHP  = max(0, currentHP - actual)
        return actual
    }

    func heal(_ amount: Int) {
        currentHP = min(totalMaxHP, currentHP + amount)
    }

    func fullHeal() {
        currentHP = totalMaxHP
    }

    // MARK: - Equipment management

    func equip(_ item: Equipment) {
        if let current = equipped(slot: item.slot) {
            if inventory.count < PlayerData.inventoryMax {
                inventory.append(current)
            }
        }
        inventory.removeAll { $0.id == item.id }
        set(item, forSlot: item.slot)
        if currentHP > totalMaxHP { currentHP = totalMaxHP }
    }

    func unequip(slot: EquipmentSlot) {
        guard let item = equipped(slot: slot) else { return }
        if inventory.count < PlayerData.inventoryMax {
            inventory.append(item)
        }
        set(nil, forSlot: slot)
    }

    func equipped(slot: EquipmentSlot) -> Equipment? {
        switch slot {
        case .weapon: return equippedWeapon
        case .armor:  return equippedArmor
        case .helmet: return equippedHelmet
        case .boots:  return equippedBoots
        case .ring:   return equippedRing
        }
    }

    private func set(_ item: Equipment?, forSlot slot: EquipmentSlot) {
        switch slot {
        case .weapon: equippedWeapon = item
        case .armor:  equippedArmor  = item
        case .helmet: equippedHelmet = item
        case .boots:  equippedBoots  = item
        case .ring:   equippedRing   = item
        }
    }

    // MARK: - Salvage

    @discardableResult
    func salvage(_ item: Equipment) -> (metal: Int, gold: Int) {
        let m: Int
        let g: Int
        switch item.rarity {
        case .common:    m = 1;  g = 0
        case .uncommon:  m = 3;  g = 0
        case .rare:      m = 5;  g = 10
        case .epic:      m = 8;  g = 25
        case .legendary: m = 15; g = 75
        }
        inventory.removeAll { $0.id == item.id }
        metal += m
        gold  += g
        return (m, g)
    }

    // MARK: - Leveling

    func addExperience(_ exp: Int) {
        experience += exp
        while experience >= expToNextLevel {
            experience -= expToNextLevel
            levelUp()
        }
    }

    var expToNextLevel: Int { level * 100 }

    private func levelUp() {
        level           += 1
        baseAttack      += 2
        baseDefense     += 1
        baseMaxHP       += 15
        baseAttackSpeed += 0.04
        currentHP        = totalMaxHP
    }
}
