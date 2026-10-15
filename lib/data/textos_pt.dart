// Textos em português para as raças. A The Cat API só devolve inglês,
// então o app traduz com tabelas locais. O que não estiver nas tabelas
// continua aparecendo como a API mandou.

// Descrição de cada raça (nome da raça em minúsculas -> texto em português).
const Map<String, String> _descricoes = {
  'abyssinian':
      'Gato elegante, atlético e muito ativo, de pelagem curta e aspecto selvagem. Curioso e brincalhão, adora explorar e escalar, e gosta de companhia.',
  'aegean':
      'Raça natural das ilhas gregas, ágil e sociável. Gosta de brincar e de conviver com as pessoas, e se adapta bem a diferentes ambientes.',
  'american bobtail':
      'Gato de cauda curta e corpo robusto, com aparência selvagem. Inteligente, brincalhão e muito ligado à família.',
  'american curl':
      'Reconhecido pelas orelhas curvadas para trás. Carinhoso, curioso e sociável, mantém o jeito brincalhão mesmo depois de adulto.',
  'american shorthair':
      'Gato robusto e equilibrado, de pelo curto e boa saúde. Tranquilo e adaptável, convive bem com crianças e outros animais.',
  'american wirehair':
      'Raça rara, de pelo duro e crespo e corpo robusto. Calmo, adaptável e afetuoso com a família.',
  'arabian mau':
      'Gato de porte médio a grande, musculoso e atlético, adaptado ao clima do deserto. Conhecido pela ótima saúde e pelos fortes instintos de sobrevivência.',
  'australian mist':
      'Gato de pelagem manchada e esfumaçada, criado na Austrália. Calmo, afetuoso e ótimo para viver dentro de casa.',
  'balinese':
      'Gato de pelo longo e sedoso, versão de pelo longo do Siamês. Falante, inteligente e muito apegado às pessoas.',
  'bambino':
      'Gato de patas curtas e quase sem pelos, cruzamento de Sphynx com Munchkin. Carinhoso, brincalhão e gosta de calor e de companhia.',
  'bengal':
      'Gato musculoso de pelagem manchada que lembra um felino selvagem. Muito ativo e inteligente, precisa de bastante brincadeira e estímulo.',
  'birman':
      'Gato de pelo longo e sedoso, com olhos azuis e patas brancas. Dócil, carinhoso e apegado à família.',
  'bombay':
      'Gato de pelo preto e brilhante, parecido com uma pantera em miniatura. Afetuoso e sociável, gosta de colo e de atenção.',
  'british longhair':
      'Versão de pelo longo do British Shorthair. Calmo, gentil e discreto, com pelagem macia e volumosa.',
  'british shorthair':
      'Gato robusto, de rosto redondo e pelo denso. Calmo e independente, aceita bem ficar sozinho por algumas horas.',
  'burmese':
      'Gato de porte médio e musculoso, muito apegado às pessoas. Brincalhão e sociável, gosta de estar sempre perto da família.',
  'burmilla':
      'Gato de pelo prateado com contorno escuro, cruzamento de Burmês com Chinchila. Doce, brincalhão e afetuoso.',
  'california spangled':
      'Gato de pelagem manchada que lembra um leopardo, criado a partir de gatos domésticos. Ativo, atlético e curioso.',
  'chantilly-tiffany':
      'Gato de pelo semilongo e sedoso, de cor chocolate. Afetuoso, calmo e muito apegado às pessoas.',
  'chartreux':
      'Gato robusto, de pelagem azul-acinzentada e olhos alaranjados, com um sorriso característico. Calmo, silencioso e leal.',
  'chausie':
      'Gato grande e atlético, com aparência selvagem. Muito ativo e inteligente, precisa de espaço e de bastante atividade.',
  'cheetoh':
      'Gato de pelagem manchada, parecida com a de um guepardo. Ativo, brincalhão e sociável, apesar da aparência selvagem.',
  'colorpoint shorthair':
      'Gato de pelo curto e pontas coloridas, parente do Siamês. Falante, sociável e muito ligado às pessoas.',
  'cornish rex':
      'Gato de pelo curto e ondulado, com corpo esguio e orelhas grandes. Muito ativo, brincalhão e afetuoso.',
  'cymric':
      'Gato de pelo longo e corpo arredondado, parente do Manx. Brincalhão, afetuoso e bom saltador.',
  'cyprus':
      'Gato nativo da ilha de Chipre, de porte médio e boa saúde. Ágil, curioso e adaptável.',
  'devon rex':
      'Gato de pelo ondulado e macio, orelhas grandes e rosto de duende. Brincalhão, sociável e gosta de ficar no colo.',
  'donskoy':
      'Gato sem pelos de origem russa, de pele enrugada. Afetuoso, inteligente e muito apegado à família.',
  'dragon li':
      'Gato chinês de pelagem rajada, forte e atlético. Inteligente, ágil e independente.',
  'egyptian mau':
      'Gato de pelagem naturalmente manchada, considerado um dos mais rápidos entre os domésticos. Leal, ativo e reservado com estranhos.',
  'european burmese':
      'Gato elegante e sociável, de temperamento afetuoso. Brincalhão e muito ligado à família.',
  'exotic shorthair':
      'Gato de rosto achatado e pelo curto e macio, parecido com o Persa. Calmo, carinhoso e fácil de cuidar.',
  'havana brown':
      'Gato de pelagem marrom-chocolate e olhos verdes. Curioso, brincalhão e muito apegado às pessoas, costuma usar as patas para explorar.',
  'himalayan':
      'Gato de pelo longo, olhos azuis e pontas escuras. Dócil e tranquilo, gosta de ambientes calmos e de colo.',
  'japanese bobtail':
      'Gato de cauda curta, parecida com um pompom. Ativo, inteligente e sociável, e no Japão é símbolo de boa sorte.',
  'javanese':
      'Gato de pelo longo e sedoso, esguio e elegante. Comunicativo, brincalhão e muito ligado às pessoas.',
  'khao manee':
      'Gato de pelo branco e curto, com olhos azuis ou de cores diferentes. Ativo, curioso e sociável, também chamado de "gato joia".',
  'korat':
      'Gato de pelagem azul-prateada e olhos verdes, com o rosto em formato de coração. Inteligente e afetuoso, é símbolo de boa sorte na Tailândia.',
  'kurilian':
      'Gato de cauda curta e pelo semilongo, originário das ilhas Curilas. Forte, ativo e bom caçador.',
  'laperm':
      'Gato de pelo encaracolado e macio. Carinhoso, ativo e gosta de ficar perto das pessoas.',
  'maine coon':
      'Uma das maiores raças de gatos domésticos, de pelo longo e denso. Gentil e sociável, costuma ser carinhoso com crianças e outros animais.',
  'malayan':
      'Gato de pelo curto, parente do Burmês, com cores variadas. Sociável, brincalhão e muito falante.',
  'manx':
      'Gato sem cauda ou de cauda muito curta, com corpo arredondado. Afetuoso, brincalhão e ótimo saltador.',
  'munchkin':
      'Gato de patas curtas, conhecido pelo jeito brincalhão. Ativo, sociável e muito curioso, corre e brinca normalmente.',
  'nebelung':
      'Gato de pelo longo, sedoso e azul-prateado, com olhos verdes. Tímido com estranhos, mas carinhoso e leal à família.',
  'norwegian forest cat':
      'Gato grande e robusto, de pelo longo e resistente à água. Independente, mas carinhoso e bom escalador.',
  'ocicat':
      'Gato de pelagem manchada que lembra um felino selvagem, mas totalmente doméstico. Ativo, sociável e muito inteligente.',
  'oriental':
      'Gato esguio, de orelhas grandes e corpo elegante. Muito falante, curioso e ligado às pessoas.',
  'persian':
      'Gato de pelo longo e rosto achatado, calmo e doce. Gosta de ambientes tranquilos e precisa de escovação diária.',
  'pixie-bob':
      'Gato de aparência selvagem, parecido com um lince, de cauda curta e patas grandes. Leal, sociável e inteligente.',
  'ragamuffin':
      'Gato grande, de pelo longo e macio, parente do Ragdoll. Dócil, calmo e muito carinhoso.',
  'ragdoll':
      'Gato grande e de pelo macio, que costuma relaxar no colo. Dócil, calmo e muito carinhoso.',
  'russian blue':
      'Gato de pelagem azul-acinzentada e olhos verdes. Inteligente e reservado com estranhos, mas leal à família.',
  'savannah':
      'Gato alto e esguio, de pelagem manchada e aparência selvagem. Muito ativo, inteligente e curioso.',
  'scottish fold':
      'Gato de orelhas dobradas para frente e rosto redondo. Calmo, doce e sociável.',
  'selkirk rex':
      'Gato de pelo encaracolado e corpo robusto. Calmo, paciente e carinhoso.',
  'siamese':
      'Gato elegante, de olhos azuis e pontas escuras. Muito falante, sociável e apegado às pessoas.',
  'siberian':
      'Gato forte, de pelo longo e denso, adaptado ao frio. Ágil, brincalhão e carinhoso.',
  'singapura':
      'Um dos menores gatos domésticos, de pelo curto e olhos grandes. Curioso, ativo e muito sociável.',
  'snowshoe':
      'Gato de pelagem clara com pontas escuras e patas brancas, como se usasse botas de neve. Carinhoso, sociável e inteligente.',
  'somali':
      'Gato de pelo semilongo e cauda volumosa, parecido com uma raposa. Ativo, brincalhão e muito curioso.',
  'sphynx':
      'Gato sem pelos, de pele enrugada e orelhas grandes. Afetuoso, extrovertido e gosta de calor e de companhia.',
  'tonkinese':
      'Gato de porte médio e pelo curto e macio, cruzamento de Siamês com Burmês. Brincalhão, sociável e muito comunicativo.',
  'toyger':
      'Gato de listras que lembram as de um mini tigre. Sociável, brincalhão e fácil de treinar.',
  'turkish angora':
      'Gato elegante, de pelo longo e sedoso, geralmente branco. Inteligente, ativo e apegado à família.',
  'turkish van':
      'Gato de pelo semilongo, branco com manchas na cabeça e na cauda, que costuma gostar de água. Ativo, inteligente e brincalhão.',
};

