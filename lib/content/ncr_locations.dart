class NcrSector {
  const NcrSector({required this.slug, required this.label});

  final String slug;
  final String label;
}

class NcrCity {
  const NcrCity({
    required this.slug,
    required this.label,
    required this.sectorNoun,
    required this.sectors,
  });

  final String slug;
  final String label;
  final String sectorNoun;
  final List<NcrSector> sectors;

  String get route => '/listings/$slug';

  NcrSector? sectorBySlug(String slug) {
    for (final sector in sectors) {
      if (sector.slug == slug) return sector;
    }
    return null;
  }
}

abstract final class NcrLocations {
  static const delhi = NcrCity(
    slug: 'delhi',
    label: 'Delhi',
    sectorNoun: 'Locality',
    sectors: [
      NcrSector(slug: 'south-delhi', label: 'South Delhi'),
      NcrSector(slug: 'central-delhi', label: 'Central Delhi'),
      NcrSector(slug: 'new-delhi', label: 'New Delhi'),
      NcrSector(slug: 'dwarka', label: 'Dwarka'),
      NcrSector(slug: 'rohini', label: 'Rohini'),
      NcrSector(slug: 'vasant-kunj', label: 'Vasant Kunj'),
      NcrSector(slug: 'greater-kailash', label: 'Greater Kailash'),
      NcrSector(slug: 'saket', label: 'Saket'),
      NcrSector(slug: 'defence-colony', label: 'Defence Colony'),
      NcrSector(slug: 'chattarpur', label: 'Chattarpur'),
      NcrSector(slug: 'aerocity', label: 'Aerocity'),
      NcrSector(slug: 'west-delhi', label: 'West Delhi'),
      NcrSector(slug: 'east-delhi', label: 'East Delhi'),
      NcrSector(slug: 'north-delhi', label: 'North Delhi'),
    ],
  );

  static const noida = NcrCity(
    slug: 'noida',
    label: 'Noida',
    sectorNoun: 'Sector',
    sectors: [
      NcrSector(slug: '16', label: 'Sector 16'),
      NcrSector(slug: '18', label: 'Sector 18'),
      NcrSector(slug: '44', label: 'Sector 44'),
      NcrSector(slug: '50', label: 'Sector 50'),
      NcrSector(slug: '62', label: 'Sector 62'),
      NcrSector(slug: '73', label: 'Sector 73'),
      NcrSector(slug: '74', label: 'Sector 74'),
      NcrSector(slug: '75', label: 'Sector 75'),
      NcrSector(slug: '76', label: 'Sector 76'),
      NcrSector(slug: '77', label: 'Sector 77'),
      NcrSector(slug: '78', label: 'Sector 78'),
      NcrSector(slug: '79', label: 'Sector 79'),
      NcrSector(slug: '93', label: 'Sector 93'),
      NcrSector(slug: '94', label: 'Sector 94'),
      NcrSector(slug: '96', label: 'Sector 96'),
      NcrSector(slug: '100', label: 'Sector 100'),
      NcrSector(slug: '104', label: 'Sector 104'),
      NcrSector(slug: '107', label: 'Sector 107'),
      NcrSector(slug: '108', label: 'Sector 108'),
      NcrSector(slug: '119', label: 'Sector 119'),
      NcrSector(slug: '128', label: 'Sector 128'),
      NcrSector(slug: '135', label: 'Sector 135'),
      NcrSector(slug: '137', label: 'Sector 137'),
      NcrSector(slug: '143', label: 'Sector 143'),
      NcrSector(slug: '144', label: 'Sector 144'),
      NcrSector(slug: '146', label: 'Sector 146'),
      NcrSector(slug: '150', label: 'Sector 150'),
      NcrSector(slug: '168', label: 'Sector 168'),
    ],
  );

  static const greaterNoida = NcrCity(
    slug: 'greater-noida',
    label: 'Greater Noida',
    sectorNoun: 'Sector',
    sectors: [
      NcrSector(slug: 'west', label: 'Greater Noida West'),
      NcrSector(slug: 'alpha-1', label: 'Alpha I'),
      NcrSector(slug: 'alpha-2', label: 'Alpha II'),
      NcrSector(slug: 'beta-1', label: 'Beta I'),
      NcrSector(slug: 'beta-2', label: 'Beta II'),
      NcrSector(slug: 'gamma-1', label: 'Gamma I'),
      NcrSector(slug: 'gamma-2', label: 'Gamma II'),
      NcrSector(slug: 'delta-1', label: 'Delta I'),
      NcrSector(slug: 'knowledge-park-1', label: 'Knowledge Park I'),
      NcrSector(slug: 'knowledge-park-2', label: 'Knowledge Park II'),
      NcrSector(slug: 'knowledge-park-3', label: 'Knowledge Park III'),
      NcrSector(slug: 'knowledge-park-5', label: 'Knowledge Park V'),
      NcrSector(slug: 'techzone', label: 'Techzone'),
      NcrSector(slug: 'techzone-4', label: 'Techzone 4'),
      NcrSector(slug: 'omega', label: 'Omega'),
      NcrSector(slug: 'chi', label: 'Chi'),
      NcrSector(slug: 'phi', label: 'Phi'),
      NcrSector(slug: 'xi', label: 'Xi'),
      NcrSector(slug: 'yamuna-expressway', label: 'Yamuna Expressway'),
    ],
  );

  static const all = [delhi, noida, greaterNoida];

  static NcrCity? bySlug(String slug) {
    for (final city in all) {
      if (city.slug == slug) return city;
    }
    return null;
  }

  static String labelFor({required String city, required String sector}) {
    final match = bySlug(city);
    if (match == null) return [city, sector].where((s) => s.isNotEmpty).join(' · ');
    final sectorLabel = match.sectorBySlug(sector)?.label ?? sector;
    if (sectorLabel.isEmpty) return match.label;
    return '${match.label} · $sectorLabel';
  }
}
