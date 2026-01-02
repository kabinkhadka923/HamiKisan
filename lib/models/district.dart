class District {
  final int id;
  final String name;
  final String province;

  const District({
    required this.id,
    required this.name,
    required this.province,
  });

  factory District.fromJson(Map<String, dynamic> json) => District(
    id: json['id'] as int,
    name: json['name'] as String,
    province: json['province'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'province': province,
  };
}

class NepalDistricts {
  static const List<District> all = [
    // Province 1
    District(id: 1, name: 'Taplejung', province: 'Province 1'),
    District(id: 2, name: 'Panchthar', province: 'Province 1'),
    District(id: 3, name: 'Ilam', province: 'Province 1'),
    District(id: 4, name: 'Jhapa', province: 'Province 1'),
    District(id: 5, name: 'Morang', province: 'Province 1'),
    District(id: 6, name: 'Sunsari', province: 'Province 1'),
    District(id: 7, name: 'Dhankuta', province: 'Province 1'),
    District(id: 8, name: 'Terhathum', province: 'Province 1'),
    District(id: 9, name: 'Sankhuwasabha', province: 'Province 1'),
    District(id: 10, name: 'Bhojpur', province: 'Province 1'),
    District(id: 11, name: 'Solukhumbu', province: 'Province 1'),
    District(id: 12, name: 'Okhaldhunga', province: 'Province 1'),
    District(id: 13, name: 'Khotang', province: 'Province 1'),
    District(id: 14, name: 'Udayapur', province: 'Province 1'),
    
    // Madhesh Province
    District(id: 15, name: 'Saptari', province: 'Madhesh Province'),
    District(id: 16, name: 'Siraha', province: 'Madhesh Province'),
    District(id: 17, name: 'Dhanusha', province: 'Madhesh Province'),
    District(id: 18, name: 'Mahottari', province: 'Madhesh Province'),
    District(id: 19, name: 'Sarlahi', province: 'Madhesh Province'),
    District(id: 20, name: 'Bara', province: 'Madhesh Province'),
    District(id: 21, name: 'Parsa', province: 'Madhesh Province'),
    District(id: 22, name: 'Rautahat', province: 'Madhesh Province'),
    
    // Bagmati Province
    District(id: 23, name: 'Sindhuli', province: 'Bagmati Province'),
    District(id: 24, name: 'Ramechhap', province: 'Bagmati Province'),
    District(id: 25, name: 'Dolakha', province: 'Bagmati Province'),
    District(id: 26, name: 'Sindhupalchok', province: 'Bagmati Province'),
    District(id: 27, name: 'Kavrepalanchok', province: 'Bagmati Province'),
    District(id: 28, name: 'Lalitpur', province: 'Bagmati Province'),
    District(id: 29, name: 'Bhaktapur', province: 'Bagmati Province'),
    District(id: 30, name: 'Kathmandu', province: 'Bagmati Province'),
    District(id: 31, name: 'Nuwakot', province: 'Bagmati Province'),
    District(id: 32, name: 'Rasuwa', province: 'Bagmati Province'),
    District(id: 33, name: 'Dhading', province: 'Bagmati Province'),
    District(id: 34, name: 'Chitwan', province: 'Bagmati Province'),
    District(id: 35, name: 'Makwanpur', province: 'Bagmati Province'),
    
    // Gandaki Province
    District(id: 36, name: 'Gorkha', province: 'Gandaki Province'),
    District(id: 37, name: 'Lamjung', province: 'Gandaki Province'),
    District(id: 38, name: 'Tanahun', province: 'Gandaki Province'),
    District(id: 39, name: 'Syangja', province: 'Gandaki Province'),
    District(id: 40, name: 'Kaski', province: 'Gandaki Province'),
    District(id: 41, name: 'Manang', province: 'Gandaki Province'),
    District(id: 42, name: 'Mustang', province: 'Gandaki Province'),
    District(id: 43, name: 'Myagdi', province: 'Gandaki Province'),
    District(id: 44, name: 'Parbat', province: 'Gandaki Province'),
    District(id: 45, name: 'Baglung', province: 'Gandaki Province'),
    District(id: 46, name: 'Nawalparasi East', province: 'Gandaki Province'),
    
    // Lumbini Province
    District(id: 47, name: 'Nawalparasi West', province: 'Lumbini Province'),
    District(id: 48, name: 'Rupandehi', province: 'Lumbini Province'),
    District(id: 49, name: 'Kapilvastu', province: 'Lumbini Province'),
    District(id: 50, name: 'Palpa', province: 'Lumbini Province'),
    District(id: 51, name: 'Gulmi', province: 'Lumbini Province'),
    District(id: 52, name: 'Arghakhanchi', province: 'Lumbini Province'),
    District(id: 53, name: 'Pyuthan', province: 'Lumbini Province'),
    District(id: 54, name: 'Rolpa', province: 'Lumbini Province'),
    District(id: 55, name: 'Rukum East', province: 'Lumbini Province'),
    District(id: 56, name: 'Banke', province: 'Lumbini Province'),
    District(id: 57, name: 'Bardiya', province: 'Lumbini Province'),
    District(id: 58, name: 'Dang', province: 'Lumbini Province'),
    
    // Karnali Province
    District(id: 59, name: 'Rukum West', province: 'Karnali Province'),
    District(id: 60, name: 'Salyan', province: 'Karnali Province'),
    District(id: 61, name: 'Dolpa', province: 'Karnali Province'),
    District(id: 62, name: 'Humla', province: 'Karnali Province'),
    District(id: 63, name: 'Jumla', province: 'Karnali Province'),
    District(id: 64, name: 'Kalikot', province: 'Karnali Province'),
    District(id: 65, name: 'Mugu', province: 'Karnali Province'),
    District(id: 66, name: 'Surkhet', province: 'Karnali Province'),
    District(id: 67, name: 'Dailekh', province: 'Karnali Province'),
    District(id: 68, name: 'Jajarkot', province: 'Karnali Province'),
    
    // Sudurpashchim Province
    District(id: 69, name: 'Kailali', province: 'Sudurpashchim Province'),
    District(id: 70, name: 'Achham', province: 'Sudurpashchim Province'),
    District(id: 71, name: 'Doti', province: 'Sudurpashchim Province'),
    District(id: 72, name: 'Bajhang', province: 'Sudurpashchim Province'),
    District(id: 73, name: 'Bajura', province: 'Sudurpashchim Province'),
    District(id: 74, name: 'Kanchanpur', province: 'Sudurpashchim Province'),
    District(id: 75, name: 'Dadeldhura', province: 'Sudurpashchim Province'),
    District(id: 76, name: 'Baitadi', province: 'Sudurpashchim Province'),
    District(id: 77, name: 'Darchula', province: 'Sudurpashchim Province'),
  ];

  static District? findById(int id) {
    try {
      return all.firstWhere((district) => district.id == id);
    } catch (e) {
      return null;
    }
  }

  static District? findByName(String name) {
    try {
      return all.firstWhere((district) => district.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}