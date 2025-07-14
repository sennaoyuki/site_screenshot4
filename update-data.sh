#!/bin/bash

# CSV データからJavaScriptファイルを自動生成するスクリプト

DATA_DIR="./data"
OUTPUT_DIR="./"
CLINIC_DB_FILE="${OUTPUT_DIR}clinic-database-generated.js"
REGION_CONFIG_FILE="${OUTPUT_DIR}region-config-generated.js"

echo "=== CSV更新スクリプト開始 ==="

# CSVファイルの存在確認
if [ ! -f "${DATA_DIR}/region_master.csv" ] || [ ! -f "${DATA_DIR}/clinic_locations.csv" ] || [ ! -f "${DATA_DIR}/clinic_master.csv" ] || [ ! -f "${DATA_DIR}/regional_rankings.csv" ]; then
    echo "エラー: 必要なCSVファイルが見つかりません"
    exit 1
fi

echo "CSVファイルを確認しました"

# clinic-database-generated.js を生成
generate_clinic_database() {
    echo "クリニックデータベースを生成中..."
    
    cat > "$CLINIC_DB_FILE" << 'EOF'
// 自動生成されたクリニックデータベース
// このファイルは update-data.sh により自動生成されます。直接編集しないでください。

const CLINIC_DATABASE_GENERATED = {
EOF

    # 地域マスターを読み取り、各地域のデータを生成
    tail -n +2 "${DATA_DIR}/region_master.csv" | while IFS=',' read -r region_id region_name area_text station_info; do
        # CSVの引用符を除去
        region_id=$(echo "$region_id" | sed 's/"//g')
        region_name=$(echo "$region_name" | sed 's/"//g')
        area_text=$(echo "$area_text" | sed 's/"//g')
        station_info=$(echo "$station_info" | sed 's/"//g')
        
        echo "    // ${region_name} - region_id: ${region_id}" >> "$CLINIC_DB_FILE"
        echo "    '${region_id}': {" >> "$CLINIC_DB_FILE"
        echo "        id: '${region_id}'," >> "$CLINIC_DB_FILE"
        echo "        name: '${region_name}'," >> "$CLINIC_DB_FILE"
        echo "        areaText: '${area_text}'," >> "$CLINIC_DB_FILE"
        echo "        stationInfo: '${station_info}'," >> "$CLINIC_DB_FILE"
        echo "        clinics: [" >> "$CLINIC_DB_FILE"
        
        # 地域別ランキングを読み取り
        ranking_line=$(grep "^${region_id}," "${DATA_DIR}/regional_rankings.csv")
        if [ -n "$ranking_line" ]; then
            rank1=$(echo "$ranking_line" | cut -d',' -f2)
            rank2=$(echo "$ranking_line" | cut -d',' -f3)
            rank3=$(echo "$ranking_line" | cut -d',' -f4)
            
            rank=1
            for location_id in "$rank1" "$rank2" "$rank3"; do
                # クリニック詳細情報を取得
                clinic_line=$(grep "^${location_id}," "${DATA_DIR}/clinic_locations.csv")
                if [ -n "$clinic_line" ]; then
                    IFS=',' read -r loc_id clinic_id region clinic_branch postal address access phone rating campaign monthly_price total_price feature1 feature2 feature3 <<< "$clinic_line"
                    
                    # クリニック名を取得
                    clinic_name_line=$(grep "^${clinic_id}," "${DATA_DIR}/clinic_master.csv")
                    clinic_name=$(echo "$clinic_name_line" | cut -d',' -f2 | sed 's/"//g')
                    clinic_url=$(echo "$clinic_name_line" | cut -d',' -f4 | sed 's/"//g')
                    
                    # JSオブジェクトを生成
                    echo "            {" >> "$CLINIC_DB_FILE"
                    echo "                rank: ${rank}," >> "$CLINIC_DB_FILE"
                    echo "                name: '${clinic_name} ${clinic_branch}'," >> "$CLINIC_DB_FILE"
                    echo "                rating: '★★★★★ (${rating})'," >> "$CLINIC_DB_FILE"
                    echo "                address: '${address}'," >> "$CLINIC_DB_FILE"
                    echo "                access: '${access}'," >> "$CLINIC_DB_FILE"
                    echo "                campaign: '${campaign}'," >> "$CLINIC_DB_FILE"
                    echo "                price: '${monthly_price}'," >> "$CLINIC_DB_FILE"
                    echo "                features: [" >> "$CLINIC_DB_FILE"
                    echo "                    '${feature1}'," >> "$CLINIC_DB_FILE"
                    echo "                    '${feature2}'," >> "$CLINIC_DB_FILE"
                    echo "                    '${feature3}'" >> "$CLINIC_DB_FILE"
                    echo "                ]," >> "$CLINIC_DB_FILE"
                    echo "                url: '${clinic_url}'," >> "$CLINIC_DB_FILE"
                    echo "                phone: '${phone}'" >> "$CLINIC_DB_FILE"
                    
                    if [ $rank -eq 3 ]; then
                        echo "            }" >> "$CLINIC_DB_FILE"
                    else
                        echo "            }," >> "$CLINIC_DB_FILE"
                    fi
                fi
                rank=$((rank + 1))
            done
        fi
        
        echo "        ]" >> "$CLINIC_DB_FILE"
        echo "    }," >> "$CLINIC_DB_FILE"
        echo "" >> "$CLINIC_DB_FILE"
    done

    cat >> "$CLINIC_DB_FILE" << 'EOF'
};

// データベースからクリニック情報を取得する関数
function getClinicDataByRegionId(regionId, regionName) {
    if (CLINIC_DATABASE_GENERATED[regionId]) {
        console.log(`詳細クリニックデータを取得: ${regionId} (${regionName})`);
        return CLINIC_DATABASE_GENERATED[regionId];
    }
    
    console.log(`データが見つかりません: ${regionId} (${regionName})`);
    return null;
}

// エクスポート（CommonJS環境の場合）
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        CLINIC_DATABASE_GENERATED,
        getClinicDataByRegionId
    };
}

