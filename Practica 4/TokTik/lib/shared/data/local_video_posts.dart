List<Map<String, dynamic>> videoPosts = [
  {
    'name': 'Subiendo escaleras automáticas',
    'videoUrl': 'assets/videos/1.mp4',
    'likes': 23230,
    'views': 1523,       // ❌ likes > views → se filtra (ilógico)
  },
  {
    'name': 'Planta apreciada por peatones',
    'videoUrl': 'assets/videos/2.mp4',
    'likes': 24230,
    'views': 1343,       // ❌ likes > views → se filtra (ilógico)
  },
  {
    'name': 'Que borroso veo todo!',
    'videoUrl': 'assets/videos/3.mp4',
    'likes': 21564320,
    'views': 123563,     // ❌ likes > views → se filtra (ilógico)
  },
  {
    'name': '¿Esto es trigo? que interesante',
    'videoUrl': 'assets/videos/4.mp4',
    'likes': 320,
    'views': 2300,       // ✅ válido
  },
  {
    'name': 'El COVID no me afecta',
    'videoUrl': 'assets/videos/5.mp4',
    'likes': 3230,
    'views': 31030,      // ✅ válido
  },
  {
    'name': 'No quiero ir a trabajar hoy señor Stark',
    'videoUrl': 'assets/videos/6.mp4',
    'likes': 10,
    'views': 330,        // ✅ válido
  },
  {
    'name': 'Limpiar nunca fue tan divertido',
    'videoUrl': 'assets/videos/7.mp4',
    'likes': 1320,
    'views': 33032,      // ✅ válido
  },
  {
    'name': '¿Ya llegamos a la India?... umm si',
    'videoUrl': 'assets/videos/8.mp4',
    'likes': 342,
    'views': 3332,       // ✅ válido
  },
  {
    'name': 'Esta tortuga es mi ídola',
    'videoUrl': 'assets/videos/9.mp4',
    'likes': 845,
    'views': 1231,       // ✅ válido
  },
  {
    'name': 'El mejor gato que he visto en mi vida',
    'videoUrl': 'assets/videos/10.mp4',
    'likes': 214,
    'views': 1231,       // ✅ válido
  },
  {
    'name': 'Jugando xbox',
    'videoUrl': 'assets/videos/11.mp4',
    'likes': 2135,
    'views': 12312,      // ✅ válido
  },
  {
    'name': 'Bonito gato',
    'videoUrl': 'assets/videos/12.mp4',
    'likes': 678,
    'views': 987,        // ✅ válido
  },
  {
    'name': 'Gato dormilon',
    'videoUrl': 'assets/videos/13.mp4',
    'likes': 8899,
    'views': 43212,      // ✅ válido
  },
  {
    'name': 'Tigre muy amable :3',
    'videoUrl': 'assets/videos/14.mp4',
    'likes': 23,
    'views': 123,        // ✅ válido
  },
];
