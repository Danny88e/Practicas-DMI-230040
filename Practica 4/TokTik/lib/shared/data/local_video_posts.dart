/// Lista de videos locales almacenados en assets/videos/.
/// Los primeros 3 son inválidos (likes > views) y serán filtrados automáticamente.
List<Map<String, dynamic>> videoPosts = [
  {
    'id': 'local_1',
    'name': 'Subiendo escaleras automáticas',
    'description': 'Una perspectiva curiosa y divertida de las escaleras eléctricas en acción desde un ángulo poco convencional.',
    'videoUrl': 'assets/videos/1.mp4',
    'likes': 23230,
    'views': 1523,   // ❌ likes > views → se filtra (ilógico)
  },
  {
    'id': 'local_2',
    'name': 'Planta apreciada por peatones',
    'description': 'Esta planta ha capturado la atención y admiración de todos los que pasan cerca de ella en la calle.',
    'videoUrl': 'assets/videos/2.mp4',
    'likes': 24230,
    'views': 1343,   // ❌ likes > views → se filtra (ilógico)
  },
  {
    'id': 'local_3',
    'name': 'Que borroso veo todo!',
    'description': 'La perspectiva del mundo a través de un lente completamente desenfocado, todo parece un hermoso sueño borroso.',
    'videoUrl': 'assets/videos/3.mp4',
    'likes': 21564320,
    'views': 123563, // ❌ likes > views → se filtra (ilógico)
  },
  {
    'id': 'local_4',
    'name': '¿Esto es trigo? que interesante',
    'description': 'Explorando los campos y descubriendo la belleza natural de los cultivos de trigo en pleno crecimiento.',
    'videoUrl': 'assets/videos/4.mp4',
    'likes': 320,
    'views': 2300,   // ✅ válido
  },
  {
    'id': 'local_5',
    'name': 'El COVID no me afecta',
    'description': 'Un video lleno de humor sobre la actitud positiva y despreocupada ante las adversidades de la pandemia.',
    'videoUrl': 'assets/videos/5.mp4',
    'likes': 3230,
    'views': 31030,  // ✅ válido
  },
  {
    'id': 'local_6',
    'name': 'No quiero ir a trabajar hoy señor Stark',
    'description': 'Un momento gracioso con referencias directas al universo Marvel que todo fanático va a entender perfectamente.',
    'videoUrl': 'assets/videos/6.mp4',
    'likes': 10,
    'views': 330,    // ✅ válido
  },
  {
    'id': 'local_7',
    'name': 'Limpiar nunca fue tan divertido',
    'description': 'Descubre cómo convertir las aburridas tareas del hogar en una experiencia completamente entretenida y motivadora.',
    'videoUrl': 'assets/videos/7.mp4',
    'likes': 1320,
    'views': 33032,  // ✅ válido
  },
  {
    'id': 'local_8',
    'name': '¿Ya llegamos a la India?... umm si',
    'description': 'Un viaje divertido e inesperado donde el destino resulta ser exactamente lo que nadie esperaba.',
    'videoUrl': 'assets/videos/8.mp4',
    'likes': 342,
    'views': 3332,   // ✅ válido
  },
  {
    'id': 'local_9',
    'name': 'Esta tortuga es mi ídola',
    'description': 'Una tortuga extraordinaria que nos deja completamente sin palabras con sus increíbles habilidades y determinación.',
    'videoUrl': 'assets/videos/9.mp4',
    'likes': 845,
    'views': 1231,   // ✅ válido
  },
  {
    'id': 'local_10',
    'name': 'El mejor gato que he visto en mi vida',
    'description': 'Este felino ha demostrado ser absolutamente único entre todos los gatos del mundo con sus reacciones increíbles.',
    'videoUrl': 'assets/videos/10.mp4',
    'likes': 214,
    'views': 1231,   // ✅ válido
  },
  {
    'id': 'local_11',
    'name': 'Jugando xbox',
    'description': 'Sesión de gaming épica con momentos increíbles que todo gamer va a entender y disfrutar al máximo.',
    'videoUrl': 'assets/videos/11.mp4',
    'likes': 2135,
    'views': 12312,  // ✅ válido
  },
  {
    'id': 'local_12',
    'name': 'Bonito gato',
    'description': 'Un gato adorable que conquista corazones con su ternura indescriptible y sus movimientos llenos de gracia.',
    'videoUrl': 'assets/videos/12.mp4',
    'likes': 678,
    'views': 987,    // ✅ válido
  },
  {
    'id': 'local_13',
    'name': 'Gato dormilon',
    'description': 'Nada mejor en la vida que ver a un gato disfrutar de una larga, profunda y placentera siesta sin preocupaciones.',
    'videoUrl': 'assets/videos/13.mp4',
    'likes': 8899,
    'views': 43212,  // ✅ válido
  },
  {
    'id': 'local_14',
    'name': 'Tigre muy amable :3',
    'description': 'Un encuentro sorprendente con un tigre majestuoso que muestra su lado más amable, juguetón y completamente adorable.',
    'videoUrl': 'assets/videos/14.mp4',
    'likes': 23,
    'views': 123,    // ✅ válido
  },
];
