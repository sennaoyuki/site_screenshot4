# iframe内フッターリンク遷移問題 - Vercelデプロイ後テスト手順書

## 修正内容の概要
iframe内のフッターリンククリック時のナビゲーション問題を解決するため、以下の修正を実装しました：

### 実装した修正
1. **postMessage targetOrigin修正**: `window.location.origin` → `'*'`
2. **Vercel環境対応のオリジン検証**: 柔軟な条件を追加
3. **詳細デバッグログ**: 問題特定を容易にするログの追加

---

## 1. 基本動作テスト

### 1.1 フッターリンクの動作確認

**テスト対象リンク（09_footer.htmlの下部ナビゲーション）:**
- TOP (`index.html`)
- 制作概要 (`about.html`)
- 運営会社 (`company.html`)
- 編集方針 (`editorial-policy.html`)
- プライバシーポリシー (`privacy-policy.html`)

**テスト手順:**
1. Vercelデプロイ済みサイトにアクセス
2. ページを最下部までスクロールしてフッターを表示
3. 各リンクを順番にクリック
4. 期待される動作を確認

**期待される動作:**
- ✅ リンククリック時に対応するページに遷移する
- ✅ ページ遷移が即座に実行される（遅延なし）
- ✅ 遷移先ページが正常に表示される
- ✅ ブラウザのURL欄が正しく更新される

### 1.2 ホバー効果の確認

**テスト手順:**
1. フッターリンクにマウスカーソルを合わせる
2. リンクからカーソルを離す

**期待される動作:**
- ✅ ホバー時にリンクが2px右に移動する
- ✅ カーソルを離すと元の位置に戻る
- ✅ 色が変化する（#e74c3c → #c0392b）

---

## 2. デバッグ情報の確認方法

### 2.1 ブラウザ開発者ツールの開き方
- **Chrome/Edge**: F12 または Ctrl+Shift+I (Mac: Cmd+Option+I)
- **Firefox**: F12 または Ctrl+Shift+K (Mac: Cmd+Option+K)
- **Safari**: Option+Cmd+I (開発者メニューを有効にする必要があります)

### 2.2 Console出力で確認すべき内容

**正常時のログパターン:**
```
Footer component loaded
Navigation request: TOP URL: index.html
Navigation message sent to parent: {type: "navigate", url: "index.html", linkText: "TOP", timestamp: ...}
Parent window origin check...
Current iframe origin: https://your-site.vercel.app
Received message from iframe: {type: "navigate", url: "index.html", linkText: "TOP", timestamp: ...}
Origin validation: {myOrigin: "https://your-site.vercel.app", eventOrigin: "https://your-site.vercel.app", isAllowed: true}
Navigating to: index.html (from link: TOP)
```

**確認項目:**
- ✅ "Footer component loaded" が表示される
- ✅ "Navigation request" でリンク情報が表示される
- ✅ "Navigation message sent to parent" でpostMessage送信が確認される
- ✅ "Origin validation" で isAllowed: true が表示される
- ✅ "Navigating to: [URL]" でページ遷移が実行される

### 2.3 Networkタブでの確認事項

**確認手順:**
1. 開発者ツールの「Network」タブを開く
2. フッターリンクをクリック
3. リクエストの確認

**確認項目:**
- ✅ クリック後に新しいHTMLファイルのリクエストが発生する
- ✅ ステータスコード 200 で正常にファイルが取得される
- ✅ Response timeが適切（通常1秒以内）

---

## 3. 問題が残っている場合のトラブルシューティング

### 3.1 リンククリックが反応しない場合

**考えられる原因と対策:**
1. **postMessage送信エラー**
   - Console で "Failed to send navigation message" を確認
   - フォールバック関数が動作しているか確認

2. **オリジン検証の失敗**
   - Console で "信頼できないオリジンからのメッセージを拒否" を確認
   - Origin validation の詳細を確認

**対策:**
```javascript
// 緊急対策: 一時的にorigin検証を無効化（デバッグ用のみ）
const isAllowedOrigin = true; // この行を一時的に追加
```

### 3.2 Console にエラーメッセージが表示される場合

**よくあるエラーパターンと対処法:**

1. **"Blocked potentially unsafe URL"**
   - JavaScriptインジェクション対策が作動
   - URLが正常な形式か確認

2. **"Invalid message format"**
   - postMessageの形式が不正
   - メッセージオブジェクトの構造を確認

3. **"Cross-origin frame access denied"**
   - iframe間通信の権限エラー
   - same-origin policyの問題

### 3.3 次に実行すべき対策

