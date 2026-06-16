<div align="center">

# 

&nbsp;

&nbsp;

# 📚 DEVAMSIZLIK TAKİP UYGULAMASI

### Mobil Programlama Proje Raporu

&nbsp;

---

&nbsp;

<table>
<tr><td><b>Öğrenci Adı Soyadı</b></td><td>: ___________________________</td></tr>
<tr><td><b>Öğrenci Numarası</b></td><td>: ___________________________</td></tr>
<tr><td><b>Bölüm</b></td><td>: ___________________________</td></tr>
<tr><td><b>Sınıf / Şube</b></td><td>: ___________________________</td></tr>
<tr><td><b>Ders Adı</b></td><td>: ___________________________</td></tr>
<tr><td><b>Danışman / Öğretim Üyesi</b></td><td>: ___________________________</td></tr>
<tr><td><b>Üniversite / Fakülte</b></td><td>: ___________________________</td></tr>
<tr><td><b>Teslim Tarihi</b></td><td>: ___________________________</td></tr>
</table>

&nbsp;

---

&nbsp;

**Akademik Dönem:** ___________________________

&nbsp;

</div>

<div style="page-break-after: always;"></div>

---

## İÇİNDEKİLER

1. [Proje Özeti](#1-proje-özeti)
2. [Amaç ve Kapsam](#2-amaç-ve-kapsam)
3. [Kullanılan Teknolojiler](#3-kullanılan-teknolojiler)
4. [Proje Mimarisi ve Dosya Yapısı](#4-proje-mimarisi-ve-dosya-yapısı)
5. [Veri Modelleri](#5-veri-modelleri)
6. [Uygulama İşlevleri (Ekran Ekran)](#6-uygulama-i̇şlevleri-ekran-ekran)
7. [Arka Plan Servisleri](#7-arka-plan-servisleri)
8. [Veri Saklama Mantığı](#8-veri-saklama-mantığı)
9. [Tasarım ve Kullanıcı Deneyimi](#9-tasarım-ve-kullanıcı-deneyimi)
10. [İşlev Özet Tablosu](#10-i̇şlev-özet-tablosu)
11. [Sonuç](#11-sonuç)

<div style="page-break-after: always;"></div>

---

## 1. PROJE ÖZETI

**Devamsızlık Takip**, üniversite ve lise öğrencilerinin derslerine olan devamsızlık haklarını takip etmelerini, ders programlarını yönetmelerini ve sınavlarını planlamalarını sağlayan bir mobil uygulamadır. Flutter çatısı (framework) kullanılarak geliştirilmiş olup, Android ve iOS platformlarında çalışacak şekilde tasarlanmıştır.

Uygulama tamamen **çevrimdışı (offline)** çalışır; tüm veriler cihaz üzerinde yerel olarak saklanır, herhangi bir sunucuya veya internete ihtiyaç duymaz. Bu sayede kullanıcı verisi gizli kalır ve uygulama internet bağlantısı olmadan da sorunsuz işler.

Temel mantık şudur: Her dersin belirli bir **devamsızlık hakkı** vardır (örneğin 4 hak). Öğrenci her gün derse "Geldim" veya "Gelmedim" işareti koyar. "Gelmedim" işaretlendiğinde dersin kalan hakkı bir azalır. Hak kritik seviyeye düştüğünde (2 ve altı) uygulama kullanıcıyı görsel olarak (kırmızı renk) uyarır.

---

## 2. AMAÇ VE KAPSAM

### 2.1. Projenin Amacı
Öğrencilerin devamsızlık nedeniyle derslerden kalma riskini önlemek, ders ve sınav takibini tek bir merkezi uygulamada toplamaktır. Defter ya da akıldan takip yerine, otomatik hesaplama ve hatırlatma sistemi sunar.

### 2.2. Kapsam
- Çoklu ders ekleme, düzenleme ve silme
- Günlük yoklama (devamsızlık) işaretleme ve hak hesabı
- Aylık takvim üzerinde ders ve sınav görünümü
- Sınav planlama, not ve "yanına al" listesi
- Akademik dönem (Güz / Bahar) yönetimi
- Resmi tatil bilgisi
- Otomatik bildirim/hatırlatma sistemi
- Öğrenci profili ve fotoğraf
- Karanlık / Aydınlık tema desteği

---

## 3. KULLANILAN TEKNOLOJILER

| Teknoloji / Paket | Sürüm | Kullanım Amacı |
|---|---|---|
| **Flutter / Dart** | SDK ^3.11.0 | Ana geliştirme çatısı ve programlama dili |
| **shared_preferences** | ^2.5.5 | Verilerin cihazda kalıcı saklanması (key-value) |
| **flutter_local_notifications** | ^21.0.0 | Yerel bildirim / hatırlatma gönderimi |
| **timezone** | ^0.11.0 | Bildirimlerin Türkiye saatine (Europe/Istanbul) sabitlenmesi |
| **table_calendar** | ^3.1.2 | Aylık takvim arayüzü |
| **flutter_slidable** | ^3.1.1 | Kartların sola kaydırılarak aksiyon menüsü açılması |
| **image_picker** | ^1.2.2 | Galeriden profil fotoğrafı seçimi |
| **intl** | ^0.20.2 | Türkçe tarih biçimlendirme (ay/gün adları) |
| **flutter_localizations** | SDK | Türkçe dil/yerelleştirme desteği |
| **flutter_launcher_icons** | ^0.13.1 | Uygulama simgesi üretimi |
| **Inter (font)** | — | Özel yazı tipi ailesi (400–700 ağırlık) |

---

## 4. PROJE MIMARISI VE DOSYA YAPISI

Proje, sorumlulukların ayrıldığı **katmanlı (feature-based)** bir mimari kullanır:

```
lib/
├── main.dart                         → Uygulama giriş noktası, başlatma
│
├── core/                             → Çekirdek (paylaşılan) katman
│   ├── models/                       → Veri modelleri
│   │   ├── course_model.dart         → Ders modeli
│   │   ├── exam_model.dart           → Sınav modeli
│   │   ├── profile_model.dart        → Öğrenci profili modeli
│   │   └── term.dart                 → Akademik dönem modeli
│   │
│   ├── services/                     → İş mantığı servisleri
│   │   ├── storage_service.dart      → Yerel veri saklama
│   │   ├── notification_service.dart → Bildirim yönetimi
│   │   └── holiday_service.dart      → Resmi tatil bilgisi
│   │
│   └── theme/
│       └── app_theme.dart            → Renkler, temalar, ortak bileşenler
│
└── features/                         → Ekran (özellik) katmanı
    ├── splash_screen.dart            → Açılış ekranı
    ├── home_screen.dart              → Ana ekran (merkez)
    ├── schedule/
    │   └── add_course_screen.dart    → Ders ekleme/düzenleme
    ├── calendar/
    │   └── calendar_screen.dart      → Ders takvimi
    ├── exams/
    │   ├── exam_calendar_screen.dart → Sınav takvimi
    │   └── exam_add_screen.dart      → Sınav ekleme
    ├── profile/
    │   └── profile_screen.dart       → Profil ekranı
    └── settings/
        └── settings_screen.dart      → Ayarlar ekranı
```

**Mimari Avantajı:** `core` katmanı veriyi ve mantığı tutar; `features` katmanı yalnızca arayüzü içerir. Bu ayrım kodun bakımını ve genişletilmesini kolaylaştırır.

---

## 5. VERI MODELLERI

Uygulamada dört temel veri modeli bulunur. Her model JSON'a dönüştürülebilir (`toJson`) ve JSON'dan okunabilir (`fromJson`); bu, cihazda saklanmalarını sağlar.

### 5.1. Course (Ders) Modeli
Bir dersi temsil eder.

| Alan | Tip | Açıklama |
|---|---|---|
| `id` | String | Benzersiz kimlik (zaman damgası) |
| `name` | String | Ders adı |
| `time` | String | Ders saati "HH:mm" (boş olabilir) |
| `rightsLeft` | int | Kalan devamsızlık hakkı |
| `days` | List\<String> | Dersin olduğu günler |
| `notificationMuted` | bool | Bu ders için bildirim susturuldu mu |
| `term` | String | Ait olduğu dönem kimliği |
| `marks` | Map | Günlük yoklama işaretleri ("yyyy-MM-dd" → durum) |
| `courseColor` | String | Takvimdeki renk (hex) |

**Önemli Metotlar:**
- `markFor(date)`: Belirli güne ait işareti döndürür ("geldim"/"gelmedim"/"iptal").
- `clearPreviousDayMarks()`: Bugün dışındaki günlerin işaretlerini temizler (günlük sıfırlama).
- `sortMinutes`: Saate göre sıralama için saati dakikaya çevirir.
- `copyWith(...)`: Dersin düzenlenmiş bir kopyasını üretir.
- 8 renkli sabit palet ile her derse renk atanır.

### 5.2. Exam (Sınav) Modeli

| Alan | Tip | Açıklama |
|---|---|---|
| `id` | String | Benzersiz kimlik |
| `courseId` / `courseName` | String | Bağlı ders bilgisi |
| `date` | DateTime | Sınav tarihi |
| `time` | String | Sınav saati |
| `notes` | String | Sınav notları (konular vb.) |
| `bringList` | String | Yanına alınacaklar listesi (kalem, hesap makinesi) |
| `term` | String | Ait olduğu dönem |

### 5.3. Profile (Profil) Modeli

| Alan | Tip | Açıklama |
|---|---|---|
| `name` | String | Ad Soyad |
| `major` | String | Bölüm |
| `year` | int | Sınıf (1–7) |
| `photoPath` | String? | Profil fotoğrafı dosya yolu |

### 5.4. Term (Dönem) Modeli
Akademik dönemi temsil eder: **yıl + sezon (Güz/Bahar) + başlangıç/bitiş tarihi**.

**Önemli Metotlar:**
- `label`: Kullanıcıya gösterilen etiket ("2024 Güz").
- `contains(date)`: Verilen günün dönem aralığında olup olmadığını kontrol eder.
- `Term.current()`: Bugünün tarihinden otomatik dönem türetir (Eylül–Ocak = Güz, diğer = Bahar).

---

## 6. UYGULAMA İŞLEVLERI (EKRAN EKRAN)

### 6.1. Açılış Ekranı (Splash Screen)
- Uygulama açılışında gösterilir.
- "DEVAMSIZLIK TAKİP" yazısında **harf harf parlayan ışık efekti** (soldan sağa süzülen parlaklık).
- Altta ince çizgi şeklinde yükleme göstergesi.
- **3.5 saniye** sonra ana ekrana yumuşak (solma + büyüme) geçiş yapar.

### 6.2. Ana Ekran (Home Screen) — Uygulamanın Merkezi
Uygulamanın kalbidir. Üç sekmeli bir yapı sunar ve diğer tüm ekranlara buradan ulaşılır.

#### a) Karşılama Ekranı (Hiç ders yokken)
- Uygulama logosu (gradyan kırmızı, okul ikonu).
- "Devamsızlık Takip" başlığı ve kısa açıklama.
- Üç özellik tanıtımı: **Devamsızlık Takibi, Ders Takvimi, Sınav Planlama**.
- Nabız gibi atan (+) **Ders Ekle** butonu.
- Arka planda yavaşça süzülen bordo ışık efekti (`_AuroraBackgroundPainter`).

#### b) Üst Bar
- Sol: Profil avatarı (dokununca profil ekranı açılır).
- Bölüm ve sınıf bilgisi gösterimi.
- Sağ: **Ayarlar** ve **Ekle (+)** butonları.
- **Bağlama duyarlı ekle:** Sınavlar sekmesindeyken (+) sınav ekler, diğer sekmelerde ders ekler.

#### c) Üç Sekme (PageView)
**1. ANA Sekmesi:**
- "BUGÜN" başlığı altında o günün dersleri (saate göre sıralı).
- Her ders kartında **GELDİM** (yeşil) / **GELMEDİM** (kırmızı) butonları.
- İşaretleme sonrası "BUGÜN: GELDİM/GELMEDİM" rozeti ve **GERİ AL** seçeneği.
- "TÜM DERSLER" başlığı altında dönemdeki tüm dersler kompakt kartlarda.
- Her kartta **kalan hak rozeti** (3+ hak nötr, 2 ve altı kırmızı).
- Kart **sola kaydırılınca**: Sustur / Düzenle / Sil aksiyonları.

**2. DERSLER Sekmesi:** → Ders Takvimi (bkz. 6.4)

**3. SINAVLAR Sekmesi:** → Sınav Takvimi (bkz. 6.5)

#### Ana Ekran İşlevleri:
| İşlev | Açıklama |
|---|---|
| Günlük yoklama | "Geldim"/"Gelmedim" işaretleme; gün başına tek işaret |
| Hak hesabı | "Gelmedim" işaretinde hak otomatik 1 azalır |
| Geri alma | Yanlış işareti geri alır, hakkı iade eder |
| Bildirim susturma | Belirli dersin bildirimlerini kapatır |
| Ders silme | Dersi listeden ve takvimden kaldırır |
| Sekme geçişi | Kaydırma veya sekme etiketine dokunma |

### 6.3. Ders Ekleme / Düzenleme Ekranı
- **Ders adı** girişi (maks. 40 karakter).
- **Ders saati** seçimi (isteğe bağlı; dakika en yakın 5'e yuvarlanır).
- **Gün seçimi** (birden fazla gün seçilebilir, çoklu seçim).
- **Devamsızlık hakkı** ayarı (+/- sayaç).
- Bölümler aşağıdan yukarı **kademeli animasyonla** belirir.

**Kayıt Sırasında Kontroller (Doğrulama):**
- Boş ders adı engellenir.
- En az bir gün seçilmesi zorunludur.
- **Aynı isimli ders engeli** (Türkçe karaktere duyarlı: İ→i, I→ı).
- **Günlük ders limiti:** Bir güne en fazla 6 ders.

### 6.4. Ders Takvimi Ekranı
- Aylık **takvim görünümü** (table_calendar).
- Her günün altında **dersleri renkli noktalarla** gösterir (3'erli iki sıra, maks. 6 nokta).
- **Bugün** kırmızı çemberle, **seçili gün** açık kırmızı tonla vurgulanır.
- **Resmi tatiller** mavi "T" harfiyle işaretlenir.
- Bir güne dokununca o günün ders listesi ve kalan hakları altta görünür.
- Performans için renk haritası önbelleğe alınır (`_rebuildCaches`).
- Dönem dışı günlerde ve tatillerde ders gösterilmez.

### 6.5. Sınav Takvimi Ekranı
İki sekmeli yapı:

**a) TAKVİM Sekmesi:**
- Aylık takvimde sınav günleri kırmızı noktalarla işaretlenir.
- Güne dokununca o günün sınavları listelenir (saat, yanına al, not detaylarıyla).
- Sınav silme imkanı.

**b) DERS NOTLARI Sekmesi:**
- Sınavlar ders bazında gruplanır.
- Her ders için sınav sayısı ve tarih/saat/not/yanına-al bilgileri.

### 6.6. Sınav Ekleme Ekranı
- Dönemdeki dersler üst şeritte **sürüklenebilir** (Draggable) olarak listelenir.
- Ders **takvimde bir güne sürüklenip bırakılır** (drag & drop).
- Açılan alt panelde: **sınav saati**, **yanına al listesi**, **notlar** girilir.
- **Aynı derse aynı güne çift sınav engeli** kontrolü.
- Kayıt sonrası bilgi mesajı (SnackBar).

### 6.7. Profil Ekranı
- **Galeriden profil fotoğrafı** seçimi (image_picker).
- Ad Soyad (maks. 40), Bölüm (maks. 30) girişi.
- **Sınıf** ayarı (1–7 arası, +/- sayaç).
- Girilen bilgilerin **canlı önizlemesi** (avatar + isim + dönem rozeti).
- Aktif dönem etiketi gösterimi.

### 6.8. Ayarlar Ekranı
| Ayar | Açıklama |
|---|---|
| **Aktif Dönem** | Yıl + sezon (Güz/Bahar) + başlangıç/bitiş tarihi seçimi |
| **Günlük Özet Bildirimi** | 00:00 ve 18:00 hatırlatıcılarını açar/kapatır |
| **Karanlık Tema** | Aydınlık/Karanlık tema geçişi |

---

## 7. ARKA PLAN SERVISLERI

### 7.1. NotificationService (Bildirim Servisi)
Yerel bildirimleri yönetir. Türkiye saatine (Europe/Istanbul) sabitlenmiştir.

**İki tür otomatik bildirim üretir (7 gün ileriye planlanır):**
- **Gece 00:00 — "Yarının Dersleri":** Ertesi günün ders sayısını ve kritik hak uyarısını bildirir. Ders yoksa "Yarın Tatil" mesajı.
- **Akşam 18:00 — "Günü Tamamla":** O gün işaretlenmemiş dersleri hatırlatır.

**Özellikler:**
- Susturulmuş dersler dahil edilmez.
- Yalnızca aktif döneme ait dersler hesaba katılır.
- Resmi tatil günleri "ders yok" sayılır.
- İzin yönetimi (Android/iOS bildirim izinleri).

### 7.2. HolidayService (Tatil Servisi)
Türkiye resmi tatillerini sağlar.
- **Sabit milli bayramlar** koddan hesaplanır (Yılbaşı, 23 Nisan, 1 Mayıs, 19 Mayıs, 15 Temmuz, 30 Ağustos, 29 Ekim).
- **Dini bayramlar** (Ramazan, Kurban) ay takvimine göre kaydığından **2025–2027** için elle tanımlanmıştır.
- `isHoliday(date)` ve `nameFor(date)` metotlarıyla sorgulanır.

### 7.3. StorageService (Saklama Servisi)
Tüm yerel veri erişimini tek noktada toplar (bkz. Bölüm 8).

---

## 8. VERI SAKLAMA MANTIĞI

Veriler **shared_preferences** ile cihazda JSON formatında saklanır. `StorageService` beş ayrı anahtar yönetir:

| Anahtar | İçerik |
|---|---|
| `saved_courses` | Tüm dersler (JSON listesi) |
| `saved_exams` | Tüm sınavlar |
| `profile` | Öğrenci profili |
| `active_term` | Aktif dönem |
| `morning_reminder` | Bildirim açık/kapalı |

**Geriye Dönük Uyumluluk (Migration):**
- Eski "Belirtilmedi" saat değerleri boşa çevrilir.
- Dönemi olmayan eski dersler aktif döneme taşınır (tek seferlik göç).
- Eski düz metin dönem kimlikleri yeni JSON formatına çözülür.

---

## 9. TASARIM VE KULLANICI DENEYIMI

### 9.1. Renk Paleti
- **Vurgu Kırmızısı** `#D62828`: CTA butonları, aktif durumlar, kritik göstergeler.
- **Başarı Yeşili** `#34C759`: "Geldim" ve olumlu durumlar.
- **Sınav İndigo** `#5B5BD6`: Sınav ekranını ders takviminden ayırmak için.
- Katmanlı koyu yüzeyler (siyaha dönük, nötr tonlar).

### 9.2. Tema Desteği
- **Karanlık** ve **Aydınlık** tema; tercih kalıcı saklanır.
- `ValueNotifier` ile anlık tema değişimi (tüm uygulamaya yayılır).

### 9.3. Animasyonlar
- Açılış ekranında harf parlama efekti.
- Ekranlar arası iOS tarzı kaydırmalı geçişler.
- Ders ekleme ekranında kademeli giriş animasyonu.
- Karşılama ekranında akan bordo ışık (CustomPainter).
- Nabız atan ekle butonu.

### 9.4. Performans Optimizasyonları
- `AutomaticKeepAliveClientMixin`: Sekme geçişlerinde takvim durumunu korur.
- `RepaintBoundary`: Gereksiz yeniden çizimi engeller.
- Takvim renk haritası önbelleğe alınır.
- `InkRipple` dalga efekti (bazı cihazlardaki takılma sorunu için).

---

## 10. İŞLEV ÖZET TABLOSU

| # | İşlev | İlgili Ekran | Durum |
|---|---|---|---|
| 1 | Ders ekleme | Ders Ekleme | ✅ |
| 2 | Ders düzenleme | Ders Ekleme | ✅ |
| 3 | Ders silme | Ana Ekran | ✅ |
| 4 | Günlük yoklama (Geldim/Gelmedim) | Ana Ekran | ✅ |
| 5 | Devamsızlık hakkı otomatik hesabı | Ana Ekran | ✅ |
| 6 | Yoklamayı geri alma | Ana Ekran | ✅ |
| 7 | Ders bildirimi susturma | Ana Ekran | ✅ |
| 8 | Aynı isim / günlük limit kontrolü | Ders Ekleme | ✅ |
| 9 | Ders takvimi (renkli noktalar) | Ders Takvimi | ✅ |
| 10 | Resmi tatil gösterimi | Ders Takvimi | ✅ |
| 11 | Sınav ekleme (sürükle-bırak) | Sınav Ekleme | ✅ |
| 12 | Sınav takvimi | Sınav Takvimi | ✅ |
| 13 | Ders bazlı sınav notları | Sınav Takvimi | ✅ |
| 14 | Sınav silme | Sınav Takvimi | ✅ |
| 15 | Profil + fotoğraf yönetimi | Profil | ✅ |
| 16 | Dönem (Güz/Bahar) yönetimi | Ayarlar | ✅ |
| 17 | Otomatik bildirim (00:00 / 18:00) | Ayarlar / Servis | ✅ |
| 18 | Karanlık/Aydınlık tema | Ayarlar | ✅ |
| 19 | Çevrimdışı veri saklama | Tüm uygulama | ✅ |

---

## 11. SONUÇ

**Devamsızlık Takip** uygulaması, öğrencilerin akademik takiplerini kolaylaştıran, çevrimdışı çalışan, tam işlevsel bir mobil uygulamadır. Katmanlı mimarisi sayesinde bakımı kolay; sürükle-bırak, otomatik hak hesabı ve akıllı bildirim sistemi gibi özellikleriyle kullanıcı dostudur.

Uygulama Flutter'ın sunduğu zengin widget ekosistemini, yerel veri saklamayı, bildirim sistemini ve özel animasyonları bir araya getirerek bütünleşik bir öğrenci asistanı oluşturmuştur. Modüler yapısı, ileride yeni özellikler (örneğin not ortalaması hesabı, ders programı dışa aktarma) eklemeye açıktır.

&nbsp;

---

<div align="center">

*Bu rapor proje kodunun ayrıntılı analizi sonucu hazırlanmıştır.*

**— RAPOR SONU —**

</div>
