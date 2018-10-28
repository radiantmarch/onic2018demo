# Demo for ONIC 2018

ONIC 2018 () 講演 [1] で行った pyATS + NSO + VIRL のデモです

[1] http://onic.jp/program-detail/#s05

講演資料はこちら

この README ファイルはデモを実行するための情報を記載しています。

pyATS の概要についてはこちら:
NSO についてはこちら:
VIRL についてはこちら:


## デモ環境 要件

- python 3 実行環境
- インターネット接続
	- git clone, pip の実行が必要
- VIRL サーバ
- NSO サーバ
    - Ubuntu VM 上にインストール


## デモ環境

- Client
	- MacBook Pro, macOS 10.13.6
	- Python 3.4.7 (virtualenv)
    	- Note: 3.4 以降であれば動くはずだが、3.6 の若いバージョンでは動作しなかったことがあるので注意

- Servers
	- VIRL VM (1.5.154) - 24vCPU, 128GB DRAM
    	- Note: VM が3~4台程度動けばよい。ここまでのスペックは実際には不要
    	- Mac 上の VMware Fusion 上の VIRL でもデモ可能（パフォーマンスに注意）
	- ESXi 6.0 update 3
    	- Note: VIRL が動作すれば問題ない
	- NSO 4.7.1
    	- Ubuntu 14.04 LTS 上で動作
    	- `apt install make gcc ant openjdk-8-jdk`
    	- Mac 上で動作させても問題ない


## インストール

- Python 環境の準備
	- 今回は pyenv を利用
		- (セットアップ方法は https://qiita.com/koooooo/items/b21d87ffe2b56d0c589b を参照)

```
cd; mkdir onicdemo
cd onicdemo
pyenv local 3.4.7
pip install --upgrade pip
pip install virtualenv
virtualenv venv
source venv/bin/activate
```

- 今後は常にこの virtual env で作業する。別のターミナルを開いた場合も毎回 source コマンドを実行する

- Git レポジトリをクローン

```
git clone xxxx demo

```

- 必要な python ライブラリのインストール
```
cd demo
pip install -r requirements.txt

```

- (参考) インストールするライブラリ一覧 (requirements.txt の中身)
```
pyats
genie
genie.libs.robot
jupyter
virlutils
```


## デモ準備

- 環境の確認

![demo_env](images/onic2018_cisco_netdevops_pyats_nso_ss_v1_p14.png)


- VIRL 環境変数を設定

```
export VIRL_HOST=10.71.158.113
export VIRL_USERNAME=guest
export VIRL_PASSWORD=guest
```

- VIRL トポロジファイルの確認

```
cat topology.virl
```


- VIRL シミュレーションの起動
```
cd; cd onicdemo
virl ls
virl up
(起動まで待機)
virl nodes
(すべてのノードが ACTIVE 表示されたらOK)
```

- VIRL トポロジから pyATS 用テストベッドファイルを生成

```
virl generate pyats
=> default_testbed.yaml ファイルが生成される
```

- テストベッドファイルを環境に合わせて修正
    -


- robot コマンドでログを生成できるように Alias でオプションを設定

`alias robot='robot -d archive/$(LC_ALL=C gdate +"%Y%m%d_%H%M%S")'`


- Jupyter ノートブックを起動 (動作確認とデモ3 で利用する)
`jupyter-notebook &`

- ブラウザが開くので `ONIC Demo Note.ipynb` を開く

- 上から順番にコマンドを実行し、成功することを確認する
    - Note: テスト後にそれぞれのデバイスから切断することを忘れない。例) ios1.disconnect()
    - 切断していないとこのセッションがコンソール接続を専有してしまい、このあとの robot コマンドでの接続がうまくいかない。



## デモ手順

### デモ1: Unicon Library を利用したプログラミング的デバイス操作と試験

- VIRL client (VM Maestro)でトポロジを確認

![virl-topology](images/virl-topology.png)


- `demo1-scenario.txt` でデモの流れを確認
- `demo1.robot` ファイルを確認

- robot コマンドでテストを実行
```
robot demo1.robot
```

