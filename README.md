# temporary
全部一番上の階層に置く、階層構造は以下を想定

```
OSS/
├── main.ps1               # 6か月削除とリネームの本体
├── Delte_6Month.bat       # main.ps1 の起動用
├── Insert_Date.ps1        # 日付付与の本体
├── Insert_Date_All.bat    # Insert_Date.ps1 の起動用
├── Filter_Del.bat         # 削除一覧の抽出
├── deleted_list.txt       # Filter_Del.bat が生成
├── あ/                    # 50音フォルダ
│   ├── あ/                # 子音フォルダ
│   │   └── 〇〇運輸-yyyyMMddHHmm/   # 会社フォルダ
│   │       └── 名前_YYYYMMDD/       # 車
|   |── い/
│   │   └── 〇〇運輸-yyyyMMddHHmm/   # 会社フォルダ
│   │       └── 名前_YYYYMMDD/       # 車
├── か/ さ/ た/ な/ は/ ま/ や/ ら/ わ/
```

ファイル名は拡張子も含めて入力 `.bat` `.ps1`
