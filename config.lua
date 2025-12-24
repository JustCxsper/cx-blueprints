Config = {}

-- Metadata key for storing learned blueprints
Config.MetadataKey = 'blueprints'

-- Defined blueprints (examples)
Config.Blueprints = {
    {
        name = 'weapon_pistol',
        label = '9mm Pistol',
        category = 'Weapons',
        tier = 'Tier 1',
        rarity = 'rare',
        description = 'Standard sidearm, reliable and easy to craft.',
    },
    {
        name = 'weapon_smg',
        label = 'Compact SMG',
        category = 'Weapons',
        tier = 'Tier 2',
        rarity = 'rare',
        description = 'High fire rate, lightweight and punchy.',
    },
    {
        name = 'advancedlockpick',
        label = 'Advanced Lockpick',
        category = 'Tools',
        tier = 'Tier 1',
        rarity = 'epic',
        description = 'For doors and locks that were never meant to open.',
    },
    {
        name = 'armour',
        label = 'Body Armour',
        category = 'Tools',
        tier = 'Tier 1',
        rarity = 'epic',
        description = 'Provides additional protection against damage.',
    },
    {
        name = 'thermite',
        label = 'Thermite',
        category = 'Tools',
        tier = 'Tier 1',
        rarity = 'epic',
        description = 'Used for breaching reinforced doors and safes.',
    },
    {
        name = 'repairkit',
        label = 'Repair Kit',
        category = 'Tools',
        tier = 'Tier 1',
        rarity = 'epic',
        description = 'Used for repairing damaged items and vehicles.',
    },
    {
        name = 'lockpick',
        label = 'Lockpick',
        category = 'Tools',
        tier = 'Tier 1',
        rarity = 'uncommon',
        description = 'Basic lockpick for simple locks.',
    },
}

-- What to show in “Requires: X” when player lacks the bp_ item
Config.RequireLabels = {
    weapon_pistol = 'Pistol Blueprint',
    weapon_smg = 'SMG Blueprint',
    advancedlockpick = 'Advanced Lockpick Blueprint',
    armour = 'Body Armour Blueprint',
    thermite = 'Thermite Blueprint',
    repairkit = 'Repair Kit Blueprint',
    lockpick = 'Lockpick Blueprint',
}
