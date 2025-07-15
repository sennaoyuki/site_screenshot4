// 統一ランキング同期システム
// CSVデータベースに基づいて全ページのランキングを統一

class RankingSyncSystem {
    constructor() {
        this.currentRegionData = null;
        this.isInitialized = false;
        this.defaultRegionId = '012'; // 千葉をデフォルト
    }

    // 初期化
    async init() {
        console.log('🔧 統一ランキング同期システムを初期化中...');
        
        // 依存関係の確認
        await this.waitForDependencies();
        
        // 初期データの読み込み
        this.loadInitialData();
        
        this.isInitialized = true;
        console.log('✅ 統一ランキング同期システムが準備完了');
        
        // 地域変更イベントの監視
        this.setupEventListeners();
        
        // 初期更新の実行
        setTimeout(() => {
            this.updateAllPages();
        }, 500);
    }

    // 依存関係の待機
    async waitForDependencies() {
        return new Promise((resolve) => {
            const checkInterval = setInterval(() => {
                if (window.CLINIC_DATABASE_GENERATED && window.getClinicDataByRegionId) {
                    clearInterval(checkInterval);
                    resolve();
                }
            }, 100);
            
            // 5秒でタイムアウト
            setTimeout(() => {
                clearInterval(checkInterval);
                console.warn('⚠️ 依存関係の読み込みがタイムアウトしました');
                resolve();
            }, 5000);
        });
    }

    // 初期データの読み込み
    loadInitialData() {
        if (window.CLINIC_DATABASE_GENERATED && window.CLINIC_DATABASE_GENERATED[this.defaultRegionId]) {
            this.currentRegionData = window.CLINIC_DATABASE_GENERATED[this.defaultRegionId];
            console.log(`📊 初期データ読み込み完了: ${this.currentRegionData.name}`);
        } else {
            console.warn('⚠️ 初期データの読み込みに失敗しました');
        }
    }

    // イベントリスナーの設定
    setupEventListeners() {
        // 地域変更イベント
        window.addEventListener('regionChanged', (event) => {
            console.log('🔄 地域変更イベントを受信:', event.detail);
            this.handleRegionChange(event.detail);
        });

        // カスタムランキング更新イベント
        window.addEventListener('updateRankings', (event) => {
            console.log('🔄 ランキング更新イベントを受信');
            this.updateAllPages();
        });
    }

    // 地域変更の処理
    handleRegionChange(eventDetail) {
        const regionId = eventDetail.regionId || this.getRegionIdFromKey(eventDetail.region);
        
        if (regionId && window.CLINIC_DATABASE_GENERATED[regionId]) {
            this.currentRegionData = window.CLINIC_DATABASE_GENERATED[regionId];
            this.updateAllPages();
        }
    }

    // 地域キーからIDを取得
    getRegionIdFromKey(regionKey) {
        const keyMap = {
            'hokkaido': '001',
            'miyagi': '004',
            'chiba': '012',
            'tokyo': '013',
            'aichi': '023',
            'osaka': '027'
        };
        return keyMap[regionKey];
    }

    // 全ページの更新
    updateAllPages() {
        if (!this.currentRegionData) {
            console.warn('⚠️ 地域データが設定されていません');
            return;
        }

        console.log(`🔄 全ページを更新中: ${this.currentRegionData.name}`);

        // 各ページタイプごとに更新
        this.updateRankingResultsPage();
        this.updateComparisonTablePage();
        this.updateDetailedContentPage();
        
        console.log('✅ 全ページの更新が完了しました');
    }

    // 04_rankingresults.html の更新
    updateRankingResultsPage() {
        const rankingCards = document.querySelectorAll('.ranking-card');
        if (rankingCards.length === 0) return;

        console.log('📄 ランキング結果ページを更新中...');

        rankingCards.forEach((card, index) => {
            const clinic = this.currentRegionData.clinics[index];
            if (!clinic) return;

            // ランキングバッジの更新
            const badge = card.querySelector('.ranking-badge');
            if (badge) {
                const rankText = index === 0 ? '🏆 第1位 最もおすすめ' : `第${index + 1}位`;
                badge.textContent = rankText;
            }

            // クリニック名の更新
            const nameElement = card.querySelector('.clinic-name');
            if (nameElement) {
                const cleanName = clinic.name.replace(/ [^ ]*院$/, ''); // 院名の部分を削除
                nameElement.innerHTML = `${cleanName} <span data-region="name">${this.currentRegionData.name}</span>院（医療脱毛）`;
            }

            // 料金の更新
            const priceElements = card.querySelectorAll('.price-large');
            priceElements.forEach(element => {
                if (clinic.price) {
                    element.textContent = clinic.price.replace('月々', '');
                }
            });

            // キャンペーンの更新
            const campaignElements = card.querySelectorAll('.price-small');
            campaignElements.forEach(element => {
                if (clinic.campaign) {
                    element.textContent = clinic.campaign;
                }
            });
        });
    }

