import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Helper — sab ad IDs aur loading logic yahan centralized hai.
///
/// IMPORTANT: Neeche di gayi IDs TEST IDs hain (Google ki official test IDs).
/// Jab aap apni real AdMob account se app register karein, in IDs ko
/// apni asal Ad Unit IDs se replace karein, warna real ads nahi chalenge
/// aur production mein launch karne se pehle test IDs hata dena zaroori hai
/// (warna AdMob policy violation ho sakta hai).
class AdHelper {
  // ---------- BANNER AD UNIT ID ----------
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID - Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID - iOS Banner
    }
    throw UnsupportedError('Unsupported platform');
  }

  // ---------- INTERSTITIAL AD UNIT ID ----------
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID - Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID - iOS Interstitial
    }
    throw UnsupportedError('Unsupported platform');
  }

  // ---------- REWARDED AD UNIT ID ----------
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID - Android Rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID - iOS Rewarded
    }
    throw UnsupportedError('Unsupported platform');
  }
}

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  int _loadAttempts = 0;
  static const int maxLoadAttempts = 3;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _loadAttempts++;
          _interstitialAd = null;
          if (_loadAttempts < maxLoadAttempts) {
            loadAd();
          }
        },
      ),
    );
  }

  /// Target complete hone par ye call karein.
  /// Har baar ad show nahi karte — taake user experience kharab na ho.
  void showAdIfAvailable() {
    if (_interstitialAd == null) {
      loadAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAd(); // next time ke liye dobara load karo
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
