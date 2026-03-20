/// Detects racial, ethnic, and anti-trans slurs in user-submitted text.
///
/// Only hard slurs are included — ordinary profanity is intentionally excluded.
/// When a slur is detected the caller should delete the user's account and
/// surface a clear rejection message.
class SlurFilter {
  SlurFilter._();

  /// Returns true if [text] contains a known slur.
  static bool containsSlur(String text) {
    final normalized = _normalize(text);
    return _patterns.any((p) => p.hasMatch(normalized));
  }

  // ── Normalization ──────────────────────────────────────────────────────────
  // Collapse common character substitutions so that n1gg3r, n!gger, etc. all
  // match the same pattern.
  static String _normalize(String input) {
    return input
        .toLowerCase()
        // common letter-swaps
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('@', 'a')
        .replaceAll('\$', 's')
        .replaceAll('!', 'i')
        .replaceAll('|', 'i')
        .replaceAll('+', 't')
        // strip punctuation / spaces that may be inserted between letters
        .replaceAll(RegExp(r'[\s\-_.·•*]'), '');
  }

  // ── Pattern list ───────────────────────────────────────────────────────────
  static final List<RegExp> _patterns = [
    // ── Anti-Black ───────────────────────────────────────────────────────────
    // n-word (nigger / nigga and all common endings)
    RegExp(r'ni+g+[aeiou]*[rz]?[sz]?', caseSensitive: false),
    // coon
    RegExp(r'\bc[o0]+ns?\b', caseSensitive: false),
    // spook (racial usage — matched conservatively as standalone word)
    RegExp(r'\bsp[o0]+ks?\b', caseSensitive: false),
    // porch monkey
    RegExp(r'porch\s*monk(ey|ie)?s?', caseSensitive: false),
    // sambo
    RegExp(r'\bsambo\b', caseSensitive: false),
    // jungle bunny
    RegExp(r'jungle\s*bunn(y|ies)', caseSensitive: false),
    // jigaboo
    RegExp(r'ji+g[aeiou]*b[o0]+', caseSensitive: false),
    // pickaninny
    RegExp(r'pickan[i1]nn(y|ie)', caseSensitive: false),

    // ── Anti-Jewish ──────────────────────────────────────────────────────────
    // kike
    RegExp(r'\bk[iy]+k[ei]*s?\b', caseSensitive: false),
    // hymie / heeb / hebe
    RegExp(r'\bhym[ei]+s?\b', caseSensitive: false),
    RegExp(r'\bhe+b[ei]*s?\b', caseSensitive: false),
    // yid
    RegExp(r'\byids?\b', caseSensitive: false),
    // sheeny
    RegExp(r'\bsheen(y|ie)s?\b', caseSensitive: false),
    // zhid (Eastern European slur)
    RegExp(r'\bzhids?\b', caseSensitive: false),

    // ── Anti-Muslim / Arab ───────────────────────────────────────────────────
    // raghead
    RegExp(r'rag\s*head', caseSensitive: false),
    // towelhead
    RegExp(r'towel\s*head', caseSensitive: false),
    // sandnigger / sand n*
    RegExp(r'sand\s*ni+g+', caseSensitive: false),
    // camel jockey
    RegExp(r'camel\s*joc?ke?y', caseSensitive: false),
    // mozzie / muzz (derogatory)
    RegExp(r'\bmuzz(ie)?s?\b', caseSensitive: false),

    // ── Anti-Trans ───────────────────────────────────────────────────────────
    // tranny / trannie
    RegExp(r'\btrann(y|ie)s?\b', caseSensitive: false),
    // shemale
    RegExp(r'\bshe\s*male\b', caseSensitive: false),
    // he-she / heshe
    RegExp(r'\bhe[\s\-]?she\b', caseSensitive: false),

    // ── Anti-Gay ─────────────────────────────────────────────────────────────
    // fag / faggot
    RegExp(r'\bfag(s|got|gots)?\b', caseSensitive: false),
  ];
}
