import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rezervasyon_mobil/core/secure_storage.dart';
import 'package:rezervasyon_mobil/screens/user_login.dart';
import 'package:rezervasyon_mobil/screens/user_chair_screen.dart';
import 'package:rezervasyon_mobil/screens/admin_screen/admin_layout.dart';
import 'package:rezervasyon_mobil/screens/user_sidebar.dart';
import '../providers/store_provider.dart';
import '../models/user_model/store_models.dart';

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  final SecureStorage _myStorage = SecureStorage();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? _cachedToken;

  // ✅ TÜRKİYE TÜM İL VE İLÇELER VERİ SETİ
  final Map<String, List<String>> _turkiyeData = {
    "Adana": [
      "Aladağ",
      "Ceyhan",
      "Çukurova",
      "Feke",
      "İmamoğlu",
      "Karaisalı",
      "Karataş",
      "Kozan",
      "Pozantı",
      "Saimbeyli",
      "Sarıçam",
      "Seyhan",
      "Tufanbeyli",
      "Yumurtalık",
      "Yüreğir",
    ],
    "Adıyaman": [
      "Besni",
      "Çelikhan",
      "Gerger",
      "Gölbaşı",
      "Kahta",
      "Merkez",
      "Samsat",
      "Sincik",
      "Tut",
    ],
    "Afyonkarahisar": [
      "Başmakçı",
      "Bayat",
      "Bolvadin",
      "Çay",
      "Çobanlar",
      "Dazkırı",
      "Dinar",
      "Emirdağ",
      "Evciler",
      "Hocalar",
      "İhsaniye",
      "İscehisar",
      "Kızılören",
      "Merkez",
      "Sandıklı",
      "Sinanpaşa",
      "Sultandağı",
      "Şuhut",
    ],
    "Ağrı": [
      "Diyadin",
      "Doğubayazıt",
      "Eleşkirt",
      "Hamur",
      "Merkez",
      "Patnos",
      "Taşlıçay",
      "Tutak",
    ],
    "Amasya": [
      "Göynücek",
      "Gümüşhacıköy",
      "Hamamözü",
      "Merkez",
      "Merzifon",
      "Suluova",
      "Taşova",
    ],
    "Ankara": [
      "Akyurt",
      "Altındağ",
      "Ayaş",
      "Bala",
      "Beypazarı",
      "Çamlıdere",
      "Çankaya",
      "Çubuk",
      "Elmadağ",
      "Etimesgut",
      "Evren",
      "Gölbaşı",
      "Güdül",
      "Haymana",
      "Kahramankazan",
      "Kalecik",
      "Keçiören",
      "Kızılcahamam",
      "Mamak",
      "Nallıhan",
      "Polatlı",
      "Pursaklar",
      "Sincan",
      "Şereflikoçhisar",
      "Yenimahalle",
    ],
    "Antalya": [
      "Akseki",
      "Aksu",
      "Alanya",
      "Demre",
      "Döşemealtı",
      "Elmalı",
      "Finike",
      "Gazipaşa",
      "Gündoğmuş",
      "İbradı",
      "Kaş",
      "Kemer",
      "Kepez",
      "Konyaaltı",
      "Korkuteli",
      "Kumluca",
      "Manavgat",
      "Muratpaşa",
      "Serik",
    ],
    "Artvin": [
      "Ardanuç",
      "Arhavi",
      "Borçka",
      "Hopa",
      "Kemalpaşa",
      "Merkez",
      "Murgul",
      "Şavşat",
      "Yusufeli",
    ],
    "Aydın": [
      "Bozdoğan",
      "Buharkent",
      "Çine",
      "Didim",
      "Efeler",
      "Germencik",
      "İncirliova",
      "Karacasu",
      "Koçarlı",
      "Köşk",
      "Kuşadası",
      "Kuyucak",
      "Nazilli",
      "Söke",
      "Sultanhisar",
      "Yenipazar",
    ],
    "Balıkesir": [
      "Altıeylül",
      "Ayvalık",
      "Balya",
      "Bandırma",
      "Bigadiç",
      "Burhaniye",
      "Dursunbey",
      "Edremit",
      "Erdek",
      "Gömeç",
      "Gönen",
      "Havran",
      "İvrindi",
      "Karesi",
      "Kepsut",
      "Manyas",
      "Marmara",
      "Savaştepe",
      "Sındırgı",
      "Susurluk",
    ],
    "Bursa": [
      "Büyükorhan",
      "Gemlik",
      "Gürsu",
      "Harmancık",
      "İnegöl",
      "İznik",
      "Karacabey",
      "Keles",
      "Kestel",
      "Mudanya",
      "Mustafakemalpaşa",
      "Nilüfer",
      "Orhaneli",
      "Orhangazi",
      "Osmangazi",
      "Yenişehir",
      "Yıldırım",
    ],
    "Çanakkale": [
      "Ayvacık",
      "Bayramiç",
      "Biga",
      "Bozcaada",
      "Çan",
      "Eceabat",
      "Ezine",
      "Gelibolu",
      "Gökçeada",
      "Lapseki",
      "Merkez",
      "Yenice",
    ],
    "Denizli": [
      "Acıpayam",
      "Babadağ",
      "Baklan",
      "Bekilli",
      "Beyağaç",
      "Bozkurt",
      "Buldan",
      "Çal",
      "Çameli",
      "Çardak",
      "Çivril",
      "Güney",
      "Honaz",
      "Kale",
      "Merkezefendi",
      "Pamukkale",
      "Sarayköy",
      "Serinhisar",
      "Tavas",
    ],
    "Diyarbakır": [
      "Bağlar",
      "Bismil",
      "Çermik",
      "Çınar",
      "Çüngüş",
      "Dicle",
      "Eğil",
      "Ergani",
      "Hani",
      "Hazro",
      "Kayapınar",
      "Kocaköy",
      "Kulp",
      "Lice",
      "Silvan",
      "Sur",
      "Yenişehir",
    ],
    "Edirne": [
      "Enez",
      "Havsa",
      "İpsala",
      "Keşan",
      "Lalapaşa",
      "Meriç",
      "Merkez",
      "Süloğlu",
      "Uzunköprü",
    ],
    "Elazığ": [
      "Ağın",
      "Alacakaya",
      "Arıcak",
      "Baskil",
      "Karakoçan",
      "Keban",
      "Kovancılar",
      "Maden",
      "Merkez",
      "Palu",
      "Sivrice",
    ],
    "Erzurum": [
      "Aşkale",
      "Aziziye",
      "Çat",
      "Hınıs",
      "Horasan",
      "İspir",
      "Karaçoban",
      "Karayazı",
      "Köprüköy",
      "Narman",
      "Oltu",
      "Olur",
      "Palandöken",
      "Pasinline",
      "Pazaryolu",
      "Şenkaya",
      "Tekman",
      "Tortum",
      "Uzundere",
      "Yakutiye",
    ],
    "Eskişehir": [
      "Alpu",
      "Beylikova",
      "Çifteler",
      "Günyüzü",
      "Han",
      "İnönü",
      "Mahmudiye",
      "Mihalgazi",
      "Mihalıççık",
      "Odunpazarı",
      "Sarıcakaya",
      "Seyitgazi",
      "Sivrihisar",
      "Tepebaşı",
    ],
    "Gaziantep": [
      "Araban",
      "İslahiye",
      "Karkamış",
      "Nizip",
      "Nurdağı",
      "Oğuzeli",
      "Şahinbey",
      "Şehitkamil",
      "Yavuzeli",
    ],
    "Hatay": [
      "Altınözü",
      "Antakya",
      "Arsuz",
      "Belen",
      "Defne",
      "Dörtyol",
      "Erzin",
      "Hassa",
      "İskenderun",
      "Kırıkhan",
      "Kumlu",
      "Payas",
      "Reyhanlı",
      "Samandağ",
      "Yayladağı",
    ],
    "İstanbul": [
      "Adalar",
      "Arnavutköy",
      "Ataşehir",
      "Avcılar",
      "Bağcılar",
      "Bahçelievler",
      "Bakırköy",
      "Başakşehir",
      "Bayrampaşa",
      "Beşiktaş",
      "Beykoz",
      "Beylikdüzü",
      "Beyoğlu",
      "Büyükçekmece",
      "Çatalca",
      "Çekmeköy",
      "Esenler",
      "Esenyurt",
      "Eyüpsultan",
      "Fatih",
      "Gaziosmanpaşa",
      "Güngören",
      "Kadıköy",
      "Kağıthane",
      "Kartal",
      "Küçükçekmece",
      "Maltepe",
      "Pendik",
      "Sancaktepe",
      "Sarıyer",
      "Silivri",
      "Sultanbeyli",
      "Sultangazi",
      "Şile",
      "Şişli",
      "Tuzla",
      "Ümraniye",
      "Üsküdar",
      "Zeytinburnu",
    ],
    "İzmir": [
      "Aliağa",
      "Balçova",
      "Bayraklı",
      "Bornova",
      "Buca",
      "Çeşme",
      "Çiğli",
      "Dikili",
      "Foça",
      "Gaziemir",
      "Karabağlar",
      "Karaburun",
      "Karşıyaka",
      "Kemalpaşa",
      "Kınık",
      "Kiraz",
      "Konak",
      "Menderes",
      "Menemen",
      "Narlıdere",
      "Ödemiş",
      "Seferihisar",
      "Selçuk",
      "Tire",
      "Torbalı",
      "Urla",
    ],
    "Kırklareli": [
      "Babaeski",
      "Demirköy",
      "Kofçaz",
      "Lüleburgaz",
      "Merkez",
      "Pehlivanköy",
      "Pınarhisar",
      "Vize",
    ],
    "Kocaeli": [
      "Başiskele",
      "Çayırova",
      "Darıca",
      "Derince",
      "Dilovası",
      "Gebze",
      "Gölcük",
      "İzmit",
      "Kandıra",
      "Karamürsel",
      "Kartepe",
      "Körfez",
    ],
    "Konya": [
      "Ahırlı",
      "Akören",
      "Akşehir",
      "Altınekin",
      "Beyşehir",
      "Bozkır",
      "Cihanbeyli",
      "Çeltik",
      "Çumra",
      "Derbent",
      "Derebucak",
      "Doğanhisar",
      "Emirgazi",
      "Ereğli",
      "Güneysınır",
      "Hadim",
      "Halkapınar",
      "Hüyük",
      "Ilgın",
      "Kadınhanı",
      "Karapınar",
      "Karatay",
      "Kulu",
      "Meram",
      "Sarayönü",
      "Selçuklu",
      "Seydişehir",
      "Taşkent",
      "Tuzlukçu",
      "Yalıhüyük",
      "Yunak",
    ],
    "Muğla": [
      "Bodrum",
      "Dalaman",
      "Datça",
      "Fethiye",
      "Kavaklıdere",
      "Köyceğiz",
      "Marmaris",
      "Menteşe",
      "Milas",
      "Ortaca",
      "Seydikemer",
      "Ula",
      "Yatağan",
    ],
    "Sakarya": [
      "Adapazarı",
      "Akyazı",
      "Arifiye",
      "Erenler",
      "Ferizli",
      "Geyve",
      "Hendek",
      "Karapürçek",
      "Karasu",
      "Kaynarca",
      "Kocaali",
      "Pamukova",
      "Sapanca",
      "Serdivan",
      "Söğütlü",
      "Taraklı",
    ],
    "Samsun": [
      "19 Mayıs",
      "Alaçam",
      "Asarcık",
      "Atakum",
      "Ayvacık",
      "Bafra",
      "Canik",
      "Çarşamba",
      "Havza",
      "İlkadım",
      "Kavak",
      "Ladik",
      "Salıpazarı",
      "Tekkeköy",
      "Terme",
      "Vezirköprü",
      "Yakakent",
    ],
    "Tekirdağ": [
      "Çerkezköy",
      "Çorlu",
      "Ergene",
      "Hayrabolu",
      "Kapaklı",
      "Malkara",
      "Marmaraereğlisi",
      "Muratlı",
      "Saray",
      "Süleymanpaşa",
      "Şarköy",
    ],
    "Trabzon": [
      "Akçaabat",
      "Araklı",
      "Arsin",
      "Beşikdüzü",
      "Çarşıbaşı",
      "Çaykara",
      "Dernekpazarı",
      "Düzköy",
      "Hayrat",
      "Köprübaşı",
      "Maçka",
      "Of",
      "Ortahisar",
      "Sürmene",
      "Şalpazarı",
      "Tonya",
      "Vakfıkebir",
      "Yomra",
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeAllData();
    });
  }

  Future<void> _initializeAllData() async {
    final provider = context.read<StoreProvider>();
    final token = await secureStorage.read(key: "token");

    // ✅ 403 HATASI ÇÖZÜMÜ: Token hatalıysa veya yoksa otomatik Public veriyi çek.
    try {
      if (token != null && token.isNotEmpty) {
        setState(() => _cachedToken = token);
        await provider.fetchStores(token: token);
      } else {
        await provider.fetchStoresPublic();
      }
    } catch (e) {
      debugPrint("⚠️ Yetki Hatası (403): Public veriye dönülüyor...");
      await provider.fetchStoresPublic();
    }

    // ✅ TIMEOUT ÇÖZÜMÜ: Konum gelmese bile liste asılı kalmaz.
    _handleLocationDetection(provider);
  }

  Future<void> _handleLocationDetection(StoreProvider provider) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // En düşük hassasiyette (lowest) daha hızlı sonuç alınır.
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.lowest,
          timeLimit: const Duration(seconds: 4),
        );

        await _myStorage.saveLocation(position.latitude, position.longitude);
        Map<String, String> address = await _myStorage.getAddressFromCoords();

        if (address["city"] != null) {
          String city =
              address["city"]!
                  .replaceAll(" İli", "")
                  .replaceAll(" İl", "")
                  .trim();
          if (_turkiyeData.containsKey(city)) {
            provider.updateLocationFilter(city, address["district"] ?? "");
            debugPrint("📍 Otomatik konum uygulandı: $city");
          }
        }
      }
    } catch (e) {
      debugPrint("📍 Konum atlandı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final sortedList = provider.sortedStores;

    return AppLayout(
      body: Column(
        children: [
          _buildLocationPicker(provider),
          Expanded(
            child:
                provider.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0F172A),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _initializeAllData,
                      child:
                          sortedList.isEmpty
                              ? _buildEmptyState()
                              : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: sortedList.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent: 210,
                                    ),
                                itemBuilder: (context, index) {
                                  return _AnimatedStoreCard(
                                    storeData: sortedList[index],
                                    index: index,
                                    token: _cachedToken ?? "",
                                  );
                                },
                              ),
                    ),
          ),
        ],
      ),
      bottomBar: const UserBottomBar(currentIndex: 0),
    );
  }

  Widget _buildLocationPicker(StoreProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _styledDropdown(
              hint: "İl",
              value:
                  provider.selectedCity.isEmpty ? null : provider.selectedCity,
              items: _turkiyeData.keys.toList()..sort(),
              onChanged: (val) => provider.updateLocationFilter(val!, ""),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _styledDropdown(
              hint: "İlçe",
              value:
                  provider.selectedDistrict.isEmpty
                      ? null
                      : provider.selectedDistrict,
              items: _turkiyeData[provider.selectedCity] ?? [],
              onChanged:
                  (val) => provider.updateLocationFilter(
                    provider.selectedCity,
                    val!,
                  ),
            ),
          ),
          if (provider.selectedCity.isNotEmpty)
            IconButton(
              onPressed: () => provider.updateLocationFilter("", ""),
              icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _styledDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          isExpanded: true,
          items:
              items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.mapLocationDot,
            size: 50,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Dükkan bulunamadı.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStoreCard extends StatefulWidget {
  final StoreResponse storeData;
  final int index;
  final String token;

  const _AnimatedStoreCard({
    required this.storeData,
    required this.index,
    required this.token,
  });

  @override
  State<_AnimatedStoreCard> createState() => _AnimatedStoreCardState();
}

class _AnimatedStoreCardState extends State<_AnimatedStoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favController;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final isFav = provider.isFavorite(widget.storeData.store.id);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChairAvailabilityScreen(
                          adminId: widget.storeData.admin.id,
                        ),
                  ),
                ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 65,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.store,
                        color: Colors.white.withOpacity(0.1),
                        size: 30,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storeData.store.storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Yönetici: ${widget.storeData.admin.adminName}",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _badge(
                              FontAwesomeIcons.chair,
                              "${widget.storeData.chairs.length}",
                              Colors.blue,
                            ),
                            _badge(
                              FontAwesomeIcons.userCheck,
                              "${widget.storeData.employees.length}",
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _FavoriteButton(
              isFav: isFav,
              onTap: () {
                if (widget.token.isNotEmpty) {
                  if (!isFav) _favController.forward(from: 0);
                  provider.toggleFavorite(
                    token: widget.token,
                    storeId: widget.storeData.store.id,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Favoriye eklemek için giriş yapmalısınız.",
                      ),
                    ),
                  );
                }
              },
              controller: _favController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;
  final AnimationController controller;

  const _FavoriteButton({
    required this.isFav,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isFav)
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 2.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.4, end: 0.0).animate(controller),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder:
                  (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                key: ValueKey(isFav),
                color: isFav ? Colors.redAccent : Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
