# CX-Blueprints — Setup & Usage Guide

*Rust-style blueprint progression for ox_inventory crafting*

---

## What This Does (Short)

Players must **learn blueprints** before they can craft certain items.

- They learn by using blueprint items (`bp_*`).
- Blueprint progress is saved in metadata.
- Crafting benches can optionally require the blueprint.

**You choose which recipes are gated.**

---

## 1. Install the Resource

Place the folder in your server:

```
resources/[custom]/cx-blueprints
```


---

## 2. Set Up Blueprint Definitions

Open:

```
cx-blueprints/config.lua
```

Inside `Config.Blueprints`, add entries like:

```lua
{
  name = 'weapon_pistol',
  label = '9mm Pistol',
  category = 'Weapons',
  tier = 'Tier 1',
  rarity = 'uncommon',
  description = 'Basic sidearm.',
},
```

**MOST IMPORTANT:** `name` must match the `ox_inventory` item name exactly.

Then, in the same file, add readable labels to `Config.RequireLabels`:

```lua
Config.RequireLabels = {
  weapon_pistol = 'Pistol Blueprint',
}
```

This is what shows in the tablet when missing.

---

## 3. Create Blueprint Items in ox_inventory

Blueprints follow one rule:

```
bp_<itemName>
```

**Examples:**
- `bp_weapon_pistol`
- `bp_lockpick_advanced`

Add items to `ox_inventory`'s items file:

```lua
['bp_weapon_pistol'] = {
  label = 'Pistol Blueprint',
  weight = 10,
  stack = true,
  close = true,
}
```

No metadata required. Players consume this item to learn.

---

## 4. Opening the Tablet In Game

Players can:

- **Command:** `/bp`
- **Keybind:** Press `F6`

The UI shows:

- ✅ Learned
- ✅ Learnable
- ✅ Locked

Clicking **LEARN** consumes the blueprint and unlocks permanently.

---

## 5. Editing ox_inventory to Enforce Blueprints
*THIS IS THE IMPORTANT PART*

Open the `ox_inventory` server crafting file:

```
ox_inventory/modules/crafting/server.lua
```
*(or wherever your `craftItem` callback lives)*

At the **TOP** (with other locals), add:

```lua
local hasBlueprintTablet = GetResourceState('cx-blueprints') == 'started'
```

Then, inside the craft event, find:

```lua
local recipe = bench.items[recipeId]
```

Immediately under it, add:

```lua
-- CX Blueprints: optional blueprint gate
if hasBlueprintTablet and recipe.requireBlueprint then
  local ok, has = pcall(function()
    return exports['cx-blueprints']:HasBlueprint(source, recipe.name)
  end)

  if ok and not has then
    if left and left.closeInventory then
      left:closeInventory()
    end

    return false, 'missing_blueprint'
  end
end
```

**SAVE THE FILE.**

---

## 6. Enable Blueprint Gating Per Recipe

Edit your ox crafting recipes:

```
ox_inventory/data/crafting.lua
```

Add:

```lua
requireBlueprint = true
```

**Example:**

```lua
{
  name = 'weapon_pistol',
  label = '9mm Pistol',
  ingredients = {
    steel = 5,
    screw = 2,
  },
  requireBlueprint = true,
}
```

If you don't add `requireBlueprint = true`, the item will **NOT** be gated.

**You control what requires progression.**

---

## 7. Add the Missing Blueprint Message

Open `ox_inventory` locales and add:

```lua
['missing_blueprint'] = 'You have not learned this blueprint yet.',
```

Otherwise, the user just sees missing_blueprint.

---

## 8. Optional: Use Exports in Your Own Scripts

Check manually:

```lua
exports['cx-blueprints']:HasBlueprint(src, 'weapon_pistol')
```

Or using recipes:

```lua
exports['cx-blueprints']:HasBlueprintForRecipe(src, recipe)
```

Both return `true` or `false`.

---

## 9. How the Flow Works In Game

1. Player finds `bp_weapon_pistol`
2. Player opens tablet
3. Player clicks **Learn**
4. Item is consumed
5. Blueprint saved to metadata
6. Crafting benches now allow pistol craft

**Forever. No resets.**

---

## 10. Troubleshooting

### Crafting doesn't block:
- `requireBlueprint` not set
- Wrong resource name
- `cx-blueprints` not started
- `Config.Blueprints` missing entry
- Missing locale entry

### Tablet shows empty:
- Blueprint name doesn't match ox item name

### Learning does nothing:
- You didn't name item `bp_itemname`
- Wrong item name in config

### Inventory doesn't close on fail:
- Make sure the `closeInventory` line exists under the check

---

*That's it — simple, clear, and complete.*
