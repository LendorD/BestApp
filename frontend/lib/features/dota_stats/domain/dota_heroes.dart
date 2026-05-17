class DotaHeroInfo {
  const DotaHeroInfo({
    required this.id,
    required this.nameRu,
    required this.slug,
  });

  final int id;
  final String nameRu;
  final String slug;

  String get imageUrl =>
      'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/$slug.png';

  String get cardUrl =>
      'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/social/$slug.jpg';
}

const dotaHeroes = <int, DotaHeroInfo>{
  1: DotaHeroInfo(id: 1, nameRu: 'Anti-Mage', slug: 'antimage'),
  2: DotaHeroInfo(id: 2, nameRu: 'Axe', slug: 'axe'),
  3: DotaHeroInfo(id: 3, nameRu: 'Bane', slug: 'bane'),
  4: DotaHeroInfo(id: 4, nameRu: 'Bloodseeker', slug: 'bloodseeker'),
  5: DotaHeroInfo(id: 5, nameRu: 'Crystal Maiden', slug: 'crystal_maiden'),
  6: DotaHeroInfo(id: 6, nameRu: 'Drow Ranger', slug: 'drow_ranger'),
  7: DotaHeroInfo(id: 7, nameRu: 'Earthshaker', slug: 'earthshaker'),
  8: DotaHeroInfo(id: 8, nameRu: 'Juggernaut', slug: 'juggernaut'),
  9: DotaHeroInfo(id: 9, nameRu: 'Mirana', slug: 'mirana'),
  10: DotaHeroInfo(id: 10, nameRu: 'Morphling', slug: 'morphling'),
  11: DotaHeroInfo(id: 11, nameRu: 'Shadow Fiend', slug: 'nevermore'),
  12: DotaHeroInfo(id: 12, nameRu: 'Phantom Lancer', slug: 'phantom_lancer'),
  13: DotaHeroInfo(id: 13, nameRu: 'Puck', slug: 'puck'),
  14: DotaHeroInfo(id: 14, nameRu: 'Pudge', slug: 'pudge'),
  15: DotaHeroInfo(id: 15, nameRu: 'Razor', slug: 'razor'),
  16: DotaHeroInfo(id: 16, nameRu: 'Sand King', slug: 'sand_king'),
  17: DotaHeroInfo(id: 17, nameRu: 'Storm Spirit', slug: 'storm_spirit'),
  18: DotaHeroInfo(id: 18, nameRu: 'Sven', slug: 'sven'),
  19: DotaHeroInfo(id: 19, nameRu: 'Tiny', slug: 'tiny'),
  20: DotaHeroInfo(id: 20, nameRu: 'Vengeful Spirit', slug: 'vengefulspirit'),
  21: DotaHeroInfo(id: 21, nameRu: 'Windranger', slug: 'windrunner'),
  22: DotaHeroInfo(id: 22, nameRu: 'Zeus', slug: 'zuus'),
  23: DotaHeroInfo(id: 23, nameRu: 'Kunkka', slug: 'kunkka'),
  25: DotaHeroInfo(id: 25, nameRu: 'Lina', slug: 'lina'),
  26: DotaHeroInfo(id: 26, nameRu: 'Lion', slug: 'lion'),
  27: DotaHeroInfo(id: 27, nameRu: 'Shadow Shaman', slug: 'shadow_shaman'),
  28: DotaHeroInfo(id: 28, nameRu: 'Slardar', slug: 'slardar'),
  29: DotaHeroInfo(id: 29, nameRu: 'Tidehunter', slug: 'tidehunter'),
  30: DotaHeroInfo(id: 30, nameRu: 'Witch Doctor', slug: 'witch_doctor'),
  31: DotaHeroInfo(id: 31, nameRu: 'Lich', slug: 'lich'),
  32: DotaHeroInfo(id: 32, nameRu: 'Riki', slug: 'riki'),
  33: DotaHeroInfo(id: 33, nameRu: 'Enigma', slug: 'enigma'),
  34: DotaHeroInfo(id: 34, nameRu: 'Tinker', slug: 'tinker'),
  35: DotaHeroInfo(id: 35, nameRu: 'Sniper', slug: 'sniper'),
  36: DotaHeroInfo(id: 36, nameRu: 'Necrophos', slug: 'necrolyte'),
  37: DotaHeroInfo(id: 37, nameRu: 'Warlock', slug: 'warlock'),
  38: DotaHeroInfo(id: 38, nameRu: 'Beastmaster', slug: 'beastmaster'),
  39: DotaHeroInfo(id: 39, nameRu: 'Queen of Pain', slug: 'queenofpain'),
  40: DotaHeroInfo(id: 40, nameRu: 'Venomancer', slug: 'venomancer'),
  41: DotaHeroInfo(id: 41, nameRu: 'Faceless Void', slug: 'faceless_void'),
  42: DotaHeroInfo(id: 42, nameRu: 'Wraith King', slug: 'skeleton_king'),
  43: DotaHeroInfo(id: 43, nameRu: 'Death Prophet', slug: 'death_prophet'),
  44: DotaHeroInfo(
    id: 44,
    nameRu: 'Phantom Assassin',
    slug: 'phantom_assassin',
  ),
  45: DotaHeroInfo(id: 45, nameRu: 'Pugna', slug: 'pugna'),
  46: DotaHeroInfo(
    id: 46,
    nameRu: 'Templar Assassin',
    slug: 'templar_assassin',
  ),
  47: DotaHeroInfo(id: 47, nameRu: 'Viper', slug: 'viper'),
  48: DotaHeroInfo(id: 48, nameRu: 'Luna', slug: 'luna'),
  49: DotaHeroInfo(id: 49, nameRu: 'Dragon Knight', slug: 'dragon_knight'),
  50: DotaHeroInfo(id: 50, nameRu: 'Dazzle', slug: 'dazzle'),
  51: DotaHeroInfo(id: 51, nameRu: 'Clockwerk', slug: 'rattletrap'),
  52: DotaHeroInfo(id: 52, nameRu: 'Leshrac', slug: 'leshrac'),
  53: DotaHeroInfo(id: 53, nameRu: 'Nature’s Prophet', slug: 'furion'),
  54: DotaHeroInfo(id: 54, nameRu: 'Lifestealer', slug: 'life_stealer'),
  55: DotaHeroInfo(id: 55, nameRu: 'Dark Seer', slug: 'dark_seer'),
  56: DotaHeroInfo(id: 56, nameRu: 'Clinkz', slug: 'clinkz'),
  57: DotaHeroInfo(id: 57, nameRu: 'Omniknight', slug: 'omniknight'),
  58: DotaHeroInfo(id: 58, nameRu: 'Enchantress', slug: 'enchantress'),
  59: DotaHeroInfo(id: 59, nameRu: 'Huskar', slug: 'huskar'),
  60: DotaHeroInfo(id: 60, nameRu: 'Night Stalker', slug: 'night_stalker'),
  61: DotaHeroInfo(id: 61, nameRu: 'Broodmother', slug: 'broodmother'),
  62: DotaHeroInfo(id: 62, nameRu: 'Bounty Hunter', slug: 'bounty_hunter'),
  63: DotaHeroInfo(id: 63, nameRu: 'Weaver', slug: 'weaver'),
  64: DotaHeroInfo(id: 64, nameRu: 'Jakiro', slug: 'jakiro'),
  65: DotaHeroInfo(id: 65, nameRu: 'Batrider', slug: 'batrider'),
  66: DotaHeroInfo(id: 66, nameRu: 'Chen', slug: 'chen'),
  67: DotaHeroInfo(id: 67, nameRu: 'Spectre', slug: 'spectre'),
  68: DotaHeroInfo(
    id: 68,
    nameRu: 'Ancient Apparition',
    slug: 'ancient_apparition',
  ),
  69: DotaHeroInfo(id: 69, nameRu: 'Doom', slug: 'doom_bringer'),
  70: DotaHeroInfo(id: 70, nameRu: 'Ursa', slug: 'ursa'),
  71: DotaHeroInfo(id: 71, nameRu: 'Spirit Breaker', slug: 'spirit_breaker'),
  72: DotaHeroInfo(id: 72, nameRu: 'Gyrocopter', slug: 'gyrocopter'),
  73: DotaHeroInfo(id: 73, nameRu: 'Alchemist', slug: 'alchemist'),
  74: DotaHeroInfo(id: 74, nameRu: 'Invoker', slug: 'invoker'),
};

DotaHeroInfo? heroInfoById(int id) => dotaHeroes[id];
