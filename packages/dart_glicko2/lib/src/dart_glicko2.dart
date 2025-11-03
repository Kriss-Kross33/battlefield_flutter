import 'dart:math' as math;

/** SYSTEM CONSTANTS **/
const MU = 1500.0;
const PHI = 350.0;
const SIGMA = 0.06;
const TAU = 1.0;
const EPSILON = 0.000001;

/** RESULTS CONSTANTS **/
const win = 1.0;
const draw = 0.5;
const loss = 0.0;

/// Simple container for a single match result used in batch updates.
class MatchResult {
  final double
  score; // 1.0 win, 0.5 draw, 0.0 loss (for the player being updated)
  final Rating opponent;

  const MatchResult({required this.score, required this.opponent});
}

/// {@template rating}
/// Represents a player's rating in Glicko-2.
/// {@endtemplate}
class Rating {
  /// {@macro rating}
  const Rating({this.mu = MU, this.phi = PHI, this.sigma = SIGMA});

  final double mu;
  final double phi;
  final double sigma;

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(mu: json['mu'], phi: json['phi'], sigma: json['sigma']);
  }

  Map<String, dynamic> toJson() {
    return {'mu': mu, 'phi': phi, 'sigma': sigma};
  }

  @override
  String toString() {
    return 'Rating(mu=${this.mu}, phi=${this.phi}, sigma=${this.sigma.toStringAsPrecision(4)}';
  }
}

/// {@template glicko2}
/// Implements the Glicko-2 algorithm (with instant and batch updates).
/// {@endtemplate}
class Glicko2 {
  /// {@macro glicko2}
  Glicko2({
    this.mu = MU,
    this.phi = PHI,
    this.sigma = SIGMA,
    this.tau = TAU,
    this.epsilon = EPSILON,
  });

  final double mu;
  final double phi;
  final double sigma;
  final double tau;
  final double epsilon;

  Rating createRating({double? mu, double? phi, double? sigma}) {
    return Rating(
      mu: mu ?? this.mu,
      phi: phi ?? this.phi,
      sigma: sigma ?? this.sigma,
    );
  }

  Rating scaleDown({required Rating rating, double ratio = 173.7178}) {
    final muScaled = (rating.mu - this.mu) / ratio;
    final phiScaled = rating.phi / ratio;
    return this.createRating(mu: muScaled, phi: phiScaled, sigma: rating.sigma);
  }

  Rating scaleUp({required Rating rating, double ratio = 173.7178}) {
    final muScaled = rating.mu * ratio + this.mu;
    final phiScaled = rating.phi * ratio;
    return this.createRating(mu: muScaled, phi: phiScaled, sigma: rating.sigma);
  }

  /// g(phi) - reduces the impact of opponents with high uncertainty.
  double reduceImpact({required Rating rating}) {
    final double phiSq = math.pow(rating.phi, 2).toDouble();
    return 1.0 / math.sqrt(1 + (3 * phiSq) / math.pow(math.pi, 2));
  }

  /// E(mu, mu_j, phi_j) - expected score of player vs opponent.
  double expectedScore({
    required Rating rating,
    required Rating otherPlayerRating,
    required double impact,
  }) {
    return 1.0 / (1 + math.exp(-impact * (rating.mu - otherPlayerRating.mu)));
  }

