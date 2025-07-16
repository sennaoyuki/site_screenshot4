# Design Document

## Overview

現在の医療脱毛クリニック比較サイトは、iframe構造で複数のコンポーネントを組み合わせて構成されています。基本的な機能は動作していますが、デザイン面で以下の課題があります：

- 統一感のないカラーパレットとタイポグラフィ
- レスポンシブデザインの不完全な実装
- 視覚的階層の不明確さ
- CSSエラーとコードの最適化不足
- ユーザビリティの改善余地

本設計では、既存のiframe構造を維持しながら、モダンで統一感のあるデザインシステムを構築し、ユーザーエクスペリエンスを大幅に向上させます。

## Architecture

### Design System Structure

```
Design System
├── Color Palette (統一カラーパレット)
├── Typography System (タイポグラフィシステム)
├── Component Library (コンポーネントライブラリ)
├── Layout System (レイアウトシステム)
└── Animation & Interaction (アニメーション・インタラクション)
```

### Component Hierarchy

1. **Header Component** (`01_header.html`)
   - サイトブランディング
   - ナビゲーション要素

2. **Main Visual Component** (`02_mainvisual.html`)
   - ヒーローセクション
   - 主要メッセージ

3. **Search Form Component** (`03_searchform.html`)
   - ユーザー入力フォーム
   - CTA要素

4. **Ranking Results Component** (`04_rankingresults.html`)
   - メインコンテンツ
   - クリニック情報カード

5. **Comparison Table Component** (`06_comparisontable.html`)
   - 比較データ表示
   - タブナビゲーション

6. **Footer Component** (`09_footer_debug.html`)
   - サイト情報
   - ナビゲーションリンク

## Components and Interfaces

### 1. Design Token System

#### Color Palette
```css
:root {
  /* Primary Colors */
  --primary-red: #e74c3c;
  --primary-red-dark: #c0392b;
  --primary-red-light: #ec7063;
  
  /* Secondary Colors */
  --secondary-gold: #f1c40f;
  --secondary-gold-dark: #d4ac0d;
  
  /* Neutral Colors */
  --neutral-white: #ffffff;
  --neutral-light: #f8f9fa;
  --neutral-medium: #e9ecef;
  --neutral-dark: #2c3e50;
  --neutral-text: #333333;
  --neutral-text-light: #666666;
  
  /* Status Colors */
  --success-green: #27ae60;
  --warning-orange: #f39c12;
  --info-blue: #3498db;
}
```

#### Typography System
```css
:root {
  /* Font Families */
  --font-primary: 'Hiragino Sans', 'Noto Sans JP', sans-serif;
  --font-secondary: 'Yu Gothic', 'YuGothic', sans-serif;
  
  /* Font Sizes */
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  
  /* Line Heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;
}
```

#### Spacing System
```css
:root {
  /* Spacing Scale */
  --space-1: 0.25rem;   /* 4px */
  --space-2: 0.5rem;    /* 8px */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-5: 1.25rem;   /* 20px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-10: 2.5rem;   /* 40px */
  --space-12: 3rem;     /* 48px */
}
```

### 2. Component Design Specifications

#### Header Component
- **Purpose**: ブランディングとナビゲーション
- **Key Elements**: ロゴ、サイトタイトル、ナビゲーションテキスト
- **Design Improvements**:
  - より目立つロゴデザイン
  - 改善されたタイポグラフィ階層
  - レスポンシブレイアウトの最適化

#### Main Visual Component
- **Purpose**: ユーザーの注意を引くヒーローセクション
- **Key Elements**: メインメッセージ、視覚的要素、地域情報
- **Design Improvements**:
  - より魅力的なビジュアルデザイン
  - 改善されたCTAの配置
  - モバイルファーストのレスポンシブデザイン

#### Search Form Component
- **Purpose**: ユーザーの検索・絞り込み機能
- **Key Elements**: フォーム要素、検索ボタン
- **Design Improvements**:
  - より使いやすいフォームデザイン
  - 改善されたボタンスタイル
  - アクセシビリティの向上