// Devolve a descrição em português pelo nome da raça, ou null se não estiver na tabela.
String? descricaoPt(String nome) => _descricoes[nome.trim().toLowerCase()];

// Palavras de temperamento (em minúsculas) -> português.
const Map<String, String> _temperamento = {
  'active': 'Ativo',
  'adaptable': 'Adaptável',
  'affectionate': 'Carinhoso',
  'agile': 'Ágil',
  'alert': 'Alerta',
  'aloof': 'Distante',
  'amiable': 'Amigável',
  'athletic': 'Atlético',
  'calm': 'Calmo',
  'charming': 'Encantador',
  'clever': 'Esperto',
  'companionable': 'Companheiro',
  'courageous': 'Corajoso',
  'creative': 'Criativo',
  'cuddly': 'Dengoso',
  'curious': 'Curioso',
  'demanding': 'Exigente',
  'dependent': 'Dependente',
  'devoted': 'Dedicado',
  'dignified': 'Digno',
  'docile': 'Dócil',
  'easy going': 'Tranquilo',
  'elegant': 'Elegante',
  'energetic': 'Cheio de energia',
  'entertaining': 'Divertido',
  'even tempered': 'Equilibrado',
  'faithful': 'Fiel',
  'fearless': 'Destemido',
  'friendly': 'Amigável',
  'fun-loving': 'Brincalhão',
  'gentle': 'Gentil',
  'good-natured': 'Boa índole',
  'highly intelligent': 'Muito inteligente',
  'independent': 'Independente',
  'inquisitive': 'Inquisitivo',
  'intelligent': 'Inteligente',
  'intense': 'Intenso',
  'interactive': 'Interativo',
  'lively': 'Animado',
  'loving': 'Amoroso',
  'loyal': 'Leal',
  'mild mannered': 'Dócil',
  'mischievous': 'Travesso',
  'obedient': 'Obediente',
  'outgoing': 'Extrovertido',
  'patient': 'Paciente',
  'peaceful': 'Pacífico',
  'perceptive': 'Perceptivo',
  'placid': 'Plácido',
  'playful': 'Brincalhão',
  'protective': 'Protetor',
  'quiet': 'Quieto',
  'relaxed': 'Relaxado',
  'reserved': 'Reservado',
  'responsive': 'Receptivo',
  'self-assured': 'Confiante',
  'sensible': 'Sensato',
  'sensitive': 'Sensível',
  'shy': 'Tímido',
  'smart': 'Esperto',
  'sociable': 'Sociável',
  'social': 'Sociável',
  'spirited': 'Espirituoso',
  'stable': 'Estável',
  'strong willed': 'Determinado',
  'sweet': 'Doce',
  'sweet-tempered': 'Doce',
  'talkative': 'Falante',
  'tenacious': 'Tenaz',
  'timid': 'Tímido',
  'tolerant': 'Tolerante',
  'trainable': 'Fácil de treinar',
  'unique': 'Único',
  'vocal': 'Vocal',
  'warm': 'Caloroso',
};