  /** Core Glicko2 computations **/
  /// Computes new volatility (sigma).
  double determineSigma({
    required Rating rating,
    required double diff,
    required double variance,
  }) {
    final phiVal = rating.phi;
    final sigmaVal = rating.sigma;
    final tauVal = this.tau;
    final eps = this.epsilon;
    double a = math.log(math.pow(sigmaVal, 2));
    final delta2 = math.pow(diff, 2).toDouble();

    double f(double x) {
      final eX = math.exp(x);
      final tmp = math.pow(phiVal, 2).toDouble() + variance + eX;
      final num = eX * (delta2 - tmp);
      final denom = 2 * math.pow(tmp, 2).toDouble();
      return (num / denom) - ((x - a) / math.pow(tauVal, 2));
    }

    // Bracket search for root
    double b;
    if (delta2 > (math.pow(phiVal, 2).toDouble() + variance)) {
      b = math.log(delta2 - math.pow(phiVal, 2).toDouble() - variance);
    } else {
      double k = 1.0;
      // ensure we dont infinite loop; tauVal is small so multiply
      while (f(a - k * math.sqrt(math.pow(tauVal, 2).toDouble())) < 0) {
        k += 1.0;
        // a hard safety cap (should not hit in normal operation)
        if (k > 1e6) break;
      }
      b = a - k * math.sqrt(math.pow(tauVal, 2).toDouble());
    }
    double fA = f(a);
    double fB = f(b);
    // iterative update (regula-falsi-like)
    while ((b - a).abs() > eps) {
      final c = a + (a - b) * fA / (fB - fA);
      final fC = f(c);
      if (fC * fB < 0) {
        a = b;
        fA = fB;
      } else {
        fA = fA / 2.0;
      }
      b = c;
      fB = fC;
    }
    return math.exp(a / 2.0);
  }

  /// Core update logic - handles both batch and single matches
  /// `results` is a list of MatchResult containing the score for the
  /// player and the opponent's Rating (in display scale).
  Rating _updateRating({required Rating rating, List<MatchResult>? results}) {
    // Work on scaled down values
    Rating r = this.scaleDown(rating: rating);
    if (results == null || results.isEmpty) {
      // No matches: increase uncertainty
      final phiStar = math.sqrt(
        math.pow(r.phi, 2).toDouble() + math.pow(r.sigma, 2).toDouble(),
      );
      return this.scaleUp(
        rating: this.createRating(mu: r.mu, phi: phiStar, sigma: r.sigma),
      );
    }
    double varianceInv = 0;
    double diffSum = 0;
    for (final MatchResult res in results) {
      final oppScaled = this.scaleDown(rating: res.opponent);
      final double g = reduceImpact(rating: oppScaled);
      final double E = expectedScore(
        rating: r,
        otherPlayerRating: oppScaled,
        impact: g,
      );
      varianceInv += math.pow(g, 2).toDouble() * E * (1 - E);
      diffSum += g * (res.score - E);
    }
    // Avoid division by zero (if varianceInv is zero, there is nothing to update)
    if (varianceInv == 0) {
      return scaleUp(
        rating: this.createRating(mu: r.mu, phi: r.phi, sigma: r.sigma),
      );
    }
    double variance = 1 / varianceInv;
    double diff = diffSum / varianceInv;
    final sigmaPrime = this.determineSigma(
      rating: r,
      diff: diff,
      variance: variance,
    );
    final phiStar = math.sqrt(
      math.pow(r.phi, 2).toDouble() + math.pow(sigmaPrime, 2).toDouble(),
    );
    final phiPrime =
        1.0 /
        math.sqrt((1.0 / math.pow(phiStar, 2).toDouble()) + (1.0 / variance));
    final muPrime = r.mu + math.pow(phiPrime, 2).toDouble() * diff / variance;
    return this.scaleUp(
      rating: this.createRating(mu: muPrime, phi: phiPrime, sigma: sigmaPrime),
    );
  }

  /** API USE **/
  (Rating, Rating) rate1v1({
    required Rating playerA,
    required Rating playerB,
    bool drawn = false,
  }) {
    final double resultA = drawn ? draw : win;
    final double resultB = drawn ? draw : loss;
    final updatedA = _updateRating(
      rating: playerA,
      results: [MatchResult(score: resultA, opponent: playerB)],
    );
    final updatedB = _updateRating(
      rating: playerB,
      results: [MatchResult(score: resultB, opponent: playerA)],
    );
    return (updatedA, updatedB);
  }

  /// Batch update for multiple matches [(score, opponent), ...]
  Rating rateBatch({
    required Rating rating,
    required List<MatchResult> matches,
  }) {
    return this._updateRating(rating: rating, results: matches);
  }
}
