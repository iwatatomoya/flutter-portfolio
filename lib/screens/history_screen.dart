import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // 追加

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() {
    return _HistoryScreenState();
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  // --- データ保存用変数 ---
  List<Map<String, String>> _historyList = [];
  String _selfPr = "";
  String _gakuchika = "";
  List<Map<String, String>> _worksList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selfPr = prefs.getString('h_selfPr') ?? "";
      _gakuchika = prefs.getString('h_gakuchika') ?? "";

      String? historyJson = prefs.getString('h_historyList');
      if (historyJson != null) {
        // List<dynamic> から List<Map<String, String>> への変換は少し丁寧に行う
        List<dynamic> decoded = jsonDecode(historyJson);
        _historyList = decoded.map((e) => Map<String, String>.from(e)).toList();
      }

      String? worksJson = prefs.getString('h_worksList');
      if (worksJson != null) {
        List<dynamic> decoded = jsonDecode(worksJson);
        _worksList = decoded.map((e) => Map<String, String>.from(e)).toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('h_selfPr', _selfPr);
    await prefs.setString('h_gakuchika', _gakuchika);
    await prefs.setString('h_historyList', jsonEncode(_historyList));
    await prefs.setString('h_worksList', jsonEncode(_worksList));
  }

  @override
  Widget build(BuildContext context) {
    String display(String text) => text.isEmpty ? "(未入力)" : text;

    return Scaffold(
      appBar: AppBar(
        title: const Text("経歴・実績 (History)"),
        backgroundColor: Colors.blue[50],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 経歴
            _buildSectionHeader("◆ 経歴 (Education / Career)", () => _showHistoryDialog()),
            
            if (_historyList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("経歴が登録されていません。", style: TextStyle(color: Colors.grey)),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final item = _historyList[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.circle, size: 12, color: Colors.blue),
                    title: Text("${item['year']}年 ${item['month']}月"),
                    subtitle: Text(
                      item['content']!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _historyList.removeAt(index);
                        });
                        _saveData();
                      },
                    ),
                  ),
                );
              },
            ),

            const Divider(height: 40, thickness: 2),

            // 自己PR & ガクチカ
            const Text("◆ アピールポイント", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildEditableTextCard(
              title: "自己PR",
              content: display(_selfPr),
              onEdit: () {
                _showLongTextDialog("自己PR", _selfPr, (val) {
                  setState(() => _selfPr = val);
                  _saveData();
                });
              },
            ),

            const SizedBox(height: 10),

            _buildEditableTextCard(
              title: "学生時代に力を入れたこと (ガクチカ)",
              content: display(_gakuchika),
              onEdit: () {
                _showLongTextDialog("ガクチカ", _gakuchika, (val) {
                  setState(() => _gakuchika = val);
                  _saveData();
                });
              },
            ),

            const Divider(height: 40, thickness: 2),

            // 作品・実績
            _buildSectionHeader("◆ 作品・活動実績 (Works)", () => _showWorksDialog()),
            
            if (_worksList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("作品や実績を追加してください。", style: TextStyle(color: Colors.grey)),
              ),

            ..._worksList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> work = entry.value;
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ExpansionTile(
                  leading: const Icon(Icons.folder_special, color: Colors.orange),
                  title: Text(work['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      color: Colors.grey[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("【詳細・苦労した点】", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text(work['detail']!),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              label: const Text("削除", style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                setState(() {
                                  _worksList.removeAt(index);
                                });
                                _saveData();
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
        ),
      ],
    );
  }

  Widget _buildEditableTextCard({required String title, required String content, required VoidCallback onEdit}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: onEdit),
              ],
            ),
            const Divider(),
            Text(content, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }

  // --- ダイアログ ---

  void _showHistoryDialog() {
    final yearCtrl = TextEditingController();
    final monthCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("経歴を追加"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: yearCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "年"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: monthCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "月"))),
              ],
            ),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: "内容")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              if (yearCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                setState(() {
                  _historyList.add({
                    'year': yearCtrl.text,
                    'month': monthCtrl.text,
                    'content': contentCtrl.text,
                  });
                  _historyList.sort((a, b) {
                     int yearA = int.tryParse(a['year'] ?? "0") ?? 0;
                     int yearB = int.tryParse(b['year'] ?? "0") ?? 0;
                     return yearB.compareTo(yearA);
                  });
                });
                _saveData(); // 保存
                Navigator.pop(context);
              }
            },
            child: const Text("追加"),
          ),
        ],
      ),
    );
  }

  void _showLongTextDialog(String title, String currentText, Function(String) onSave) {
    final ctrl = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$titleを編集"),
        content: TextField(
          controller: ctrl,
          maxLines: 8,
          decoration: const InputDecoration(hintText: "入力してください", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              onSave(ctrl.text); // ここで setState と _saveData が呼ばれる
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  void _showWorksDialog() {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("作品・実績を追加"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "タイトル")),
            const SizedBox(height: 10),
            TextField(controller: detailCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "詳細", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  _worksList.add({
                    'title': titleCtrl.text,
                    'detail': detailCtrl.text,
                  });
                });
                _saveData(); // 保存
                Navigator.pop(context);
              }
            },
            child: const Text("追加"),
          ),
        ],
      ),
    );
  }
}