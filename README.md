# 「FPGA × 仮想通貨」 ソースコード

サークル電脳律速が頒布している同人誌「FPGA×仮想通貨」関連のソースコードです。

## 同人誌「FPGA×仮想通貨」について

下記URLを参照願います。  
https://d-rissoku.net/サークルサポート/fpga_x_仮想通貨/

PDF版をBOOTHにて販売中です。  
https://d-rissoku.booth.pm/items/1039985

## 各ディレクトリの内容
### 3.1_sha256/
同人誌の3.1節で扱っているSHA-256のHash処理の非パイプライン版の実装（sha256モジュール）とテストベンチ、並びに期待値生成プログラムです。

### 3.2_sha256_pipeline/
同人誌の3.2節で扱っているSHA-256のHash処理のパイプライン化版の実装(sha256_pipelineモジュール)とテストベンチです。

### bitcoin_fpga/
同人誌の4章で扱っている bitcoin_miner とPYNQ-Z1のPLへの実装です。Vivadoのプロジェクト一式です。

#### bitcoin_fpga/ip_repo/bitcoin_miner_ip_1.0/src
同人誌の4.2節で扱っている bitcoin_miner モジュールです。bitcoin_minerのテストベンチは、このディレクトリ内では無く test_bitcoin_fpga ディレクトリ内にあります。

#### bitcoin_fpga/ip_repo/bitcoin_miner_ip_1.0/hdl
同人誌の4.3節で扱っている IPのスケルトンに bitcoin_miner モジュールを組み込んだコードです。

### test_bitcoin_fpga/
同人誌の4.2.3節と4.2.4節で扱っているbitcoin\_minerテスト用の期待値入手スクリプトとbitcoin\_minerのテストベンチです。

### jupyter_notebooks/
bitcoin_minerをPYNQ-Z1のJupyter Notebookから利用するときに利用する miner.py と、miner.pyを利用してbitcoin_minerのテストをしたときのNotebook（test_bitcoin_miner.ipynb）です。

miner.binは bitcoin_fpga/ のプロジェクトで生成したBitstreamをリネームしたものです。
miner.tclは、bitcoin_fpga/ のプロジェクトのBlcok DesignをVivadoで開いた状態で、メニューより File -> Export -> Export Block Designを選択して生成したファイルをリネームしたものです。

## bitcoin_fpga で実際にマイニングを行う方法

PYNQ-Z1のPLを jupyter_notebooks/miner.py を用いてbitcoin_minerにコンフィグレーションした状態にて、次のレポジトリにある bitcoin_minerを利用するように改造した cpuminer-multi をビルドしたものを実行します。

https://github.com/BOSUKE/cpuminer-multi

bitcoin_miner向けに改造したcpuminer-multiの実行の仕方などは上記レポジトリのREADME.mdを参照してください。
