# Lucksmith — iOS Idle RPG

A 2D side-scrolling idle RPG for iOS built with **Swift + SpriteKit**.

Your hero auto-walks through increasingly dangerous castles, auto-attacks enemies, collects gold and metal, and visits the Blacksmith to forge random equipment. Hunt for that Legendary drop.

---

## Features

| System | Details |
|---|---|
| **Auto-combat** | Player walks right, stops to attack, then continues |
| **10 floors per castle** | Enemies scale with each castle level |
| **Enemy variety** | Slime → Goblin → Orc → Skeleton → Vampire → Golem → Dark Knight → Dragon → Lich → Demon Lord (boss) |
| **Loot** | Gold + Metal drop on kill, auto-collected |
| **Blacksmith** | Spend metal to forge random equipment with animated hammer reveal |
| **5 rarity tiers** | Common (60%), Uncommon (25%), Rare (10%), Epic (4%), Legendary (1%) |
| **5 equipment slots** | Weapon, Armor, Helmet, Boots, Ring |
| **30+ equipment blueprints** | Including ultra-rare Excalibur, Ring of Omnipotence, Boots of the Void |
| **Inventory** | Scrollable gear list with one-tap equip |
| **Progression** | Enemies and stat scaling per castle; player levels up automatically |
| **Save/Load** | Auto-saves to UserDefaults after every meaningful action |
| **Death system** | Revive with gold, or restart from floor 1 |

---

## Project Structure

```
LucksmithRPG/
├── AppDelegate.swift            — App entry point
├── GameViewController.swift     — Presents the SpriteKit view
├── GameView.swift               — Notes on SKView setup
├── Info.plist
│
├── Models/
│   ├── Equipment.swift          — EquipmentStats, Rarity, Slot, Equipment struct
│   ├── Player.swift             — PlayerData (stats, equipment, resources, leveling)
│   └── Enemy.swift              — EnemyType, FloorSpawnTable, EnemyInstance
│
├── Systems/
│   ├── GameManager.swift        — Singleton: floor/castle state, save/load, death
│   └── BlacksmithSystem.swift   — 30+ blueprints, weighted rarity roll, forge()
│
├── Nodes/
│   ├── PlayerNode.swift         — Animated player sprite (no image assets needed)
│   ├── EnemyNode.swift          — Enemy sprite + HP bar + death animation
│   ├── HUDNode.swift            — HP bar, gold, metal, floor label, action buttons
│   └── FloatingTextNode.swift   — Rising damage/loot/status numbers
│
└── Scenes/
    ├── GameScene.swift          — Main gameplay: walking, combat, loot, transitions
    ├── BlacksmithScene.swift    — Forge UI with hammer animation + legendary sparkles
    └── InventoryScene.swift     — Scrollable gear list, stats summary, equip buttons
```

---

## Xcode Setup (Step-by-Step)

### 1. Create the Xcode project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → Game** template
3. Name: `LucksmithRPG`
4. Language: **Swift**
5. Game Technology: **SpriteKit**
6. Uncheck Core Data, Unit Tests, UI Tests
7. Choose a save location

### 2. Replace generated files

Xcode generates `GameScene.swift` and `GameViewController.swift` — **delete them** (Move to Trash).

### 3. Add the source files

Drag the entire `LucksmithRPG/` folder into the Xcode project navigator, making sure:
- ✅ **Copy items if needed** is checked
- ✅ **Add to target: LucksmithRPG** is checked
- ✅ **Create groups** is selected

### 4. Configure the root view as SKView

In `Main.storyboard`:
1. Select the root `View` inside `GameViewController`
2. Open the **Identity Inspector** (⌘⌥3)
3. Set **Class** to `SKView`

**Or**, to avoid the storyboard entirely, replace `GameViewController.swift` with this programmatic version:

```swift
import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        let scene  = GameScene()
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
    }
    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
```

### 5. Remove the default SKS file

Delete `GameScene.sks` if Xcode generated one — the game builds its scene entirely in code.

### 6. Replace Info.plist if needed

The provided `Info.plist` is a reference. Xcode's generated one is fine; just ensure `UISupportedInterfaceOrientations` contains only `UIInterfaceOrientationPortrait`.

### 7. Build & Run

Select an **iPhone simulator** (iPhone 15 or newer recommended) and press **⌘R**.

---

## Gameplay

| Goal | How |
|---|---|
| Advance floors | Walk right → kill all enemies → reach the exit door |
| Collect loot | Player auto-collects gold 🪙 and metal ⚙️ from fallen enemies |
| Get stronger gear | Tap **🔨 FORGE** to spend metal at the Blacksmith |
| Equip items | Tap **🎒 GEAR** to open inventory, tap **Equip** on any item |
| Level up | Kill enemies to gain EXP; levels up automatically |
| Survive death | Revive with gold or restart castle from floor 1 |

---

## Equipment Rarities

| Rarity | Color | Drop Weight | Stat Multiplier |
|---|---|---|---|
| Common    | Gray   | 60% | ×1.0 |
| Uncommon  | Green  | 25% | ×1.6 |
| Rare      | Blue   | 10% | ×2.5 |
| Epic      | Purple |  4% | ×4.0 |
| Legendary | Orange |  1% | ×7.0 |

Spending more metal (and reaching higher castle levels) increases rare+ drop rates.

### Rare Legendary Items

- ⚡ Excalibur (Weapon) — ATK +630, DEF +140, HP +350, SPD +7, ASPD +3.5/s
- ⚡ Ring of Omnipotence (Ring) — ATK +490, DEF +315, HP +840, SPD +10.5, ASPD +2.8/s  
- ⚡ Abyssal Plate (Armor) — DEF +385, HP +1400, ATK +70
- ⚡ Halo of the Fallen (Helmet) — ATK +245, DEF +280, HP +1050, ASPD +1.4/s
- ⚡ Boots of the Void (Boots) — ATK +126, DEF +126, HP +350, SPD +56, ASPD +2.45/s

---

## Extending the Game

- **New enemies**: Add cases to `EnemyType` in `Enemy.swift`
- **New blueprints**: Add `Blueprint` entries in `BlacksmithSystem.swift`
- **New castles**: Scale automatically via `FloorSpawnTable.enemies(floor:castle:)`
- **More floors**: Change the `advanceFloor()` logic in `GameManager.swift`
- **Art assets**: Replace `SKShapeNode` bodies in `PlayerNode` / `EnemyNode` with `SKTexture`
- **Music/SFX**: Add `SKAudioNode` in `GameScene.didMove(to:)`

---

## Requirements

- Xcode 15+
- iOS 16+ deployment target
- Swift 5.9+
- No third-party dependencies