// グローバルに公開
window.CLINIC_DATABASE_GENERATED = CLINIC_DATABASE_GENERATED;
window.getClinicDataByRegionId = getClinicDataByRegionId;
EOF

    echo "クリニックデータベースを生成しました: ${CLINIC_DB_FILE}"
}

# region-config-generated.js を生成
generate_region_config() {
    echo "地域設定ファイルを生成中..."
    
    cat > "$REGION_CONFIG_FILE" << 'EOF'
// 自動生成された地域設定ファイル
// このファイルは update-data.sh により自動生成されます。直接編集しないでください。

const REGION_CONFIG_GENERATED = {
    regions: {
EOF

    # 地域マスターを読み取り、地域設定を生成
    tail -n +2 "${DATA_DIR}/region_master.csv" | while IFS=',' read -r region_id region_name area_text station_info; do
        # CSVの引用符を除去
        region_id=$(echo "$region_id" | sed 's/"//g')
        region_name=$(echo "$region_name" | sed 's/"//g')
        area_text=$(echo "$area_text" | sed 's/"//g')
        station_info=$(echo "$station_info" | sed 's/"//g')
        
        # 地域キーを小文字で生成（例：001→hokkaido, 013→tokyo）
        case "$region_id" in
            "001") region_key="hokkaido" ;;
            "004") region_key="miyagi" ;;
            "012") region_key="chiba" ;;
            "013") region_key="tokyo" ;;
            "023") region_key="aichi" ;;
            "027") region_key="osaka" ;;
            *) region_key="region${region_id}" ;;
        esac
        
        echo "        '${region_key}': {" >> "$REGION_CONFIG_FILE"
        echo "            id: '${region_id}'," >> "$REGION_CONFIG_FILE"
        echo "            name: '${region_name}'," >> "$REGION_CONFIG_FILE"
        echo "            areaText: '${area_text}'," >> "$REGION_CONFIG_FILE"
        echo "            stationInfo: '${station_info}'," >> "$REGION_CONFIG_FILE"
        echo "            clinics: []" >> "$REGION_CONFIG_FILE"
        echo "        }," >> "$REGION_CONFIG_FILE"
    done

    cat >> "$REGION_CONFIG_FILE" << 'EOF'
    },

    currentRegion: 'chiba',

    switchRegion: function(regionKey) {
        if (this.regions[regionKey]) {
            this.currentRegion = regionKey;
            this.updateAllComponents();
            console.log(`地域を${this.regions[regionKey].name}に切り替えました`);
        }
    },

    getCurrentRegion: function() {
        return this.regions[this.currentRegion];
    },

    updateAllComponents: function() {
        const event = new CustomEvent('regionChanged', {
            detail: { 
                region: this.currentRegion,
                data: this.getCurrentRegion()
            }
        });
        
        window.dispatchEvent(event);
        
        const iframes = document.querySelectorAll('iframe');
        iframes.forEach(iframe => {
            try {
                iframe.contentWindow.postMessage({
                    type: 'regionChanged',
                    region: this.currentRegion,
                    data: this.getCurrentRegion()
                }, '*');
            } catch (e) {
                console.warn('iframe通信エラー:', e);
            }
        });
    },

    init: function() {
        this.createRegionSelector();
        setTimeout(() => {
            this.updateAllComponents();
        }, 1000);
    },

    createRegionSelector: function() {
        const selector = document.createElement('div');
        let optionsHTML = '';
        
        // 動的にオプションを生成
        for (const [key, region] of Object.entries(this.regions)) {
            optionsHTML += `<option value="${key}">${region.name}エリア</option>`;
        }
        
        selector.innerHTML = `
            <div style="
                position: fixed;
                top: 20px;
                right: 20px;
                background: white;
                border: 2px solid #007bff;
                border-radius: 8px;
                padding: 15px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                z-index: 9999;
                font-family: sans-serif;
                min-width: 200px;
            ">
                <h4 style="margin: 0 0 10px 0; color: #007bff;">地域を選択</h4>
                <select id="regionSelector" style="
                    width: 100%;
                    padding: 8px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    font-size: 14px;
                ">
                    ${optionsHTML}
                </select>
            </div>
        `;
        
        document.body.appendChild(selector);
        
        const selectElement = document.getElementById('regionSelector');
        selectElement.value = this.currentRegion;
        selectElement.addEventListener('change', (e) => {
            this.switchRegion(e.target.value);
        });
    }
};

