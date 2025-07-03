[TOP](../README.md)<br/>
# Raspberry Pi5 と GNSS モジュールの初期設定
## 0. テスト環境
Raspberry Pi5, M.2 HAT+, Ubuntu 24.02.2 LTS<br/>
Rpi-F9PD9C (本基板)<br/>
GNSS ANT: L1,L2,L6<br/>
ZED-F9P, NEO-D9C UART: 921600bps, 8N1<br/>
UART0: ZED-F9P data<br/>
UART1: NEO-D9C data<br/>
UART4: ZED-F9P config (ネットワーク越しに ublox で設定できる様にする)<br/>
UART3: NEO-D9D config (ネットワーク越しに ublox で設定できる様にする)<br/>
ネットワークポート番号 2000: ZED-F9P UART4 送受信データのリレー
ネットワークポート番号 2001: NEO-D9C UART3 送受信データのリレー
u-center 24.10

## 1. Ubuntu の設定
/boot/firmware/config.txt に以下を追加
```
% sudo vi /boot/firmware/config.txt
[all]
init_uart_baud=921600
enable_uart=1
dtparam=uart0,console=off
dtparam=uart0=on
dtparam=uart1=on
dtparam=uart2=on
dtparam=uart3=on
dtparam=uart4=on
dtparam=disable-bt

dtoverlay=pps-gpio,gpiopin=18,assert_falling_edge=false

gpio=22=op,dh            # turn on the GNSS board when the Rpi is booted
```

変更後 reboot してください.

## 2. 電源の投入方法
   本基板のは GPIO22 (pin15) によって電源が入る様になっています. その為以下のコマンドを実行して電源を投入してください. ただし, USB Type-C を外部の PC や USB PD に接続している場合はコマンドを実行しなくても電源が入ります. もし /boot/firmware/config.txt に "gpio=22,op,dh" を記述した場合は起動時に自動的に on になります
```
% gpioset gpiochip4 22=1
```

## 3. GNSS (GPS) ツールのインストールと設定
### 3-1. ツールのインストール
```
% sudo apt install -y gpsd gpsd-clients pps-tools
```
### 3-2. /etc/default/gpsd の設定

### 3-3. PPS の設定
### 3-4. pps-gpio モジュールの追加
### 3-5. gpsd.socket の有効化

## 4. ZED-F9P の設定
ZED-F9P の一番最初の設定は USB Type-C で Windows 上の u-center での設定をしてください. ZED-F9P は USB 仮想シリアルポートですので baud の設定は特に気にしなくて結構です. 本基板の USB Type-C CN には HUB によって ZED-F9P と NEO-D9C の 2 つに接続しています. その為 u-center には 2 つの GNSS モジュールが見える事になります. いずれかの GNSS に接続 (Receiver -> Connection -> COMxx) し, 衛星の軌道や緯度経度時間などが表示されれば ZED-F9P に接続した事になりなすし, 何も表示されなければ NEO-D9C になります. もし正確に確認したいのであれば, いずれかのモジュールに接続した状態で "View-> Messages" で Messages ウィンドウが開き UBX - MON - VER の Extension(s) 内に<br/>
ZED-F9Pの場合
```
MOD=ZED-F9P
```
NEO-D9Cの場合
```
MOD=NEO-D9C
```
が表示されます.

### 4-1. firmware update
ublox 社のサイトからファームウェア 1.51 をダウンロードします

[ZED-F9P HPG1.51](https://content.u-blox.com/sites/default/files/2024-11/UBX_F9_100_HPG151_ZED_F9P.6c43b30ccfed539322eccedfb96ad933.bin)

u-center の "Tools -> Firmware Update" を選択し "Firmware Update Utility" ウィンドウを開く. Firmware image でダウンロードしたファームウェアを選び左下にある "GO" を押しファームウェアを更新します.
最新ファームウェアは ublox ZED-F9P04B の製品サイトの "Documentation & resouces" の "Firmware Update" を参照してください.
### 4-2. 設定
以下を設定する.
1. UART1, UART2  921600 8N1                (UBX-CFG-PRT)
2. UBX+NMEA+RTCM3 in, UBX+NMEA+RTCM3 out   (UBX-CFG-PRT)
3. みちびき衛星受信有効                       (UBX-CFG-NMEA)
4. 高精度測位モード有効                       (UBX-CFG-NMEA)
5. データ出力設定 (高精度位置情報)             (UBX-CFG-MSG- 01-14 NAV-HPPOSLLH)
6. 設定書き込み

[ZED-F9P_Fw151_00_init921600.txt](../conf/ZED-F9P_Fw151_00_init921600.txt) をダウンロードし, u-center の "Tools -> Receiver Configuration" で "Load/Save Receiver Configurataion" ウィンドウが開くので "Confituration file" でダウンロードしたファイルを指定する. その後 "Load configuration" 内の "Transfer file -> GNSS" を押す事により設定される. その後不揮発メモリに保存する為に**"Receiver -> Action -> Save Config" を選択し保存**する. 特にウィンドウは出ない.

## 5. NEO-D9C の設定
### 4-1. firmware update
最新ファームウェアは ublox NEO-D9C の製品サイトの "Documentation & resouces" の "Firmware Update" を参照してください.

### 4-2. 設定
以下を設定する.
1. UART1, UART2  921600 8N1                  (UBX-PRT)
2. UBX+NMEA+RTCM3 in, UBX+NMEA+RTCM3 out     (UBX-PRT)
3. 高精度測位モード有効                         (UBX-CFG)
4. 設定書き込み

[NEO-D9C_Fw151_00_init921600.txt](../conf/NEO-D9C_Fw151_00_init921600.txt) をダウンロードし, u-center の "Tools -> Receiver Configuration" で "Load/Save Receiver Configurataion" ウィンドウが開くので "Confituration file" でダウンロードしたファイルを指定する. その後 "Load configuration" 内の "Transfer file -> GNSS" を押す事により設定される. その後不揮発メモリに保存する為に**"Receiver -> Action -> Save Config" を選択し保存**する. 特にウィンドウは出ない.