// Traduz uma palavra de temperamento; se não souber, devolve a original.
String traduzirTemperamento(String palavra) {
  return _temperamento[palavra.trim().toLowerCase()] ?? palavra;
}

// País de origem (em minúsculas) -> português.
const Map<String, String> _paises = {
  'arabian peninsula': 'Península Arábica',
  'australia': 'Austrália',
  'belgium': 'Bélgica',
  'brazil': 'Brasil',
  'burma': 'Birmânia',
  'myanmar': 'Mianmar',
  'canada': 'Canadá',
  'china': 'China',
  'cuba': 'Cuba',
  'cyprus': 'Chipre',
  'egypt': 'Egito',
  'england': 'Inglaterra',
  'ethiopia': 'Etiópia',
  'france': 'França',
  'germany': 'Alemanha',
  'greece': 'Grécia',
  'india': 'Índia',
  'iran (persia)': 'Irã (Pérsia)',
  'ireland': 'Irlanda',
  'isle of man': 'Ilha de Man',
  'italy': 'Itália',
  'japan': 'Japão',
  'mexico': 'México',
  'netherlands': 'Países Baixos',
  'norway': 'Noruega',
  'portugal': 'Portugal',
  'russia': 'Rússia',
  'scotland': 'Escócia',
  'singapore': 'Singapura',
  'somalia': 'Somália',
  'south africa': 'África do Sul',
  'spain': 'Espanha',
  'sweden': 'Suécia',
  'switzerland': 'Suíça',
  'thailand': 'Tailândia',
  'turkey': 'Turquia',
  'united arab emirates': 'Emirados Árabes Unidos',
  'united kingdom': 'Reino Unido',
  'united states': 'Estados Unidos',
};

// Traduz o país de origem; se não souber, devolve o original.
String traduzirOrigem(String pais) {
  return _paises[pais.trim().toLowerCase()] ?? pais;
}