#### Ranking Results Component
- **Purpose**: メインコンテンツの表示
- **Key Elements**: クリニックカード、ランキング表示、CTA
- **Design Improvements**:
  - カードデザインの統一と改善
  - 視覚的階層の明確化
  - 改善されたCTAボタン

#### Comparison Table Component
- **Purpose**: クリニック比較データの表示
- **Key Elements**: テーブル、タブナビゲーション
- **Design Improvements**:
  - レスポンシブテーブルデザイン
  - 改善されたタブインターフェース
  - データの視覚化向上

#### Footer Component
- **Purpose**: サイト情報とナビゲーション
- **Key Elements**: リンク、著作権情報
- **Design Improvements**:
  - 整理されたリンク構造
  - 改善されたレイアウト
  - デバッグ機能の最適化

### 3. Responsive Design Strategy

#### Breakpoint System
```css
/* Mobile First Approach */
:root {
  --breakpoint-sm: 576px;   /* Small devices */
  --breakpoint-md: 768px;   /* Medium devices */
  --breakpoint-lg: 992px;   /* Large devices */
  --breakpoint-xl: 1200px;  /* Extra large devices */
}
```

#### Layout Patterns
- **Mobile (< 768px)**: Single column, stacked layout
- **Tablet (768px - 992px)**: Two column layout where appropriate
- **Desktop (> 992px)**: Multi-column layout with optimized spacing

## Data Models

### Design Configuration Model
```javascript
const DesignConfig = {
  colors: {
    primary: '#e74c3c',
    primaryDark: '#c0392b',
    secondary: '#f1c40f',
    neutral: '#f8f9fa',
    text: '#333333'
  },
  typography: {
    fontFamily: "'Hiragino Sans', 'Noto Sans JP', sans-serif",
    baseFontSize: '16px',
    lineHeight: 1.5
  },
  spacing: {
    unit: '4px',
    scale: [4, 8, 12, 16, 20, 24, 32, 40, 48]
  },
  breakpoints: {
    sm: '576px',
    md: '768px',
    lg: '992px',
    xl: '1200px'
  }
};
```

### Component State Model
```javascript
const ComponentState = {
  header: {
    isFixed: false,
    showNavigation: true
  },
  searchForm: {
    isExpanded: false,
    activeFilters: []
  },
  rankingResults: {
    currentView: 'card',
    sortOrder: 'ranking'
  },
  comparisonTable: {
    activeTab: 0,
    visibleColumns: []
  }
};
```

## Error Handling

### CSS Error Resolution
1. **Syntax Errors**: 修正が必要なCSS構文エラー
   - 不完全なブロック（`}` の不足）
   - 無効なプロパティ値

2. **Property Warnings**: 警告の解決
   - `display: block` と `vertical-align` の競合
   - 非推奨プロパティの更新

3. **Performance Issues**: パフォーマンス最適化
   - 不要なCSSの削除
   - セレクターの最適化

### Responsive Design Error Handling
- **Viewport Issues**: メタタグの最適化
- **Layout Breaks**: フレックスボックス・グリッドの適切な実装
- **Image Scaling**: レスポンシブ画像の実装

## Testing Strategy

### Visual Testing
1. **Cross-browser Testing**
   - Chrome, Firefox, Safari, Edge での表示確認
   - モバイルブラウザでの動作確認

2. **Responsive Testing**
   - 各ブレークポイントでの表示確認
   - デバイス回転時の動作確認

3. **Accessibility Testing**
   - キーボードナビゲーション
   - スクリーンリーダー対応
   - カラーコントラスト確認

### Performance Testing
1. **Loading Speed**
   - CSS最適化による読み込み速度改善
   - 不要なリソースの削除

2. **Animation Performance**
   - スムーズなトランジション
   - 60fps のアニメーション維持

### Integration Testing
1. **iframe Communication**
   - コンポーネント間の通信確認
   - postMessage APIの動作確認

2. **JavaScript Functionality**
   - 既存機能の動作確認
   - 新しいインタラクションの実装

### User Experience Testing
1. **Usability Testing**
   - ナビゲーションの使いやすさ
   - フォームの入力しやすさ
   - CTAボタンの見つけやすさ

2. **Mobile Experience**
   - タッチインターフェースの最適化
   - スクロール動作の改善
   - 読みやすさの向上