[TOP](../README.md)<br/>
# NTRIP による高精度位置情報の取得
![rtk image](rtkImage.png)<br/>
図中の "移動局(Rover Station)" 本基板に相当します
本基板上の NEO-D9C の CLAS を使用しないで外部の基準局の補正情報 (RTCM) を利用して高精度位置情報を得る場合は Rasberry Pi5 をネットワークにアクセスできる状態で以下のコマンドを実行してください. ただし, 基準局は自局から約 10km 程度まで最悪 20km までの局を選択してください.

例 CQ 出版社の NTRIP server から RTCM を取得し ZED-F9P に入力
```
/usr/local/bin/str2str -in ntrip://guest:guest@160.16.134.72:80/CQ-F9P -out /dev/ttyAMA0
```