document.addEventListener('DOMContentLoaded', () => {
    REGION_CONFIG_GENERATED.init();
});

window.REGION_CONFIG_GENERATED = REGION_CONFIG_GENERATED;
EOF

    echo "地域設定ファイルを生成しました: ${REGION_CONFIG_FILE}"
}

# CSVファイルを監視して自動更新する関数
watch_csv_files() {
    echo "CSVファイルの監視を開始します..."
    echo "変更があった場合、自動的にJSファイルを再生成します"
    echo "終了するには Ctrl+C を押してください"
    
    # fswatch がインストールされている場合
    if command -v fswatch >/dev/null 2>&1; then
        fswatch -o "${DATA_DIR}/*.csv" | while read f; do
            echo "CSVファイルの変更を検出しました。JSファイルを更新します..."
            generate_clinic_database
            generate_region_config
            echo "更新完了！"
        done
    else
        echo "警告: fswatch がインストールされていません"
        echo "brew install fswatch でインストールすることで、自動監視機能を使用できます"
        echo "現在は手動実行のみです"
    fi
}

# メイン処理
case "${1:-generate}" in
    "generate")
        generate_clinic_database
        generate_region_config
        echo "=== 生成完了 ==="
        ;;
    "watch")
        generate_clinic_database
        generate_region_config
        watch_csv_files
        ;;
    *)
        echo "使用方法:"
        echo "  $0 generate  # JSファイルを生成"
        echo "  $0 watch     # CSVファイルを監視して自動更新"
        ;;
esac