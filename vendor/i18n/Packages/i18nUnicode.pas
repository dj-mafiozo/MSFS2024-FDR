{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// <summary>
/// This unit defines some functions, data types, and constants regarding the
/// Unicode characters.
/// </summary>
Unit i18nUnicode;

{$I DELPHIAREA.INC}

Interface

 Const

  {$Region 'xmldoc'}
  /// <summary>
  /// Unicode Control Character: Left-to-right mark (LRM)
  /// </summary>
  /// <remarks>
  /// Acts exactly like left-to-right characters, except that it is not displayed.
  /// LRM does not have any other semantic effect.
  /// </remarks>
  {$Endregion}
  UCC_LMR = #$200E;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Right-to-left mark (RLM)
/// </summary>
/// <remarks>
/// Acts exactly like right-to-left characters, except that it is not displayed.
/// RLM does not have any other semantic effect.
/// </remarks>
{$Endregion}
  UCC_RLM = #$200F;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Zero-width joiner (ZWJ)
/// </summary>
/// <remarks>
/// Prevents the joining of consecutive characters on output.
/// </remarks>
{$Endregion}
  UCC_ZWJ = #$200D;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Zero width non-joiner (ZWNJ)
/// </summary>
/// <remarks>
/// Adds a non-joiner between two characters to prevent them from forming a
/// cursive connection with each other when rendered.
/// </remarks>
{$Endregion}
  UCC_ZWNJ = #$200C;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Start of left-to-right embedding (LRE)
/// </summary>
/// <remarks>
/// Signals that a piece of text is to be treated as embedded left-to-right.
/// For example, an English quotation in the middle of an Arabic sentence could
/// be marked as being embedded left-to-right text.
/// NOTE: LRE affects word order, not character order.
/// </remarks>
{$Endregion}
  UCC_LRE = #$202A;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Start of right-to-left embedding (RLE)
/// </summary>
/// <remarks>
/// Signals that a piece of text is to be treated as embedded right-to-left.
/// For example, a Hebrew phrase in the middle of an English quotation could be
/// marked as being embedded right-to-left.
/// NOTE: RLE affects word order, not character order.
/// </remarks>
{$Endregion}
  UCC_RLE = #$202B;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Start of left-to-right override (LRO)
/// </summary>
/// <remarks>
/// Overrides bidirectional character types when required for special cases, such
/// as for part numbers. LRO forces characters to be treated as strong left-to-right
/// characters.
/// </remarks>
{$Endregion}
  UCC_LRO = #$202D;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Start of right-to-left override (RLO)
/// </summary>
/// <remarks>
/// Overrides bidirectional character types when required for special cases, such
/// as for part numbers. RLO forces characters to be treated as strong right-to-left
/// characters.
/// </remarks>
{$Endregion}
  UCC_RLO = #$202E;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Pop directional formatting (PDF)
/// </summary>
/// <remarks>
/// Terminates the effects of the last explicit code (either embedding or override)
/// and restores the bidirectional state to what it was before the last LRE, RLE,
/// RLO, or LRO control characters.
/// </remarks>
{$Endregion}
  UCC_PDF = #$202C;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: National digit shapes substitution (NADS)
/// </summary>
/// <remarks>
/// Uses national digit shapes to display the U+0030-U+0039 (ASCII numerals). The
/// national digit shapes are determined by the current user locale.
/// </remarks>
{$Endregion}
  UCC_NADS = #$206E;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Nominal (European) digit shapes (NODS)
/// </summary>
/// <remarks>
/// Uses the nominal digit shapes for the digits U+0030-U+0039 (ASCII digits).
/// Nominal digit shapes are Western digits.
/// </remarks>
{$Endregion}
  UCC_NODS = #$206F;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Activate symmetric swapping (ASS)
/// </summary>
/// <remarks>
/// Indicates whether the term LEFT or RIGHT in pairs of character names, such
/// as parentheses, should be interpreted as meaning opening or closing, respectively.
/// The default state is activated.
/// </remarks>
{$Endregion}
  UCC_ASS = #$206B;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Inhibit symmetric swapping (ISS)
/// </summary>
/// <remarks>
/// Turns off the symmetric swapping of characters such as parenthesis, so that left
/// and right continue to mean left and right facing, as opposed to opening and closing,
/// when symmetric swapping is on.
/// </remarks>
{$Endregion}
  UCC_ISS = #$206A;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Activate Arabic form shaping (AAFS)
/// </summary>
/// <remarks>
/// Controls the shaping behavior of the Arabic compatibility characters. During the
/// presentation process, certain letterforms may be joined together in cursive
/// connection or ligatures. The shaping selector codes indicate that the character
/// shape determination (glyph selection) process used to achieve this presentation
/// effect is to be either activated or inhibited. The default state is inhibited.
/// </remarks>
{$Endregion}
  UCC_AAFS = #$206D;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Inhibit Arabic form shaping (IAFS)
/// </summary>
/// <remarks>
/// Inhibits the character shaping determination process, so that characters are not
/// shaped based on position.
/// </remarks>
{$Endregion}
  UCC_IAFS = #$206C;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Record Separator (Block separator) (RS)
/// </summary>
/// <remarks>
/// Begins a new line after each line separator.
/// </remarks>
{$Endregion}
  UCC_RS = #$241E;

{$Region 'xmldoc'}
/// <summary>
/// Unicode Control Character: Unit Separator (Segment separator) (US)
/// </summary>
/// <remarks>
/// Begins a new paragraph after each paragraph separator.
/// </remarks>
{$Endregion}
  UCC_US = #$241F;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// This enumeration type identifies the different types of scripts.
  /// </summary>
  {$Endregion}
  TUnicodeScript = (
  {$Region 'xmldoc'}
  /// Arabic
  {$Endregion}
  usArabic,
  {$Region 'xmldoc'}
  /// Imperial Aramaic
  {$Endregion}
  usImperialAramaic,
  {$Region 'xmldoc'}
  /// Armenian
  {$Endregion}
  usArmenian,
  {$Region 'xmldoc'}
  /// Avestan
  {$Endregion}
  usAvestan,
  {$Region 'xmldoc'}
  /// Balinese
  {$Endregion}
  usBalinese,
  {$Region 'xmldoc'}
  /// Bamum
  {$Endregion}
  usBamum,
  {$Region 'xmldoc'}
  /// Bassa Vah
  {$Endregion}
  usBassaVah,
  {$Region 'xmldoc'}
  /// Batak
  {$Endregion}
  usBatak,
  {$Region 'xmldoc'}
  /// Bengali
  {$Endregion}
  usBengali,
  {$Region 'xmldoc'}
  /// Blissymbols
  {$Endregion}
  usBlissymbols,
  {$Region 'xmldoc'}
  /// Bopomofo
  {$Endregion}
  usBopomofo,
  {$Region 'xmldoc'}
  /// Brahmi
  {$Endregion}
  usBrahmi,
  {$Region 'xmldoc'}
  /// Braille
  {$Endregion}
  usBraille,
  {$Region 'xmldoc'}
  /// Buginese
  {$Endregion}
  usBuginese,
  {$Region 'xmldoc'}
  /// Buhid
  {$Endregion}
  usBuhid,
  {$Region 'xmldoc'}
  /// Chakma
  {$Endregion}
  usChakma,
  {$Region 'xmldoc'}
  /// Unified Canadian Aboriginal Syllabics
  {$Endregion}
  usUnifiedCanadianAboriginalSyllabics,
  {$Region 'xmldoc'}
  /// Carian
  {$Endregion}
  usCarian,
  {$Region 'xmldoc'}
  /// Cham
  {$Endregion}
  usCham,
  {$Region 'xmldoc'}
  /// Cherokee
  {$Endregion}
  usCherokee,
  {$Region 'xmldoc'}
  /// Cirth
  {$Endregion}
  usCirth,
  {$Region 'xmldoc'}
  /// Coptic
  {$Endregion}
  usCoptic,
  {$Region 'xmldoc'}
  /// Cypriot
  {$Endregion}
  usCypriot,
  {$Region 'xmldoc'}
  /// Cyrillic
  {$Endregion}
  usCyrillic,
  {$Region 'xmldoc'}
  /// Cyrillic (Old Church Slavonic variant)
  {$Endregion}
  usCyrillic_OldChurchSlavonic,
  {$Region 'xmldoc'}
  /// Devanagari (Nagari)
  {$Endregion}
  usDevanagari,
  {$Region 'xmldoc'}
  /// Deseret (Mormon)
  {$Endregion}
  usDeseret,
  {$Region 'xmldoc'}
  /// Duployan shorthand, Duployan stenography
  {$Endregion}
  usDuployan,
  {$Region 'xmldoc'}
  /// Egyptian demotic
  {$Endregion}
  usEgyptianDemotic,
  {$Region 'xmldoc'}
  /// Egyptian hieratic
  {$Endregion}
  usEgyptianHieratic,
  {$Region 'xmldoc'}
  /// Egyptian hieroglyphs
  {$Endregion}
  usEgyptianHieroglyphs,
  {$Region 'xmldoc'}
  /// Elbasan
  {$Endregion}
  usElbasan,
  {$Region 'xmldoc'}
  /// Ethiopic
  {$Endregion}
  usEthiopic,
  {$Region 'xmldoc'}
  /// Khutsuri
  {$Endregion}
  usKhutsuri,
  {$Region 'xmldoc'}
  /// Georgian (Mkhedruli)
  {$Endregion}
  usGeorgian,
  {$Region 'xmldoc'}
  /// Glagolitic
  {$Endregion}
  usGlagolitic,
  {$Region 'xmldoc'}
  /// Gothic
  {$Endregion}
  usGothic,
  {$Region 'xmldoc'}
  /// Grantha
  {$Endregion}
  usGrantha,
  {$Region 'xmldoc'}
  /// Greek
  {$Endregion}
  usGreek,
  {$Region 'xmldoc'}
  /// Gujarati
  {$Endregion}
  usGujarati,
  {$Region 'xmldoc'}
  /// Gurmukhi
  {$Endregion}
  usGurmukhi,
  {$Region 'xmldoc'}
  /// Hangul (Hangŭl, Hangeul)
  {$Endregion}
  usHangul,
  {$Region 'xmldoc'}
  /// Han (Hanzi, Kanji, Hanja)
  {$Endregion}
  usHan,
  {$Region 'xmldoc'}
  /// Hanunoo (Hanunóo)
  {$Endregion}
  usHanunoo,
  {$Region 'xmldoc'}
  /// Han (Simplified variant)
  {$Endregion}
  usHan_Simplified,
  {$Region 'xmldoc'}
  /// Han (Traditional variant)
  {$Endregion}
  usHan_Traditional,
  {$Region 'xmldoc'}
  /// Hebrew
  {$Endregion}
  usHebrew,
  {$Region 'xmldoc'}
  /// Hiragana
  {$Endregion}
  usHiragana,
  {$Region 'xmldoc'}
  /// Pahawh Hmong
  {$Endregion}
  usPahawhHmong,
  {$Region 'xmldoc'}
  /// (alias for Hiragana + Katakana)
  {$Endregion}
  usHiraganaKatakana,
  {$Region 'xmldoc'}
  /// Old Hungarian
  {$Endregion}
  usOldHungarian,
  {$Region 'xmldoc'}
  /// Indus (Harappan)
  {$Endregion}
  usIndus,
  {$Region 'xmldoc'}
  /// Old Italic (Etruscan, Oscan, etc.)
  {$Endregion}
  usOldItalic,
  {$Region 'xmldoc'}
  /// Javanese
  {$Endregion}
  usJavanese,
  {$Region 'xmldoc'}
  /// Japanese (alias for Han + Hiragana + Katakana)
  {$Endregion}
  usJapanese,
  {$Region 'xmldoc'}
  /// Kayah Li
  {$Endregion}
  usKayahLi,
  {$Region 'xmldoc'}
  /// Katakana
  {$Endregion}
  usKatakana,
  {$Region 'xmldoc'}
  /// Kharoshthi
  {$Endregion}
  usKharoshthi,
  {$Region 'xmldoc'}
  /// Khmer
  {$Endregion}
  usKhmer,
  {$Region 'xmldoc'}
  /// Kannada
  {$Endregion}
  usKannada,
  {$Region 'xmldoc'}
  /// Korean (alias for Hangul + Han)
  {$Endregion}
  usKorean,
  {$Region 'xmldoc'}
  /// Kpelle
  {$Endregion}
  usKpelle,
  {$Region 'xmldoc'}
  /// Kaithi
  {$Endregion}
  usKaithi,
  {$Region 'xmldoc'}
  /// Tai Tham (Lanna)
  {$Endregion}
  usTaiTham,
  {$Region 'xmldoc'}
  /// Lao
  {$Endregion}
  usLao,
  {$Region 'xmldoc'}
  /// Latin (Fraktur variant)
  {$Endregion}
  usLatin_Fraktur,
  {$Region 'xmldoc'}
  /// Latin (Gaelic variant)
  {$Endregion}
  usLatin_Gaelic,
  {$Region 'xmldoc'}
  /// Latin
  {$Endregion}
  usLatin,
  {$Region 'xmldoc'}
  /// Lepcha (Róng)
  {$Endregion}
  usLepcha,
  {$Region 'xmldoc'}
  /// Limbu
  {$Endregion}
  usLimbu,
  {$Region 'xmldoc'}
  /// Linear A
  {$Endregion}
  usLinearA,
  {$Region 'xmldoc'}
  /// Linear B
  {$Endregion}
  usLinearB,
  {$Region 'xmldoc'}
  /// Lisu (Fraser)
  {$Endregion}
  usLisu,
  {$Region 'xmldoc'}
  /// Loma
  {$Endregion}
  usLoma,
  {$Region 'xmldoc'}
  /// Lycian
  {$Endregion}
  usLycian,
  {$Region 'xmldoc'}
  /// Lydian
  {$Endregion}
  usLydian,
  {$Region 'xmldoc'}
  /// Mandaic
  {$Endregion}
  usMandaic,
  {$Region 'xmldoc'}
  /// Manichaean
  {$Endregion}
  usManichaean,
  {$Region 'xmldoc'}
  /// Mayan hieroglyphs
  {$Endregion}
  usMayanHieroglyphs,
  {$Region 'xmldoc'}
  /// Mende
  {$Endregion}
  usMende,
  {$Region 'xmldoc'}
  /// Meroitic Cursive
  {$Endregion}
  usMeroiticCursive,
  {$Region 'xmldoc'}
  /// Meroitic Hieroglyphs
  {$Endregion}
  usMeroiticHieroglyphs,
  {$Region 'xmldoc'}
  /// Malayalam
  {$Endregion}
  usMalayalam,
  {$Region 'xmldoc'}
  /// Mongolian
  {$Endregion}
  usMongolian,
  {$Region 'xmldoc'}
  /// Moon (Moon code, Moon script, Moon type)
  {$Endregion}
  usMoon,
  {$Region 'xmldoc'}
  /// Meitei Mayek (Meithei, Meetei)
  {$Endregion}
  usMeiteiMayek,
  {$Region 'xmldoc'}
  /// Myanmar (Burmese)
  {$Endregion}
  usMyanmar,
  {$Region 'xmldoc'}
  /// Old North Arabian (Ancient North Arabian)
  {$Endregion}
  usOldNorthArabian,
  {$Region 'xmldoc'}
  /// Nabataean
  {$Endregion}
  usNabataean,
  {$Region 'xmldoc'}
  /// Nakhi Geba ('Na-'Khi ²Ggŏ-¹baw, Naxi Geba)
  {$Endregion}
  usNakhiGeba,
  {$Region 'xmldoc'}
  /// N’Ko
  {$Endregion}
  usNKo,
  {$Region 'xmldoc'}
  /// Ogham
  {$Endregion}
  usOgham,
  {$Region 'xmldoc'}
  /// Ol Chiki (Ol Cemet’, Ol, Santali)
  {$Endregion}
  usOlChiki,
  {$Region 'xmldoc'}
  /// Old Turkic, Orkhon Runic
  {$Endregion}
  usOldTurkicOrkhonRunic,
  {$Region 'xmldoc'}
  /// Oriya
  {$Endregion}
  usOriya,
  {$Region 'xmldoc'}
  /// Osmanya
  {$Endregion}
  usOsmanya,
  {$Region 'xmldoc'}
  /// Palmyrene
  {$Endregion}
  usPalmyrene,
  {$Region 'xmldoc'}
  /// Old Permic
  {$Endregion}
  usOldPermic,
  {$Region 'xmldoc'}
  /// Phags-pa
  {$Endregion}
  usPhagsPa,
  {$Region 'xmldoc'}
  /// Inscriptional Pahlavi
  {$Endregion}
  usInscriptionalPahlavi,
  {$Region 'xmldoc'}
  /// Psalter Pahlavi
  {$Endregion}
  usPsalterPahlavi,
  {$Region 'xmldoc'}
  /// Book Pahlavi
  {$Endregion}
  usBookPahlavi,
  {$Region 'xmldoc'}
  /// Phoenician
  {$Endregion}
  usPhoenician,
  {$Region 'xmldoc'}
  /// Miao (Pollard)
  {$Endregion}
  usMiao,
  {$Region 'xmldoc'}
  /// Inscriptional Parthian
  {$Endregion}
  usInscriptionalParthian,
  {$Region 'xmldoc'}
  /// Reserved for private use (start)
  {$Endregion}
  usReservedStart,
  {$Region 'xmldoc'}
  /// Reserved for private use (end)
  {$Endregion}
  usReservedEnd,
  {$Region 'xmldoc'}
  /// Rejang (Redjang, Kaganga)
  {$Endregion}
  usRejang,
  {$Region 'xmldoc'}
  /// Rongorongo
  {$Endregion}
  usRongorongo,
  {$Region 'xmldoc'}
  /// Runic
  {$Endregion}
  usRunic,
  {$Region 'xmldoc'}
  /// Samaritan
  {$Endregion}
  usSamaritan,
  {$Region 'xmldoc'}
  /// Sarati
  {$Endregion}
  usSarati,
  {$Region 'xmldoc'}
  /// Old South Arabian
  {$Endregion}
  usOldSouthArabian,
  {$Region 'xmldoc'}
  /// Saurashtra
  {$Endregion}
  usSaurashtra,
  {$Region 'xmldoc'}
  /// SignWriting
  {$Endregion}
  usSignWriting,
  {$Region 'xmldoc'}
  /// Shavian (Shaw)
  {$Endregion}
  usShavian,
  {$Region 'xmldoc'}
  /// Sindhi
  {$Endregion}
  usSindhi,
  {$Region 'xmldoc'}
  /// Sinhala
  {$Endregion}
  usSinhala,
  {$Region 'xmldoc'}
  /// Sundanese
  {$Endregion}
  usSundanese,
  {$Region 'xmldoc'}
  /// Syloti Nagri
  {$Endregion}
  usSylotiNagri,
  {$Region 'xmldoc'}
  /// Syriac
  {$Endregion}
  usSyriac,
  {$Region 'xmldoc'}
  /// Syriac (Estrangelo variant)
  {$Endregion}
  usSyriac_Estrangelo,
  {$Region 'xmldoc'}
  /// Syriac (Western variant)
  {$Endregion}
  usSyriac_Western,
  {$Region 'xmldoc'}
  /// Syriac (Eastern variant)
  {$Endregion}
  usSyriac_Eastern,
  {$Region 'xmldoc'}
  /// Tagbanwa
  {$Endregion}
  usTagbanwa,
  {$Region 'xmldoc'}
  /// Tai
  {$Endregion}
  usTai,
  {$Region 'xmldoc'}
  /// New Tai Lue
  {$Endregion}
  usNewTaiLue,
  {$Region 'xmldoc'}
  /// Tamil
  {$Endregion}
  usTamil,
  {$Region 'xmldoc'}
  /// Tai Viet
  {$Endregion}
  usTaiViet,
  {$Region 'xmldoc'}
  /// Telugu
  {$Endregion}
  usTelugu,
  {$Region 'xmldoc'}
  /// Tengwar
  {$Endregion}
  usTengwar,
  {$Region 'xmldoc'}
  /// Tifinagh (Berber)
  {$Endregion}
  usTifinagh,
  {$Region 'xmldoc'}
  /// Tagalog (Baybayin, Alibata)
  {$Endregion}
  usTagalog,
  {$Region 'xmldoc'}
  /// Thaana
  {$Endregion}
  usThaana,
  {$Region 'xmldoc'}
  /// Thai
  {$Endregion}
  usThai,
  {$Region 'xmldoc'}
  /// Tibetan
  {$Endregion}
  usTibetan,
  {$Region 'xmldoc'}
  /// Ugaritic
  {$Endregion}
  usUgaritic,
  {$Region 'xmldoc'}
  /// Vai
  {$Endregion}
  usVai,
  {$Region 'xmldoc'}
  /// Visible Speech
  {$Endregion}
  usVisibleSpeech,
  {$Region 'xmldoc'}
  /// Warang Citi (Varang Kshiti)
  {$Endregion}
  usWarangCiti,
  {$Region 'xmldoc'}
  /// Old Persian
  {$Endregion}
  usOldPersian,
  {$Region 'xmldoc'}
  /// Cuneiform, Sumero-Akkadian
  {$Endregion}
  usCuneiformSumeroAkkadian,
  {$Region 'xmldoc'}
  /// Yi
  {$Endregion}
  usYi,
  {$Region 'xmldoc'}
  /// Code for inherited script
  {$Endregion}
  usInherited,
  {$Region 'xmldoc'}
  /// Mathematical notation
  {$Endregion}
  usMathematical,
  {$Region 'xmldoc'}
  /// Symbols
  {$Endregion}
  usSymbols,
  {$Region 'xmldoc'}
  /// Unwritten documents
  {$Endregion}
  usUnwritten,
  {$Region 'xmldoc'}
  /// Undetermined script
  {$Endregion}
  usUndetermined,
  {$Region 'xmldoc'}
  /// Uncoded script
  {$Endregion}
  usUncoded
  );

{$Region 'xmldoc'}
/// <summary>
/// This data type represents a set of <see cref="TUnicodeScript"/> values.
/// </summary>
{$Endregion}

  TUnicodeScripts = Set Of TUnicodeScript;

{$Region 'xmldoc'}
/// <summary>
/// Converts a semicolon separated list of the four-character ISO 15924 script
/// codes to a set of <see cref="TUnicodeScript"/> values.
/// </summary>
/// <param name="Codes">
/// The semicolon separated list of the four-character codes.
/// </param>
/// <returns>
/// The set of <see cref="TUnicodeScript"/> values.
/// </returns>
/// <seealso cref="ScriptsToScriptCodes"/>
{$Endregion}

 Function ScriptCodesToScripts(Const Codes : String) : TUnicodeScripts;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts a set of <see cref="TUnicodeScript"/> values to a semicolon separated
 /// list of the four characters ISO 15924 script codes.
 /// </summary>
 /// <param name="Scripts">
 /// The set of <see cref="TUnicodeScript"/> values.
 /// </param>
 /// <returns>
 /// The semicolon separated list of the four-character codes.
 /// </returns>
 /// <seealso cref="ScriptCodesToScripts"/>
 {$Endregion}
 Function ScriptsToScriptCodes(Scripts : TUnicodeScripts) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Determines whether the specified character is a Unicode separator character.
 /// </summary>
 /// <param name="C">
 /// The character to check.
 /// </param>
 /// <returns>
 /// <see langword="true"/> if the character is a separator; otherwise, <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function CharIsSeparator(c : Char) : Boolean; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Determines whether the specified character is a letter.
 /// </summary>
 /// <param name="C">
 /// The character to check.
 /// </param>
 /// <returns>
 /// <see langword="true"/> if the character is a letter; otherwise, <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function CharIsLetter(c : Char) : Boolean; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Determines whether the specified character is a digit.
 /// </summary>
 /// <param name="C">
 /// The character to check.
 /// </param>
 /// <returns>
 /// <see langword="true"/> if the character is a digit; otherwise, <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function CharIsDigit(c : Char) : Boolean; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Determines whether the specified character is a letter or digit.
 /// </summary>
 /// <param name="C">
 /// The character to check.
 /// </param>
 /// <returns>
 /// <see langword="true"/> if the character is a letter or digit; otherwise, <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function CharIsLetterOrDigit(c : Char) : Boolean; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Determines whether the specified character is a whitespace character.
 /// </summary>
 /// <param name="C">
 /// The character to check.
 /// </param>
 /// <returns>
 /// <see langword="true"/> if the character is a whitespace; otherwise, <see langword="false"/>.
 /// </returns>
 {$Endregion}
 Function CharIsWhiteSpace(c : Char) : Boolean; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts the specified character to uppercase.
 /// </summary>
 /// <param name="C">
 /// The character to convert.
 /// </param>
 /// <returns>
 /// The uppercase equivalent of the character.
 /// </returns>
 {$Endregion}
 Function CharToUpper(c : Char) : Char; Inline;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts the specified character to lowercase.
 /// </summary>
 /// <param name="C">
 /// The character to convert.
 /// </param>
 /// <returns>
 /// The lowercase equivalent of the character.
 /// </returns>
 {$Endregion}
 Function CharToLower(c : Char) : Char; Inline;

Implementation

 Uses
  SysUtils, Types
  {$IFDEF COMPILER_XE4_UP}
  , System.Character
  {$ENDIF}
  ;

 Const
  // ISO 15924 script codes in alphabetical order
  ScriptCodes : Array [TUnicodeScript] Of PChar = (
  'Arab', 'Armi', 'Armn', 'Avst', 'Bali', 'Bamu', 'Bass', 'Batk', 'Beng',
  'Blis', 'Bopo', 'Brah', 'Brai', 'Bugi', 'Buhd', 'Cakm', 'Cans', 'Cari',
  'Cham', 'Cher', 'Cirt', 'Copt', 'Cprt', 'Cyrl', 'Cyrs', 'Deva', 'Dsrt',
  'Dupl', 'Egyd', 'Egyh', 'Egyp', 'Elba', 'Ethi', 'Geok', 'Geor', 'Glag',
  'Goth', 'Gran', 'Grek', 'Gujr', 'Guru', 'Hang', 'Hani', 'Hano', 'Hans',
  'Hant', 'Hebr', 'Hira', 'Hmng', 'Hrkt', 'Hung', 'Inds', 'Ital', 'Java',
  'Jpan', 'Kali', 'Kana', 'Khar', 'Khmr', 'Knda', 'Kore', 'Kpel', 'Kthi',
  'Lana', 'Laoo', 'Latf', 'Latg', 'Latn', 'Lepc', 'Limb', 'Lina', 'Linb',
  'Lisu', 'Loma', 'Lyci', 'Lydi', 'Mand', 'Mani', 'Maya', 'Mend', 'Merc',
  'Mero', 'Mlym', 'Mong', 'Moon', 'Mtei', 'Mymr', 'Narb', 'Nbat', 'Nkgb',
  'Nkoo', 'Ogam', 'Olck', 'Orkh', 'Orya', 'Osma', 'Palm', 'Perm', 'Phag',
  'Phli', 'Phlp', 'Phlv', 'Phnx', 'Plrd', 'Prti', 'Qaaa', 'Qabx', 'Rjng',
  'Roro', 'Runr', 'Samr', 'Sara', 'Sarb', 'Saur', 'Sgnw', 'Shaw', 'Sind',
  'Sinh', 'Sund', 'Sylo', 'Syrc', 'Syre', 'Syrj', 'Syrn', 'Tagb', 'Tale',
  'Talu', 'Taml', 'Tavt', 'Telu', 'Teng', 'Tfng', 'Tglg', 'Thaa', 'Thai',
  'Tibt', 'Ugar', 'Vaii', 'Visp', 'Wara', 'Xpeo', 'Xsux', 'Yiii', 'Zinh',
  'Zmth', 'Zsym', 'Zxxx', 'Zyyy', 'Zzzz');

 Function CharIsSeparator(c : Char) : Boolean;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.IsSeparator;
  End;
{$ELSE}

 Var
  CharType : Word;

Begin
 GetStringTypeEx(LOCALE_USER_DEFAULT, CT_CTYPE1, @c, 1, CharType);
 Result := ((CharType And C1_SPACE) <> 0) Or (c = #$2028) Or (c = #$2029);

End;
{$ENDIF}

 Function CharIsLetter(c : Char) : Boolean;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.IsLetter;
  End;
{$ELSE}

Begin
 Result := IsLetter(c);

End;
{$ENDIF}

 Function CharIsDigit(c : Char) : Boolean;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.IsDigit;
  End;
{$ELSE}

Begin
 Result := IsDigit(c);

End;
{$ENDIF}

 Function CharIsLetterOrDigit(c : Char) : Boolean;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.IsLetterOrDigit;
  End;
{$ELSE}

Begin
 Result := IsLetterOrDigit(c);

End;
{$ENDIF}

 Function CharIsWhiteSpace(c : Char) : Boolean;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.IsWhiteSpace;
  End;
{$ELSE}

Begin
 Result := IsCharWhiteSpace(c);

End;
{$ENDIF}

 Function CharToUpper(c : Char) : Char;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.ToUpper;
  End;
{$ELSE}

Begin
 Result := UpCase(c);

End;
{$ENDIF}

 Function CharToLower(c : Char) : Char;
 {$IFDEF COMPILER_XE4_UP}
  Begin
   Result := c.ToLower;
  End;
{$ELSE}

Begin
 CharLowerBuff(@c, 1);
 Result := c;

End;
{$ENDIF}

 Function FindScript(pCode : PChar; Out Script : TUnicodeScript) : Boolean;
  Var
   l : TUnicodeScript;
   h : TUnicodeScript;
   c : Integer;
  Begin
   l := Low(TUnicodeScript);
   h := High(TUnicodeScript);
   Repeat
    Script := TUnicodeScript((Ord(l) + Ord(h)) Shr 1);
    c      := StrLIComp(ScriptCodes[Script], pCode, 4);
    If c < 0 Then
     l := Succ(Script)
    Else If c > 0 Then
     h := Pred(Script)
    Else
     Begin
      Result := True;
      Exit;
     End;
   Until l > h;
   Result := False;
  End;

 Function ScriptCodesToScripts(Const Codes : String) : TUnicodeScripts;
  Var
   Script : TUnicodeScript;
   s      : PChar;
   e      : PChar;
  Begin
   Result := [];
   s      := PChar(Codes);
   e      := StrScan(s, ';');
   While e <> Nil Do
    Begin
     If (e - s = 4) And FindScript(s, Script) Then
      Include(Result, Script);
     s := e + 1;
     If s^ = #0 Then
      Exit;
     e := StrScan(s, ';');
    End;
  End;

 Function ScriptsToScriptCodes(Scripts : TUnicodeScripts) : String;
  Var
   Script : TUnicodeScript;
  Begin
   Result     := '';
   For Script := Low(TUnicodeScript) To High(TUnicodeScript) Do
    If Script In Scripts Then
     Result := Result + ScriptCodes[Script] + ';';
  End;

End.
