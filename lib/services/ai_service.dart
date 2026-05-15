import '../models/ai_reflection.dart';

class AiService {
  static Future<AiReflection> generateReflection(String moodId, String note) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final responses = {
      'excited': AiReflection(
        reflection:
            "What wonderful energy you're experiencing! This excitement is a sign of passion and readiness. Embrace this moment and let it fuel meaningful action.",
        keywords: ['energized', 'vibrant', 'optimistic'],
        suggestion: 'Channel this positive energy into a project or activity you love.',
      ),
      'happy': AiReflection(
        reflection:
            "Happiness is blooming in your heart right now. This joy reminds you of what truly matters. Hold onto this feeling and share it with those around you.",
        keywords: ['joyful', 'content', 'grateful'],
        suggestion:
            'Take a moment to appreciate what brought you this happiness today.',
      ),
      'love': AiReflection(
        reflection:
            "Love is a beautiful force that connects us. Whether directed toward a person, place, or passion, this feeling enriches your life deeply. Nurture it with care.",
        keywords: ['connected', 'cherished', 'tender'],
        suggestion: 'Express your appreciation to someone or something you love today.',
      ),
      'calm': AiReflection(
        reflection:
            "You've found your peaceful center. This calm is your inner strength, a place of clarity and balance. Rest here and let it replenish your spirit.",
        keywords: ['serene', 'grounded', 'centered'],
        suggestion: 'Spend time in stillness—meditation, journaling, or quiet reflection.',
      ),
      'neutral': AiReflection(
        reflection:
            "Neutrality can be a place of observation and acceptance. You're witnessing your emotions without judgment. This objectivity is a form of wisdom.",
        keywords: ['balanced', 'observant', 'steady'],
        suggestion:
            'Use this clarity to reflect on what matters most to you right now.',
      ),
      'sad': AiReflection(
        reflection:
            "Your sadness is valid and deserves acknowledgment. It's a signal that something matters to you. Be gentle with yourself—this feeling will move through you.",
        keywords: ['melancholic', 'reflective', 'tender'],
        suggestion:
            'Try doing something soothing—write, listen to music, or reach out to someone you trust.',
      ),
      'crying': AiReflection(
        reflection:
            "Tears are a release, a healing flow. Whatever you're feeling deeply enough to cry about deserves compassion. Let yourself feel fully, then rest.",
        keywords: ['vulnerable', 'cathartic', 'hopeful'],
        suggestion:
            'Be kind to yourself right now—do something comforting or simply rest.',
      ),
      'angry': AiReflection(
        reflection:
            "Your anger is a messenger. It shows you what your boundaries are and what matters to you. Channel this intensity into positive change or healthy release.",
        keywords: ['powerful', 'awakened', 'determined'],
        suggestion:
            'Consider journaling or physical activity to release this energy constructively.',
      ),
    };

    return responses[moodId] ??
        AiReflection(
          reflection:
              'Every emotion you feel is part of your unique journey. Trust yourself.',
          keywords: ['authentic', 'resilient', 'worthy'],
          suggestion: 'Take time to honor your feelings, whatever they may be.',
        );
  }
}
