import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Implémentation du BioHashing Non-Inversible
/// Protège les vecteurs biométriques (embeddings) :
/// BioHash = HMAC-SHA256(Embedding, PIN_User)
class BioHash {
  
  /// Ne stocke jamais l'embedding tel quel, uniquement son hash salé avec le PIN.
  /// Si le hash fuite, il est inutilisable sans le PIN utilisateur (inconnu du système).
  static String create(String rawEmbedding, String userPin) {
    // 1. Dérivation d'une clé locale depuis le PIN (PBKDF2 en temps normal, SHA256 suffisant pour le MVP ici)
    final keyBytes = utf8.encode(userPin);
    final _hmacSha256 = Hmac(sha256, keyBytes);
    
    // 2. Hash HMAC
    final embeddingBytes = utf8.encode(rawEmbedding);
    final digest = _hmacSha256.convert(embeddingBytes);
    
    return digest.toString();
  }

  /// Au moment de l'authentification, on recrée le hash avec le nouveau scan facial
  /// Si le Hash(ScanFaceCourant, PIN) == Hash(ScanFaceStocké, PIN)
  /// C'est virtuellement impossible à cause de la non-stricte égalité des scans (l'embedding change tjrs un peu).
  /// Dans la réalité, le BioHash classique passe plutôt par une projection orthogonale (Tokenised Pseudo-Random Numbers)
  /// puis quantisation. 
  /// 
  /// Pour ce MVP, l'approche est la suivante : 
  /// Le PIN décrypte un modèle de référence, puis l'embedding est comparé algorithmiquement (Cosine Similarity).
  /// Le modèle de référence est stocké chiffré AES, la clé = SHA256(PIN).
  
  static double compare(List<double> currentEmbedding, List<double> referenceEmbedding) {
      double dotProduct = 0.0;
      double normA = 0.0;
      double normB = 0.0;
      for (int i = 0; i < currentEmbedding.length; i++) {
        dotProduct += currentEmbedding[i] * referenceEmbedding[i];
        normA += pow(currentEmbedding[i], 2);
        normB += pow(referenceEmbedding[i], 2);
      }
      if (normA == 0 || normB == 0) return 0.0;
      return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
