import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static AdManager? _instance;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 5;

  AdManager._();

  static AdManager getInstance() {
    _instance ??= AdManager._();
    return _instance!;
  }
  initialize()async{
    await _createInterstitialAd();
  }

  dispose(){
    _interstitialAd?.dispose();
  }

  _createInterstitialAd() async{
    await InterstitialAd.load(
        adUnitId: 'ca-app-pub-4240235604287847/9522714373',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
              _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  showInterstitialAd() async{
    int c=0;
    while(_interstitialAd == null && c<6){
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