- 出力例 (一部出力を省略***しています)
```
(venv)***$ robot demo1.robot
==============================================================================
Demo1
==============================================================================
UUT デバイスに接続                                                    | PASS |
------------------------------------------------------------------------------
Execute "show ip route" on device r1                                  | PASS |
------------------------------------------------------------------------------
Shutdown loopback interface on device r2                              | PASS |
------------------------------------------------------------------------------
Execute "show ip route" on device r1 after trigger                    Waiting 10 seconds for routing convergence...
Execute "show ip route" on device r1 after trigger                    | PASS |
------------------------------------------------------------------------------
Restore loopback interface on device                                  | PASS |
------------------------------------------------------------------------------
Demo1                                                                 | PASS |
5 critical tests, 5 passed, 0 failed
5 tests total, 5 passed, 0 failed
==============================================================================
Output:  ***onicdemo/demo/archive/20181028_112114/output.xml
Log:     ***onicdemo/demo/archive/20181028_112114/log.html
Report:  ***onicdemo/demo/archive/20181028_112114/report.html
```

- 出力されたレポートを確認
`open ~/onicdemo/demo/archive/20181028_112114/log.html`

- レポート例

![demo1-report-sample](images/demo1-report-sample.png)
図: Robot ファイルで定義した通りにテストが実行され、セクションごとにログが整理されている

![demo1-report-log-1](images/demo1-report-log-1.png)
図: IOS でのコマンド実行結果


- サマリー
    - robot フレームワークとその裏で動作する pyATS/Unicon ライブラリを利用して、ルータに接続しコマンドを実行
    - コマンド出力に基づいてテストを行い Pass/Fail の判定を出力
    - ログやテスト結果が自動的にレポート出力される


### デモ2: Genie Parser Library を利用したデバイスステートの取得と検証

- 前置き
    - デモ1 でやったのは show ip route の出力を単純にテキスト処理して、成功・失敗を判定。
    - 実際のテストではコマンド出力をもっと詳しく
    - デモ2 では bgp コマンド

- `demo2.robot` の確認
    -

- robot コマンドでテストを実行
`robot demo2.robot`