**レベル1: 基本対策**
1. ブラウザキャッシュのクリア
2. ハードリロード（Ctrl+F5 / Cmd+Shift+R）
3. 別のブラウザでのテスト

**レベル2: 設定調整**
1. postMessage の targetOrigin を `window.location.origin` に戻す
2. オリジン検証条件を更に緩和
3. iframe の sandbox 属性の確認

**レベル3: 根本対策**
1. postMessage 実装の見直し
2. iframe 構造の変更検討
3. 代替ナビゲーション手法の実装

---

## 4. 成功判定基準

### 4.1 正常動作の明確な判定基準

**完全成功の条件（全て満たす必要あり）:**
- ✅ 全5つのフッターリンクがクリック可能
- ✅ クリック後1秒以内にページ遷移が完了
- ✅ Console にエラーメッセージが表示されない
- ✅ 遷移先ページが正常に表示される
- ✅ ブラウザの戻るボタンで元のページに戻れる

### 4.2 部分的成功の場合の評価方法

**レベルA（良好）:**
- 4-5個のリンクが正常動作
- Console に軽微な警告のみ表示

**レベルB（要改善）:**
- 2-3個のリンクが正常動作
- 一部のリンクで遅延が発生

**レベルC（要修正）:**
- 0-1個のリンクのみ動作
- Console に重大エラーが表示

---

## 5. 環境別テスト

### 5.1 デスクトップブラウザでのテスト

**推奨テスト環境:**
- Windows: Chrome 最新版、Edge 最新版
- Mac: Chrome 最新版、Safari 最新版
- Linux: Chrome 最新版、Firefox 最新版

**テスト項目:**
1. 基本動作（全リンククリック）
2. ホバー効果
3. キーボードナビゲーション（Tab + Enter）
4. ページサイズ変更（ウィンドウリサイズ）

### 5.2 モバイルブラウザでのテスト

**推奨テスト環境:**
- iOS: Safari、Chrome
- Android: Chrome、Samsung Internet

**モバイル固有のテスト項目:**
1. タッチ操作でのリンククリック
2. スクロール後のリンククリック
3. 画面回転後の動作確認
4. ピンチズーム後の動作確認

### 5.3 異なるブラウザでの確認

**ブラウザ別チェックポイント:**

**Chrome:**
- Console ログの詳細確認
- postMessage 送受信ログ
- パフォーマンスタブでの読み込み時間

**Safari:**
- iframe セキュリティ制限の確認
- WebKit固有のバグの確認
- プライベートブラウジングでのテスト

**Firefox:**
- Enhanced Tracking Protection の影響確認
- iframe sandbox の動作確認
- 開発者ツールでのネットワーク確認

**Edge:**
- IE互換性の確認
- Windows固有の問題の確認
- SmartScreen フィルターの影響確認

---

## 6. レポート作成テンプレート

### 6.1 テスト結果記録フォーマット

```
## テスト実施日時
yyyy/mm/dd hh:mm

## テスト環境
- OS: 
- ブラウザ: 
- サイトURL: 

## テスト結果
### フッターリンク動作テスト
- TOP: ✅/❌
- 制作概要: ✅/❌
- 運営会社: ✅/❌
- 編集方針: ✅/❌
- プライバシーポリシー: ✅/❌

### Console ログ確認
- エラーメッセージ: 
- 警告メッセージ: 
- 正常ログ確認: ✅/❌

### 総合評価
- 成功レベル: A/B/C
- 備考: 
```

### 6.2 問題発見時の報告フォーマット

```
## 問題報告
### 発生状況
- 発生タイミング: 
- 再現手順: 
- 発生頻度: 

### エラー詳細
- Console エラー: 
- ネットワークエラー: 
- 画面の状況: 

### 影響範囲
- 影響するリンク: 
- 影響するブラウザ: 
- 影響するデバイス: 

### 緊急度
- 高/中/低: 
- 理由: 
```

---

## 7. 追加確認事項

### 7.1 パフォーマンス確認
- ページ読み込み時間が3秒以内
- iframe の高さ調整が正常に動作
- レスポンシブデザインが適切に機能

### 7.2 アクセシビリティ確認
- キーボードのみでナビゲーション可能
- スクリーンリーダーでの読み上げ確認
- 色のコントラスト比が適切

### 7.3 SEO影響確認
- リンクのクロールが正常
- 内部リンク構造が維持されている
- canonical URL が正しく設定されている

---

この手順書に従ってテストを実施し、問題が発見された場合は詳細な情報とともにご報告ください。