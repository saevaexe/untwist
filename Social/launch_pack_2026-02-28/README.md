# Untwist Launch Pack (2026-02-28)

Bu klasör Instagram ve X hesaplarını ilk aşamada doldurmak için hazırlanmış görsel + metin paketidir.

Not (2026-03-03): `generate_assets.py` ekran görüntüsü kaynakları güncellendi.
Script tekrar çalıştırıldığında aynı konsept görseller yeni screenshot'larla yeniden üretilir.

## Üretim

```bash
cd /Users/osmanseven/Untwist/Social/launch_pack_2026-02-28
python3 generate_assets.py
```

## Çıktılar

- Instagram feed görselleri: `images/instagram/` (9 adet, `1080x1350`)
- X post görselleri: `images/x/` (6 adet, `1600x900`)
- X kapak görseli: `images/x/x_header_1500x500.png`
- Profil görselleri: `images/profile/`
- Hazır paylaşım metinleri: `captions_tr.md`
- Hazır bio metinleri: `bios_tr.md`

## Önerilen kullanım sırası

1. Önce profil görsellerini ve X kapağı güncelle.
2. IG'de 9 postu art arda yükleyip profili dolu hale getir.
3. X'te `x_01_untwist_nedir.png` ile pinned post yayınla.
4. Sonraki 5 görseli günde 1 tane olacak şekilde paylaş.
