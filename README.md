# Tasbeeh Counter App — Setup Guide

Ye complete Flutter project hai. Neeche diye gaye steps follow karein taake
app apne computer par run kar sakein aur Play Store par publish kar sakein.

---

## STEP 1: Required Tools Install Karein (one-time)

1. **Flutter SDK** install karein: https://docs.flutter.dev/get-started/install
2. **Android Studio** install karein: https://developer.android.com/studio
3. Installation ke baad terminal mein ye command chalayen check karne ke liye:
   ```
   flutter doctor
   ```
   Agar koi ❌ (cross mark) aaye, uska fix Flutter doctor khud bata dega.

---

## STEP 2: Project Open Karna

1. Ye zip file extract karein.
2. Android Studio kholen → **Open** → extract ki hui `tasbeeh_counter` folder select karein.
3. Android Studio neeche "Pub get" / "Get dependencies" khud chalayega.
   Agar na chale, terminal mein project folder ke andar ye likhein:
   ```
   flutter pub get
   ```

---

## STEP 3: App Run Karna (Test Karne Ke Liye)

1. Android Studio mein, top par ek emulator/device select karein (ya phone USB se connect karein, USB debugging on karke).
2. Green "Run" button dabayen, ya terminal mein:
   ```
   flutter run
   ```
3. App test ads ke saath chalegi (real AdMob IDs abhi nahi lagayi gayi — yeh
   safety ke liye hai, taake aap accidentally apna account suspend na karen).

---

## STEP 4: Apna AdMob Account Banayein

1. https://admob.google.com par jayen, Google account se sign up karein.
2. **New App Add** karein → "Tasbeeh Counter" naam dein → Android select karein.
3. AdMob aap ko 3 cheezein dega, jo replace karni hain:
   - **App ID** (shakal: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)
   - **Banner Ad Unit ID**
   - **Interstitial Ad Unit ID**

### Kahan Replace Karna Hai:

**File: `android/app/src/main/AndroidManifest.xml`**
Is line mein apni App ID dalen:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YAHAN_APNI_APP_ID_DALEN"/>
```

**File: `lib/services/ad_helper.dart`**
Teen jagah test IDs ko apni real IDs se replace karein:
- `bannerAdUnitId`
- `interstitialAdUnitId`
- `rewardedAdUnitId` (agar rewarded ads use karni hain)

⚠️ **Bohat Zaroori:** Jab tak aap testing kar rahe hain, TEST IDs hi use karein
(jo already code mein hain). Real IDs sirf tab lagayen jab app publish karne
ke liye taiyar ho. Apne hi ads par repeatedly click karna AdMob policy
violation hai aur account permanently ban ho sakta hai.

---

## STEP 5: App Icon Aur Naam Change Karna

- App ka naam: `android/app/src/main/AndroidManifest.xml` mein `android:label` change karein.
- App icon: `flutter_launcher_icons` package use karein (Google kar lein "flutter app icon generator").

---

## STEP 6: Play Store Par Publish Karna

1. https://play.google.com/console par jayen, $25 one-time registration fee dein.
2. Release build banayen:
   ```
   flutter build appbundle
   ```
3. `.aab` file `build/app/outputs/bundle/release/` mein milegi.
4. Play Console mein naya app create karein, store listing (screenshots, description, privacy policy) fill karein, aur `.aab` upload karein.
5. AdMob account ko Play Console se link karein (Play Console > Monetization setup).

**Note:** Privacy Policy zaroori hai (kyunke ads use ho rahi hain). Free privacy
policy generator online mil jayega (e.g. "Google Play privacy policy generator").

---

## Project Ki Files Ka Tor-Phor (kya kahan hai)

```
lib/
  main.dart                    -> App entry point, theme setup
  screens/
    home_screen.dart           -> Main counter screen
    settings_screen.dart       -> Target, vibration, dark mode settings
  services/
    ad_helper.dart              -> AdMob ad IDs aur interstitial logic
    storage_service.dart        -> Counter data save/load (device storage)
  widgets/
    banner_ad_widget.dart       -> Reusable banner ad component

android/                        -> Android-specific build files
pubspec.yaml                    -> Dependencies list
```

---

## Agle Steps (Future Improvements Jo Aap Khud Ya Kisi Se Add Karwa Sakte Hain)

- Multiple Tasbeeh presets (list se select karna, sirf naam type karne ke ilawa)
- Daily/weekly stats graph
- Notification reminders (din mein kisi waqt zikr ki yaad dehani)
- Different counter themes/colors unlock karne ke liye rewarded ad
- Cloud backup (Firebase) taake naya phone lene par data na khoye

---

Koi error aaye Flutter run karte waqt, error ka exact message copy karke
mujhse puch sakte hain — main uska solution bata dunga.
