# CSV更新システム

このシステムでは、CSVファイルを更新することで地域名やクリニックの順位などが動的に変更されます。

## ファイル構成

### CSVファイル（data/）
- `region_master.csv` - 地域マスターデータ
- `clinic_master.csv` - クリニックマスターデータ  
- `clinic_locations.csv` - クリニック詳細情報
- `regional_rankings.csv` - 地域別ランキング

### 生成されるJavaScriptファイル
- `clinic-database-generated.js` - CSVから自動生成されるクリニックデータベース
- `region-config-generated.js` - CSVから自動生成される地域設定

### システムファイル
- `update-data.sh` - CSV更新時の自動生成スクリプト
- `csv-data-loader.js` - CSVファイルを直接読み込む動的ローダー

## 使用方法

### 1. 静的生成方式

CSVを更新後、シェルスクリプトでJavaScriptファイルを生成：

```bash
# 一度だけ生成
./update-data.sh generate

# CSVファイルを監視して自動生成（要fswatch）
./update-data.sh watch
```

生成されたファイルをHTMLで読み込み：
```html
<script src="clinic-database-generated.js"></script>
<script src="region-config-generated.js"></script>
```

### 2. 動的読み込み方式

CSVファイルを直接ブラウザで読み込み：

```html
<script src="csv-data-loader.js"></script>
```

### 監視機能のセットアップ

ファイル変更の自動監視（macOS）：
```bash
brew install fswatch
./update-data.sh watch
```

## CSVデータ更新手順

### 1. 新しい地域を追加

`region_master.csv`に新しい行を追加：
```csv
region_id,region_name,area_text,station_info
008,福岡,福岡・北九州・久留米エリア対応,JR博多駅徒歩5分以内の好立地
```

### 2. 新しいクリニックを追加

`clinic_master.csv`にクリニック情報を追加：
```csv
clinic_id,clinic_name,clinic_type,official_url
7,○○クリニック,医療脱毛,https://example.com/
```

`clinic_locations.csv`に詳細情報を追加：
```csv
location_id,clinic_id,region_id,branch_name,postal_code,address,access,phone,rating,campaign,monthly_price,total_price,feature1,feature2,feature3
fukuoka_001,7,008,博多院,812-0011,福岡県福岡市博多区博多駅前...,JR博多駅徒歩3分,092-xxx-xxxx,4.5,キャンペーン内容,月々2000円,総額150000円,特徴1,特徴2,特徴3
```

### 3. 地域ランキングを更新

`regional_rankings.csv`でランキングを設定：
```csv
region_id,rank1_location,rank2_location,rank3_location
008,fukuoka_001,fukuoka_002,fukuoka_003
```

### 4. 更新を反映

```bash
# 静的生成の場合
./update-data.sh generate

# 動的読み込みの場合
# ブラウザでページをリロードするか、以下のJavaScriptを実行
dynamicRegionConfig.reloadData();
```

## デバッグ・確認方法

### 生成されたデータの確認
```javascript
// 静的生成版
console.log(CLINIC_DATABASE_GENERATED);
console.log(REGION_CONFIG_GENERATED);

// 動的読み込み版
console.log(csvDataLoader.cache);
console.log(dynamicRegionConfig.regions);
```

### データ再読み込み
```javascript
// 動的読み込み版のみ
await dynamicRegionConfig.reloadData();
```

## トラブルシューティング

### CSVファイルが読み込めない
- ファイルパスが正しいか確認
- CSVの文字エンコーディングがUTF-8か確認
- Webサーバーが起動しているか確認（CORS制限）

### 地域が表示されない
- `region_master.csv`にデータが正しく入力されているか確認
- `regional_rankings.csv`に対応するランキングがあるか確認

### スクリプトが実行できない
```bash
chmod +x update-data.sh
```

### fswatch監視が動かない
```bash
# macOSの場合
brew install fswatch

# Linuxの場合
sudo apt-get install inotify-tools
```