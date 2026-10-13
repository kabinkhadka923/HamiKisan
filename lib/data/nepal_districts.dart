const List<String> nepalDistricts = [
  'Achham',
  'Arghakhanchi',
  'Baglung',
  'Baitadi',
  'Bajhang',
  'Bajura',
  'Banke',
  'Bara',
  'Bardiya',
  'Bhaktapur',
  'Bhojpur',
  'Chitwan',
  'Dadeldhura',
  'Dailekh',
  'Dang',
  'Darchula',
  'Dhading',
  'Dhankuta',
  'Dhanusha',
  'Dolakha',
  'Dolpa',
  'Doti',
  'Gorkha',
  'Gulmi',
  'Humla',
  'Ilam',
  'Jajarkot',
  'Jhapa',
  'Jumla',
  'Kailali',
  'Kalikot',
  'Kanchanpur',
  'Kapilvastu',
  'Kaski',
  'Kathmandu',
  'Kavrepalanchok',
  'Khotang',
  'Lalitpur',
  'Lamjung',
  'Mahottari',
  'Makwanpur',
  'Manang',
  'Morang',
  'Mugu',
  'Mustang',
  'Myagdi',
  'Nawalparasi East',
  'Nuwakot',
  'Okhaldhunga',
  'Palpa',
  'Panchthar',
  'Nawalparasi West',
  'Parbat',
  'Parsa',
  'Pyuthan',
  'Ramechhap',
  'Rasuwa',
  'Rautahat',
  'Rolpa',
  'Rukum East',
  'Rukum West',
  'Rupandehi',
  'Salyan',
  'Sankhuwasabha',
  'Saptari',
  'Sarlahi',
  'Sindhuli',
  'Sindhupalchok',
  'Siraha',
  'Solukhumbu',
  'Sunsari',
  'Surkhet',
  'Syangja',
  'Tanahun',
  'Taplejung',
  'Terhathum',
  'Udayapur',
];

String districtGroupId(String district) {
  final normalized = district
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return 'district_$normalized';
}

String? findNepalDistrict(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = value.toLowerCase();
  for (final district in nepalDistricts) {
    if (RegExp(
      r'(^|[^a-z])' + RegExp.escape(district.toLowerCase()) + r'([^a-z]|$)',
    ).hasMatch(normalized)) {
      return district;
    }
  }
  if (normalized.contains('nawalparasi east') ||
      normalized.contains('nawalparasi (east)')) {
    return 'Nawalparasi East';
  }
  if (normalized.contains('nawalparasi west') ||
      normalized.contains('nawalparasi (west)')) {
    return 'Nawalparasi West';
  }
  if (normalized.contains('nawalpur')) return 'Nawalparasi East';
  if (normalized.contains('parasi')) return 'Nawalparasi West';
  if (normalized.contains('kavre')) return 'Kavrepalanchok';
  return null;
}
