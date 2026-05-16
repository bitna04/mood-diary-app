import 'dart:math';
import '../models/ai_reflection.dart';

class AiService {
  static final Random _random = Random();

  static Future<AiReflection> generateReflection(String moodId, String note) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final reflections = _getReflectionsForMood(moodId);
    return reflections[_random.nextInt(reflections.length)];
  }

  static List<AiReflection> _getReflectionsForMood(String moodId) {
    switch (moodId) {
      case 'excited':
        return _excitedReflections;
      case 'happy':
        return _happyReflections;
      case 'love':
        return _loveReflections;
      case 'calm':
        return _calmReflections;
      case 'neutral':
        return _neutralReflections;
      case 'sad':
        return _sadReflections;
      case 'crying':
        return _cryingReflections;
      case 'angry':
        return _angryReflections;
      default:
        return _defaultReflections;
    }
  }

  static final List<AiReflection> _excitedReflections = [
    AiReflection(
      reflection: "What wonderful energy you're experiencing! This excitement is a sign of passion and readiness. Embrace this moment and let it fuel meaningful action.",
      keywords: ['energized', 'vibrant', 'optimistic'],
      suggestion: 'Channel this positive energy into a project or activity you love.',
    ),
    AiReflection(
      reflection: "Your enthusiasm is contagious! This spark of joy is a reminder of what makes life worth living. Hold onto this momentum.",
      keywords: ['passionate', 'motivated', 'alive'],
      suggestion: 'Share this energy with someone who needs it.',
    ),
    AiReflection(
      reflection: "The world feels full of possibilities right now. This excitement is your inner voice telling you something wonderful is unfolding.",
      keywords: ['hopeful', 'inspired', 'ready'],
      suggestion: 'Write down your ideas before this moment passes.',
    ),
    AiReflection(
      reflection: "You're riding a wave of positive energy. This is the perfect time to pursue what matters most to you.",
      keywords: ['dynamic', 'driven', 'enthusiastic'],
      suggestion: 'Take action on something you have been planning.',
    ),
    AiReflection(
      reflection: "Your excitement is a powerful force. It shows you are aligned with your values and ready for new experiences.",
      keywords: ['courageous', 'bold', 'radiant'],
      suggestion: 'Challenge yourself to try something new today.',
    ),
    AiReflection(
      reflection: "This electric feeling is your potential coming alive. You are tapping into a source of creative power.",
      keywords: ['creative', 'powerful', 'unstoppable'],
      suggestion: 'Let your excitement guide you to unexpected places.',
    ),
  ];

  static final List<AiReflection> _happyReflections = [
    AiReflection(
      reflection: "Happiness is blooming in your heart right now. This joy reminds you of what truly matters. Hold onto this feeling and share it with those around you.",
      keywords: ['joyful', 'content', 'grateful'],
      suggestion: 'Take a moment to appreciate what brought you this happiness today.',
    ),
    AiReflection(
      reflection: "Your smile is a reflection of a happy heart. This simple joy is one of life's greatest gifts.",
      keywords: ['blessed', 'light', 'glowing'],
      suggestion: 'Look in the mirror and acknowledge your own happiness.',
    ),
    AiReflection(
      reflection: "You have found a moment of pure contentment. This is what peace feels like when mixed with joy.",
      keywords: ['peaceful', 'content', 'serene'],
      suggestion: 'Sit with this feeling without needing to change anything.',
    ),
    AiReflection(
      reflection: "Happiness looks beautiful on you. This warm glow you are feeling is your authentic self shining through.",
      keywords: ['authentic', 'beautiful', 'radiant'],
      suggestion: 'Let others see and feel your genuine happiness.',
    ),
    AiReflection(
      reflection: "This happiness is earned. Whatever led you here, you deserve this moment of joy.",
      keywords: ['deserving', 'worthy', 'rewarded'],
      suggestion: 'Recognize the effort that brought you to this joy.',
    ),
    AiReflection(
      reflection: "You are experiencing the simple perfection of being happy. No grand reason needed, your joy is reason enough.",
      keywords: ['simple', 'perfect', 'pure'],
      suggestion: 'Share your happiness without explaining it.',
    ),
  ];

  static final List<AiReflection> _loveReflections = [
    AiReflection(
      reflection: "Love is a beautiful force that connects us. Whether directed toward a person, place, or passion, this feeling enriches your life deeply. Nurture it with care.",
      keywords: ['connected', 'cherished', 'tender'],
      suggestion: 'Express your appreciation to someone or something you love today.',
    ),
    AiReflection(
      reflection: "You are experiencing the most transformative force in existence. Love opens doors that nothing else can.",
      keywords: ['transformative', 'opening', 'powerful'],
      suggestion: 'Let love guide your decisions today.',
    ),
    AiReflection(
      reflection: "Your heart is overflowing. This love you feel is proof that you are capable of deep connection.",
      keywords: ['overflowing', 'deep', 'connected'],
      suggestion: 'Show your love through actions, not just words.',
    ),
    AiReflection(
      reflection: "Love is making you vulnerable and strong at the same time. This is beautiful.",
      keywords: ['vulnerable', 'strong', 'beautiful'],
      suggestion: 'Embrace both sides of love, the strength and the softness.',
    ),
    AiReflection(
      reflection: "You are experiencing love in its purest form. This feeling is sacred and worthy of protection.",
      keywords: ['sacred', 'pure', 'protected'],
      suggestion: 'Guard this love and let it grow.',
    ),
    AiReflection(
      reflection: "Love is illuminating your world. With it, everything looks brighter and more meaningful.",
      keywords: ['illuminated', 'bright', 'meaningful'],
      suggestion: 'Notice how love changes your perspective.',
    ),
  ];

  static final List<AiReflection> _calmReflections = [
    AiReflection(
      reflection: "You have found your peaceful center. This calm is your inner strength, a place of clarity and balance. Rest here and let it replenish your spirit.",
      keywords: ['serene', 'grounded', 'centered'],
      suggestion: 'Spend time in stillness, meditation, journaling, or quiet reflection.',
    ),
    AiReflection(
      reflection: "Stillness has become your natural state. You are in sync with your own rhythm.",
      keywords: ['still', 'rhythmic', 'natural'],
      suggestion: 'Notice the peace that comes from within.',
    ),
    AiReflection(
      reflection: "Your mind is like a still pond. The clarity you feel is the absence of resistance.",
      keywords: ['clear', 'still', 'transparent'],
      suggestion: 'Let your mind settle even deeper.',
    ),
    AiReflection(
      reflection: "Calm is your superpower. In this state, you can access your deepest wisdom.",
      keywords: ['wise', 'powerful', 'intuitive'],
      suggestion: 'Ask yourself important questions while you are calm.',
    ),
    AiReflection(
      reflection: "You are experiencing the luxury of inner peace. This is a state many search for.",
      keywords: ['peaceful', 'luxurious', 'rare'],
      suggestion: 'Savor this peace as the gift it is.',
    ),
    AiReflection(
      reflection: "Your breath is slow and steady. Your heartbeat is calm. You are in perfect harmony.",
      keywords: ['harmonious', 'steady', 'balanced'],
      suggestion: 'Continue breathing deeply and consciously.',
    ),
  ];

  static final List<AiReflection> _neutralReflections = [
    AiReflection(
      reflection: "Neutrality can be a place of observation and acceptance. You are witnessing your emotions without judgment. This objectivity is a form of wisdom.",
      keywords: ['balanced', 'observant', 'steady'],
      suggestion: 'Use this clarity to reflect on what matters most to you right now.',
    ),
    AiReflection(
      reflection: "You are in a state of equilibrium. This is a powerful position from which to assess your life.",
      keywords: ['balanced', 'powerful', 'clear'],
      suggestion: 'Make important decisions from this balanced perspective.',
    ),
    AiReflection(
      reflection: "Your emotions are resting. This neutrality is a reset button for your mind and heart.",
      keywords: ['resting', 'neutral', 'fresh'],
      suggestion: 'Use this rest to prepare for what comes next.',
    ),
    AiReflection(
      reflection: "You are experiencing the stability of emotional equilibrium. From here, you can move in any direction.",
      keywords: ['stable', 'grounded', 'free'],
      suggestion: 'Consider what direction you want to go.',
    ),
    AiReflection(
      reflection: "Neutrality is often overlooked, but it is a gift. You are neither up nor down, you are steady.",
      keywords: ['steady', 'gifted', 'stable'],
      suggestion: 'Appreciate the steadiness of this state.',
    ),
    AiReflection(
      reflection: "You are in a state of possibility. Neutrality is the blank canvas upon which life is painted.",
      keywords: ['open', 'blank', 'possible'],
      suggestion: 'What would you like to create from here?',
    ),
  ];

  static final List<AiReflection> _sadReflections = [
    AiReflection(
      reflection: "Your sadness is valid and deserves acknowledgment. It is a signal that something matters to you. Be gentle with yourself, this feeling will move through you.",
      keywords: ['melancholic', 'reflective', 'tender'],
      suggestion: 'Try doing something soothing, write, listen to music, or reach out to someone you trust.',
    ),
    AiReflection(
      reflection: "You are grieving something important. This sadness is love that has nowhere to go right now.",
      keywords: ['grieving', 'loving', 'tender'],
      suggestion: 'Allow yourself to feel without judgment.',
    ),
    AiReflection(
      reflection: "Your sadness is a reminder of your capacity to care. That takes courage and tenderness.",
      keywords: ['caring', 'courageous', 'tender'],
      suggestion: 'Honor what you have lost or what you are missing.',
    ),
    AiReflection(
      reflection: "This sadness will pass. Like all emotions, it is temporary, but right now, it is true and real.",
      keywords: ['temporary', 'real', 'authentic'],
      suggestion: 'Let yourself feel the fullness of this moment.',
    ),
    AiReflection(
      reflection: "You are experiencing a necessary sadness. Some things deserve to be mourned.",
      keywords: ['necessary', 'honoring', 'respectful'],
      suggestion: 'Create a ritual to honor what sadness represents.',
    ),
    AiReflection(
      reflection: "Your tears are water from a deep well. They are cleansing and necessary.",
      keywords: ['cleansing', 'deep', 'necessary'],
      suggestion: 'Let your tears flow freely if they want to.',
    ),
  ];

  static final List<AiReflection> _cryingReflections = [
    AiReflection(
      reflection: "Tears are a release, a healing flow. Whatever you are feeling deeply enough to cry about deserves compassion. Let yourself feel fully, then rest.",
      keywords: ['vulnerable', 'cathartic', 'hopeful'],
      suggestion: 'Be kind to yourself right now, do something comforting or simply rest.',
    ),
    AiReflection(
      reflection: "Your tears are water from your soul. They are a sign of deep feeling and profound truth.",
      keywords: ['deep', 'truthful', 'profound'],
      suggestion: 'Let the tears fall as long as they need to.',
    ),
    AiReflection(
      reflection: "You are experiencing an emotional release. Your body is healing through these tears.",
      keywords: ['healing', 'releasing', 'cleansing'],
      suggestion: 'Do not hold back, cry as fully as you need to.',
    ),
    AiReflection(
      reflection: "Crying is your body way of processing what is too big for words. Trust this process.",
      keywords: ['processing', 'trusted', 'necessary'],
      suggestion: 'Let your tears do the work your words cannot.',
    ),
    AiReflection(
      reflection: "These tears are evidence of your capacity to feel deeply. This is a gift, not a weakness.",
      keywords: ['gifted', 'deep', 'strong'],
      suggestion: 'Appreciate your own emotional depth.',
    ),
    AiReflection(
      reflection: "You are grieving something that mattered. Your tears honor what you have lost or are losing.",
      keywords: ['honoring', 'grieving', 'meaningful'],
      suggestion: 'Let your tears be a tribute to what was important.',
    ),
  ];

  static final List<AiReflection> _angryReflections = [
    AiReflection(
      reflection: "Your anger is a messenger. It shows you what your boundaries are and what matters to you. Channel this intensity into positive change or healthy release.",
      keywords: ['powerful', 'awakened', 'determined'],
      suggestion: 'Consider journaling or physical activity to release this energy constructively.',
    ),
    AiReflection(
      reflection: "You are experiencing righteous anger. This means something unjust or harmful has touched you.",
      keywords: ['just', 'aware', 'powerful'],
      suggestion: 'Use this anger to protect yourself or create change.',
    ),
    AiReflection(
      reflection: "Your anger is fire. Fire can burn or light the way. Choose where you direct this power.",
      keywords: ['powerful', 'choice', 'intense'],
      suggestion: 'Channel your anger into something constructive.',
    ),
    AiReflection(
      reflection: "Anger is your boundary setter. It is telling you something crossed a line. Listen to this message.",
      keywords: ['boundary', 'aware', 'protective'],
      suggestion: 'Identify what crossed your boundary and how to protect it.',
    ),
    AiReflection(
      reflection: "You are experiencing passion in its raw form. Anger and passion come from the same place.",
      keywords: ['passionate', 'raw', 'powerful'],
      suggestion: 'Transform your anger into passionate action.',
    ),
    AiReflection(
      reflection: "Your anger is valid. Do not apologize for it, understand it.",
      keywords: ['valid', 'understood', 'rightful'],
      suggestion: 'Ask yourself what your anger is protecting.',
    ),
  ];

  static final List<AiReflection> _defaultReflections = [
    AiReflection(
      reflection: 'Every emotion you feel is part of your unique journey. Trust yourself.',
      keywords: ['authentic', 'resilient', 'worthy'],
      suggestion: 'Take time to honor your feelings, whatever they may be.',
    ),
    AiReflection(
      reflection: 'Your feelings matter. Whatever you are experiencing is valid.',
      keywords: ['valid', 'important', 'meaningful'],
      suggestion: 'Listen to what your emotions are telling you.',
    ),
  ];
}