- 出力例. このデモではあえて
```
(venv)***$ robot demo2.robot
==============================================================================
Demo2
==============================================================================
UUT デバイスに接続                                                    | PASS |
------------------------------------------------------------------------------
Execute and parse "show bgp all neighbor" on IOS-XE                   ...
Original JSON
{"list_of_neighbors": ["192.168.0.2", "192.168.0.3"], "vrf": {"default": {"neighbor": {"192.168.0.3": {"bgp_session_transport": {"unread_input_bytes": 0, "tcp_path_mtu_discovery": "enabled", "irs": 1011041344, "outgoing_ttl": 255, "connection_state": "estab", "packet_slow_path": 0, "fast_lock_acquisition_failures": 0, "ip_precedence_value": 6, "rib_route_ip": "192.168.0.3", "rcvnxt": 1011325784, "status_flags": "active open", "maximum_output_segment_queue_size": 50, "maxrcvwnd": 16384, "datagram": {"datagram_sent": {"value": 31381, "total_data": 313142, "with_data": 16476, "partialack": 0, "fastretransmit": 0, "retransmit": 1, "second_congestion": 0}, "datagram_received": {"value": 31405, "out_of_order": 0, "total_data": 284439, "with_data": 14964}}, "ecn_connection": "disabled", "rtv": 3, "option_flags": "nagle, path mtu capable", "rcvwnd": 16251, "delrcvwnd": 133, "packet_fast_processed": 0, "lock_slow_path": 0, "receive_idletime": 16091, "krtt": 0, "packet_fast_path": 0, "rtto": 1003, "rcv_scale": 0, "sndnxt": 1787674355, "uptime": 897731238, "io_status": 1, "connection_tableid": 0, "max_rtt": 1000, "tcp_semaphore": "0x7F13DBB0A550", "ack_hold": 200, "graceful_restart": "disabled", "min_time_between_advertisement_runs": 0, "connection": {"last_reset": "never", "established": 1, "dropped": 0}, "minimum_incoming_ttl": 0, "srtt": 1000, "sndwnd": 16616, "tcp_semaphore_status": "FREE", "transport": {"local_port": "11809", "local_host": "192.168.0.1", "mss": 536, "foreign_host": "192.168.0.3", "foreign_port": "179"}, "min_rtt": 11, "address_tracking_status": "enabled", "iss": 1787361212, "enqueued_packets": {"mis_ordered_packet": 0, "input_packet": 0, "retransmit_packet": 0}, "snduna": 1787674355, "sent_idletime": 15890, "snd_scale": 0}, "bgp_event_timer": {"next": {"retrans": "0x0", "timewait": "0x0", "sendwnd": "0x0", "giveup": "0x0", "processq": "0x0", "keepalive": "0x0", "pmtuager": "0x0", "deadwait": "0x0", "ackhold": "0x0", "linger": "0x0"}, "starts": {"retrans": 16476, "timewait": 0, "sendwnd": 0, "giveup": 0, "processq": 0, "keepalive": 0, "pmtuager": 1, "deadwait": 0, "ackhold": 14965, "linger": 0}, "wakeups": {"retrans": 1, "timewait": 0, "sendwnd": 0, "giveup": 0, "processq": 0, "keepalive": 0, "pmtuager": 1, "deadwait": 0, "ackhold": 14387, "linger": 0}}, "address_family": {"ipv4 unicast": {"last_write": "00:00:44", "session_state": "established", "current_time": "0x358591A1", "up_time": "1w3d", "last_read": "00:00:16"}}, "bgp_negotiated_capabilities": {"four_octets_asn": "advertised and received", "route_refresh": "advertised and received(new)", "graceful_restart": "received", "enhanced_refresh": "advertised", "graceful_restart_af_advertised_by_peer": "IPv4 Unicast (was not preserved", "ipv4_unicast": "advertised and received", "graceful_remote_restart_timer": 120, "stateful_switchover": "NO for session 1"}, "bgp_neighbor_counters": {"messages": {"received": {"total": 14966, "route_refresh": 0, "notifications": 0, "updates": 2, "opens": 1, "keepalives": 14963}, "out_queue_depth": 0, "sent": {"total": 16477, "route_refresh": 0, "notifications": 0, "updates": 2, "opens": 1, "keepalives": 16474}, "in_queue_depth": 0}}, "bgp_version": 4, "remote_as": 1, "bgp_negotiated_keepalive_timers": {"hold_time": 180, "keepalive_interval": 60}, "link": "internal", "description": "iBGP peer nxos3", "router_id": "192.168.0.3", "session_state": "established"}, "192.168.0.2": {"bgp_session_transport": {"unread_input_bytes": 0, "tcp_path_mtu_discovery": "enabled", "irs": 2394978386, "outgoing_ttl": 255, "connection_state": "estab", "packet_slow_path": 0, "fast_lock_acquisition_failures": 0, "ip_precedence_value": 6, "rib_route_ip": "192.168.0.2", "rcvnxt": 2395291740, "status_flags": "active open", "maximum_output_segment_queue_size": 50, "maxrcvwnd": 16384, "datagram": {"datagram_sent": {"value": 32861, "total_data": 312819, "with_data": 16459, "partialack": 0, "fastretransmit": 0, "retransmit": 3, "second_congestion": 0}, "datagram_received": {"value": 32884, "out_of_order": 0, "total_data": 313353, "with_data": 16475}}, "ecn_connection": "disabled", "rtv": 3, "option_flags": "nagle, path mtu capable", "rcvwnd": 16137, "delrcvwnd": 247, "packet_fast_processed": 0, "lock_slow_path": 0, "receive_idletime": 34233, "krtt": 0, "packet_fast_path": 0, "rtto": 1003, "rcv_scale": 0, "sndnxt": 3323724142, "uptime": 897717921, "io_status": 1, "connection_tableid": 0, "max_rtt": 1000, "tcp_semaphore": "0x7F13DBB0A480", "ack_hold": 200, "graceful_restart": "disabled", "min_time_between_advertisement_runs": 0, "connection": {"last_reset": "never", "established": 1, "dropped": 0}, "minimum_incoming_ttl": 0, "srtt": 1000, "sndwnd": 15187, "tcp_semaphore_status": "FREE", "transport": {"local_port": "44433", "local_host": "192.168.0.1", "mss": 1460, "foreign_host": "192.168.0.2", "foreign_port": "179"}, "min_rtt": 0, "address_tracking_status": "enabled", "iss": 3323411322, "enqueued_packets": {"mis_ordered_packet": 0, "input_packet": 0, "retransmit_packet": 0}, "snduna": 3323724142, "sent_idletime": 34434, "snd_scale": 0}, "bgp_event_timer": {"next": {"retrans": "0x0", "timewait": "0x0", "sendwnd": "0x0", "giveup": "0x0", "processq": "0x0", "keepalive": "0x0", "pmtuager": "0x0", "deadwait": "0x0", "ackhold": "0x0", "linger": "0x0"}, "starts": {"retrans": 16463, "timewait": 0, "sendwnd": 0, "giveup": 0, "processq": 0, "keepalive": 0, "pmtuager": 118003, "deadwait": 0, "ackhold": 16475, "linger": 0}, "wakeups": {"retrans": 3, "timewait": 0, "sendwnd": 0, "giveup": 0, "processq": 0, "keepalive": 0, "pmtuager": 118003, "deadwait": 0, "ackhold": 16170, "linger": 0}}, "address_family": {"ipv4 unicast": {"last_write": "00:00:34", "session_state": "established", "current_time": "0x358591A0", "up_time": "1w3d", "last_read": "00:00:45"}}, "bgp_negotiated_capabilities": {"ipv4_unicast": "advertised and received", "route_refresh": "advertised and received(new)", "stateful_switchover": "NO for session 1", "enhanced_refresh": "advertised and received", "four_octets_asn": "advertised and received"}, "bgp_neighbor_counters": {"messages": {"received": {"total": 16476, "route_refresh": 0, "notifications": 0, "updates": 12, "opens": 1, "keepalives": 16463}, "out_queue_depth": 0, "sent": {"total": 16460, "route_refresh": 0, "notifications": 0, "updates": 2, "opens": 1, "keepalives": 16457}, "in_queue_depth": 0}}, "bgp_version": 4, "remote_as": 1, "bgp_negotiated_keepalive_timers": {"hold_time": 180, "keepalive_interval": 60}, "link": "internal", "description": "iBGP peer ios2", "router_id": "192.168.0.2", "session_state": "established"}}}}}
..
Neighbors List
['192.168.0.2', '192.168.0.3']
Execute and parse "show bgp all neighbor" on IOS-XE                   | PASS |
------------------------------------------------------------------------------
Demo2                                                                 | PASS |
2 critical tests, 2 passed, 0 failed
2 tests total, 2 passed, 0 failed
==============================================================================
Output:  ***onicdemo/demo/archive/20181028_113639/output.xml
Log:     ***onicdemo/demo/archive/20181028_113639/log.html
Report:  ***onicdemo/demo/archive/20181028_113639/report.html
```

- 出力の中の Original JSON のテキストを https://jsonformatter.curiousconcept.com/ などで整形して確認

- list_of_neighbors をキーとするエントリに、ネイバーのリストが表示されている

- ポイント
    - Genie ライブラリの一つである Parser の genie.libs.parser.show_bgp.ShowBgpAllNeighbors を使ってコマンド出力をパース
    - 通常のテキスト出力では抽出が難しい情報も、構造化データ (JSON) で取得できる
    - Genie ライブラリには、こうした Parser の他に、特定機能のテストに必要なコンフィグ変更を実行してくれる Trigger や、テスト実行後の正常性判定をしてくれる Verifier も備えている。



### デモ3: NSO を利用したネットワーク全体の設定変更と試験 & ロールバック

- 前置き
    - デモ1, デモ2 では、テスト後、元の状態に戻す（ロールバックする）ためのコマンドをわざわざ投入していた
    - NSO を使うとロールバックが簡単にできる

- Jupyter Notebook を開く (デモ準備で開いている)

- "NSOへの接続（デモ3)" のセクションへ移動しテストを実行

-












<!--  -->