    // 06_comparisontable.html の更新
    updateComparisonTablePage() {
        const comparisonItems = document.querySelectorAll('.comparison-item, .clinic-row');
        if (comparisonItems.length === 0) return;

        console.log('📄 比較表ページを更新中...');

        comparisonItems.forEach((item, index) => {
            const clinic = this.currentRegionData.clinics[index];
            if (!clinic) return;

            // クリニック名の更新（複数箇所）
            const nameElements = item.querySelectorAll('.clinic-name');
            nameElements.forEach(nameElement => {
                const cleanName = clinic.name.split(' ')[0]; // 最初の単語のみ取得
                nameElement.textContent = cleanName;
            });

            // 料金の更新
            const priceElements = item.querySelectorAll('.price-value, .highlight-price');
            priceElements.forEach(priceElement => {
                if (clinic.price) {
                    priceElement.textContent = clinic.price;
                }
            });

            // 順位表示の更新
            const rankElements = item.querySelectorAll('.rank-number, .comparison-rank');
            rankElements.forEach(rankElement => {
                rankElement.textContent = `${index + 1}位`;
            });
        });
    }

    // 07_detailedcontent.html の更新
    updateDetailedContentPage() {
        const clinicSections = document.querySelectorAll('.clinic-section');
        if (clinicSections.length === 0) return;

        console.log('📄 詳細コンテンツページを更新中...');

        // 既存のセクション順序を現在のランキングに合わせて並び替え
        const container = document.querySelector('.detailed-container');
        if (!container) return;

        // 新しい順序でセクションを並び替え
        const sortedSections = [];
        
        this.currentRegionData.clinics.forEach((clinic, index) => {
            const cleanName = clinic.name.split(' ')[0];
            
            // 対応するセクションを見つける
            const matchingSection = Array.from(clinicSections).find(section => {
                const header = section.querySelector('.clinic-header h2');
                return header && header.textContent.includes(cleanName);
            });

            if (matchingSection) {
                // ヘッダーを更新
                const header = matchingSection.querySelector('.clinic-header h2');
                if (header) {
                    header.textContent = cleanName;
                }

                // 料金の更新
                const priceElements = matchingSection.querySelectorAll('.price-highlight');
                priceElements.forEach(element => {
                    if (clinic.price) {
                        element.textContent = clinic.price + 'から';
                    }
                });

                sortedSections.push(matchingSection);
            }
        });

        // DOM上での順序を変更
        sortedSections.forEach((section, index) => {
            container.appendChild(section);
        });
    }

    // 地域名の更新（全ページ共通）
    updateRegionNames() {
        const regionElements = document.querySelectorAll('[data-region="name"]');
        regionElements.forEach(element => {
            element.textContent = this.currentRegionData.name;
        });
    }

    // 現在のランキング情報を取得
    getCurrentRanking() {
        return this.currentRegionData;
    }

    // デバッグ用：現在のランキングをコンソールに表示
    logCurrentRanking() {
        if (!this.currentRegionData) {
            console.log('❌ ランキングデータが読み込まれていません');
            return;
        }

        console.log(`\n📊 === ${this.currentRegionData.name} 地域の統一ランキング ===`);
        this.currentRegionData.clinics.forEach((clinic, index) => {
            console.log(`${index + 1}位: ${clinic.name}`);
            console.log(`     💰 ${clinic.price} | 📢 ${clinic.campaign}`);
        });
        console.log('='.repeat(50));
    }

    // 特定地域のデータを手動で更新
    updateRegion(regionId) {
        if (window.CLINIC_DATABASE_GENERATED && window.CLINIC_DATABASE_GENERATED[regionId]) {
            this.currentRegionData = window.CLINIC_DATABASE_GENERATED[regionId];
            this.updateAllPages();
            console.log(`🔄 手動で地域を更新: ${this.currentRegionData.name}`);
        } else {
            console.warn(`⚠️ 地域ID ${regionId} のデータが見つかりません`);
        }
    }
}

// グローバルインスタンス
window.rankingSyncSystem = new RankingSyncSystem();

// ページ読み込み完了後に初期化
document.addEventListener('DOMContentLoaded', async () => {
    await window.rankingSyncSystem.init();
});

// デバッグ用グローバル関数
window.showRanking = () => {
    window.rankingSyncSystem.logCurrentRanking();
};

window.updateToRegion = (regionId) => {
    window.rankingSyncSystem.updateRegion(regionId);
};

window.forceUpdate = () => {
    window.rankingSyncSystem.updateAllPages();
};