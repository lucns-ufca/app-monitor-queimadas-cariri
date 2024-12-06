class Constants {
  static const double DEFAULT_ROUND_BORDER = 56;
  static const double DEFAULT_WIDGET_HEIGHT = 40;
  // Fonte IBGE: https://cidades.ibge.gov.br/brasil/ce/abaiara/panorama
  static final Map<String, dynamic> CITIES_DATA = {
    'Abaiara': CityData(name: 'Abaiara', latitude: -7.349389, longitude: -39.033383, geographicalArea: const Tuple(key: '2022', value: '180,833'), urbanizedArea: const Tuple(key: '2019', value: '3,19'), population: const Tuple(key: '2022', value: '10.038')),
    'Altaneira': CityData(name: 'Altaneira', latitude: -6.998939, longitude: -39.738878, geographicalArea: const Tuple(key: '2022', value: '72,675'), urbanizedArea: const Tuple(key: '2019', value: '1,48'), population: const Tuple(key: '2022', value: '6.782')),
    'Antonina do Norte':
        CityData(name: 'Antonina do Norte', latitude: -6.775348, longitude: -39.988188, geographicalArea: const Tuple(key: '2022', value: '259,706'), urbanizedArea: const Tuple(key: '2019', value: '1,50'), population: const Tuple(key: '2022', value: '7.245')),
    'Araripe': CityData(name: 'Araripe', latitude: -7.211309, longitude: -40.138323, geographicalArea: const Tuple(key: '2022', value: '1.097,339'), urbanizedArea: const Tuple(key: '2019', value: '3,43'), population: const Tuple(key: '2022', value: '19.783')),
    'Assaré': CityData(name: 'Assaré', latitude: -6.870889, longitude: -39.871030, geographicalArea: const Tuple(key: '2022', value: '1.155,124'), urbanizedArea: const Tuple(key: '2019', value: '3,33'), population: const Tuple(key: '2022', value: '21.697')),
    'Aurora': CityData(name: 'Aurora', latitude: -6.943031, longitude: -38.969761, geographicalArea: const Tuple(key: '2022', value: '885,870'), urbanizedArea: const Tuple(key: '2019', value: '2,73'), population: const Tuple(key: '2022', value: '23.714')),
    'Baixio': CityData(name: 'Baixio', latitude: -6.730631, longitude: -38.716898, geographicalArea: const Tuple(key: '2022', value: '145,556'), urbanizedArea: const Tuple(key: '2019', value: '0,68'), population: const Tuple(key: '2022', value: '5.704')),
    'Barbalha':
        CityData(name: 'Barbalha', latitude: -7.288738, longitude: -39.299320, geographicalArea: const Tuple(key: '2022', value: '608,158'), urbanizedArea: const Tuple(key: '2019', value: '20,64'), population: const Tuple(key: '2022', value: '75.033')),
    'Brejo Santo':
        CityData(name: 'Brejo Santo', latitude: -7.488500, longitude: -38.987459, geographicalArea: const Tuple(key: '2022', value: '654,658'), urbanizedArea: const Tuple(key: '2019', value: '13,00'), population: const Tuple(key: '2022', value: '51.090')),
    'Barro': CityData(name: 'Barro', latitude: -7.174146, longitude: -38.779534, geographicalArea: const Tuple(key: '2022', value: '711,346'), urbanizedArea: const Tuple(key: '2019', value: '3,34'), population: const Tuple(key: '2022', value: '19.381')),
    'Caririaçu':
        CityData(name: 'Caririaçu', latitude: -7.042127, longitude: -39.285435, geographicalArea: const Tuple(key: '2022', value: '634,179'), urbanizedArea: const Tuple(key: '2019', value: '5,40'), population: const Tuple(key: '2022', value: '26.320')),
    'Crato': CityData(name: 'Crato', latitude: -7.231216, longitude: -39.410477, geographicalArea: const Tuple(key: '2022', value: '1.138,150'), urbanizedArea: const Tuple(key: '2019', value: '32,21'), population: const Tuple(key: '2022', value: '131.050')),
    'Campos Sales':
        CityData(name: 'Campos Sales', latitude: -7.075103, longitude: -40.372339, geographicalArea: const Tuple(key: '2022', value: '1.082,582'), urbanizedArea: const Tuple(key: '2019', value: '4,63'), population: const Tuple(key: '2022', value: '25.135')),
    'Farias Brito':
        CityData(name: 'Farias Brito', latitude: -6.928198, longitude: -39.571438, geographicalArea: const Tuple(key: '2022', value: '530,540'), urbanizedArea: const Tuple(key: '2019', value: '3,08'), population: const Tuple(key: '2022', value: '18.217')),
    'Granjeiro':
        CityData(name: 'Granjeiro', latitude: -6.887292, longitude: -39.220469, geographicalArea: const Tuple(key: '2022', value: '111,528'), urbanizedArea: const Tuple(key: '2019', value: '0,91'), population: const Tuple(key: '2022', value: '4.841')),
    'Ipaumirim':
        CityData(name: 'Ipaumirim', latitude: -6.789527, longitude: -38.718022, geographicalArea: const Tuple(key: '2022', value: '276,508'), urbanizedArea: const Tuple(key: '2019', value: '1,36'), population: const Tuple(key: '2022', value: '12.083')),
    'Jati': CityData(name: 'Jati', latitude: -7.688990, longitude: -39.005227, geographicalArea: const Tuple(key: '2022', value: '368,359'), urbanizedArea: const Tuple(key: '2019', value: '1,98'), population: const Tuple(key: '2022', value: '7.861')),
    'Jardim': CityData(name: 'Jardim', latitude: -7.586031, longitude: -39.279563, geographicalArea: const Tuple(key: '2022', value: '544,980'), urbanizedArea: const Tuple(key: '2019', value: '5,41'), population: const Tuple(key: '2022', value: '27.411')),
    'Juazeiro do Norte': CityData(name: 'Juazeiro do Norte', latitude: -7.228166, geographicalArea: const Tuple(key: '2022', value: '258,788'), urbanizedArea: const Tuple(key: '2019', value: '51,44'), population: const Tuple(key: '2022', value: '286.120')),
    'Lavras da Mangabeira': CityData(
        name: 'Lavras da Mangabeira', latitude: -6.752719, longitude: -38.965939, geographicalArea: const Tuple(key: '2022', value: '945,263'), urbanizedArea: const Tuple(key: '2019', value: '3,69'), population: const Tuple(key: '2022', value: '30.802')),
    'Mauriti': CityData(name: 'Mauriti', latitude: -7.382958, longitude: -38.771900, geographicalArea: const Tuple(key: '2022', value: '1.079,011'), urbanizedArea: const Tuple(key: '2019', value: '9,44'), population: const Tuple(key: '2022', value: '45.561')),
    'Milagres': CityData(name: 'Milagres', latitude: -7.310940, longitude: -38.938627, geographicalArea: const Tuple(key: '2022', value: '579,097'), urbanizedArea: const Tuple(key: '2019', value: '6,73'), population: const Tuple(key: '2022', value: '25.900')),
    'Nova Olinda':
        CityData(name: 'Nova Olinda', latitude: -7.092372, longitude: -39.678686, geographicalArea: const Tuple(key: '2022', value: '282,584'), urbanizedArea: const Tuple(key: '2019', value: '3,35'), population: const Tuple(key: '2022', value: '15.399')),
    'Porteiras':
        CityData(name: 'Porteiras', latitude: -7.534501, longitude: -39.116856, geographicalArea: const Tuple(key: '2022', value: '224,860'), urbanizedArea: const Tuple(key: '2019', value: '5,01'), population: const Tuple(key: '2022', value: '17.050')),
    'Potengi': CityData(name: 'Potengi', latitude: -7.091934, longitude: -40.027603, geographicalArea: const Tuple(key: '2022', value: '343,264'), urbanizedArea: const Tuple(key: '2019', value: '1,68'), population: const Tuple(key: '2022', value: '8.833')),
    'Penaforte':
        CityData(name: 'Penaforte', latitude: -7.830278, longitude: -39.072340, geographicalArea: const Tuple(key: '2022', value: '150,536'), urbanizedArea: const Tuple(key: '2019', value: '1,34'), population: const Tuple(key: '2022', value: '8.972')),
    'Santana do Cariri': CityData(
        name: 'Santana do Cariri', latitude: -7.185914, longitude: -39.737159, geographicalArea: const Tuple(key: '2022', value: '855,165'), urbanizedArea: const Tuple(key: '2019', value: '2,56'), population: const Tuple(key: '2022', value: '16.954')),
    'Salitre': CityData(name: 'Salitre', latitude: -7.285748, longitude: -40.457514, geographicalArea: const Tuple(key: '2022', value: '806,253'), urbanizedArea: const Tuple(key: '2019', value: '2,14'), population: const Tuple(key: '2022', value: '16.633')),
    'Tarrafas': CityData(name: 'Tarrafas', latitude: -6.684036, longitude: -39.758108, geographicalArea: const Tuple(key: '2022', value: '412,719'), urbanizedArea: const Tuple(key: '2019', value: '1,85'), population: const Tuple(key: '2022', value: '7.529')),
    'Umari': CityData(name: 'Umari', latitude: -6.644247, longitude: -38.699599, geographicalArea: const Tuple(key: '2022', value: '263,183'), urbanizedArea: const Tuple(key: '2019', value: '0,92'), population: const Tuple(key: '2022', value: '6.871')),
  };

  static const String FCM_TOPIC_ALERT_FIRE = 'monitor_queimadas_cariri-alert_fire';
}

class CityData {
  String name;
  Tuple geographicalArea, urbanizedArea, population;
  double latitude, longitude;

  CityData({this.name = "", this.latitude = 0, this.longitude = 0, this.geographicalArea = const Tuple(), this.urbanizedArea = const Tuple(), this.population = const Tuple()});
}

class Tuple {
  final String? key, value;

  const Tuple({this.key, this.value});
}
