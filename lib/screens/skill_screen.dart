import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // リストを保存するためにJSON変換機能を使う

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() {
    return _SkillScreenState();
  }
}

class _SkillScreenState extends State<SkillScreen> {
  // --- データ保存用リスト ---
  List<Map<String, dynamic>> _skills = [];
  List<Map<String, dynamic>> _personalities = [];
  List<Map<String, dynamic>> _licenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // リストは "JSON文字列" として保存/読込
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 保存された文字データを読み出し、元のリストの形に戻す (jsonDecode)
      String? skillsJson = prefs.getString('s_skills');
      if (skillsJson != null) {
        _skills = List<Map<String, dynamic>>.from(jsonDecode(skillsJson));
      }

      String? personalitiesJson = prefs.getString('s_personalities');
      if (personalitiesJson != null) {
        _personalities = List<Map<String, dynamic>>.from(jsonDecode(personalitiesJson));
      }

      String? licensesJson = prefs.getString('s_licenses');
      if (licensesJson != null) {
        _licenses = List<Map<String, dynamic>>.from(jsonDecode(licensesJson));
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // リストを文字データに変換して保存 (jsonEncode)
    await prefs.setString('s_skills', jsonEncode(_skills));
    await prefs.setString('s_personalities', jsonEncode(_personalities));
    await prefs.setString('s_licenses', jsonEncode(_licenses));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("スキル・性格 (Skills)"),
        backgroundColor: Colors.blue[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. 技術スキル
            // ==========================================
            _buildSectionHeader("◆ 技術スキル (Technical Skills)", () {
              _showSkillDialog();
            }),
            
            if (_skills.isEmpty) 
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("まだ登録されていません。「＋」ボタンで追加してください。", style: TextStyle(color: Colors.grey)),
              ),

            ..._skills.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> skill = entry.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(skill['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                onPressed: () => _showSkillDialog(index: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _skills.removeAt(index);
                                  });
                                  _saveData(); // 削除したら保存
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("0"),
                          Expanded(
                            child: Slider(
                              value: skill['value'],
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: skill['value'].round().toString(),
                              onChanged: (val) {
                                setState(() {
                                  skill['value'] = val;
                                });
                                _saveData(); // スライダー動かしたら保存
                              },
                            ),
                          ),
                          Text(skill['value'].round().toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Divider(height: 40, thickness: 2),

            // ==========================================
            // 2. 性格分析
            // ==========================================
            _buildSectionHeader("◆ 性格分析 (Personality)", () {
              _showPersonalityDialog();
            }),
            
            if (_personalities.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("性格データがありません。", style: TextStyle(color: Colors.grey)),
              ),

            ..._personalities.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              
              int rightVal = (item['value'] * 100).round();
              int leftVal = 100 - rightVal;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${item['left']} ⇔ ${item['right']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                onPressed: () => _showPersonalityDialog(index: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _personalities.removeAt(index);
                                  });
                                  _saveData();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(item['left'], style: const TextStyle(color: Colors.blue, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text("$leftVal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Expanded(
                            child: Slider(
                              value: item['value'],
                              onChanged: (val) {
                                setState(() {
                                  item['value'] = val;
                                });
                                _saveData();
                              },
                            ),
                          ),
                          Text("$rightVal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(item['right'], style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Divider(height: 40, thickness: 2),

            // ==========================================
            // 3. 資格・検定
            // ==========================================
            _buildSectionHeader("◆ 資格・検定 (Certifications)", () {
              _showLicenseDialog();
            }),
            
            if (_licenses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("資格が登録されていません。", style: TextStyle(color: Colors.grey)),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _licenses.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified, color: Colors.orange),
                    title: Text(_licenses[index]['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showLicenseDialog(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _licenses.removeAt(index);
                            });
                            _saveData();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
        ),
      ],
    );
  }

  // --- ダイアログ ---

  void _showSkillDialog({int? index}) {
    TextEditingController controller = TextEditingController();
    if (index != null) {
      controller.text = _skills[index]['name'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "スキルを追加" : "スキルを編集"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "例: Python, Flutter"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      _skills.add({'name': controller.text, 'value': 50.0});
                    } else {
                      _skills[index]['name'] = controller.text;
                    }
                  });
                  _saveData(); // 保存
                  Navigator.pop(context);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showPersonalityDialog({int? index}) {
    TextEditingController leftController = TextEditingController();
    TextEditingController rightController = TextEditingController();

    if (index != null) {
      leftController.text = _personalities[index]['left'];
      rightController.text = _personalities[index]['right'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "性格指標を追加" : "性格指標を編集"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: leftController, decoration: const InputDecoration(labelText: "左側の性質")),
              TextField(controller: rightController, decoration: const InputDecoration(labelText: "右側の性質")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
            ElevatedButton(
              onPressed: () {
                if (leftController.text.isNotEmpty && rightController.text.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      _personalities.add({'left': leftController.text, 'right': rightController.text, 'value': 0.5});
                    } else {
                      _personalities[index]['left'] = leftController.text;
                      _personalities[index]['right'] = rightController.text;
                    }
                  });
                  _saveData(); // 保存
                  Navigator.pop(context);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showLicenseDialog({int? index}) {
    TextEditingController controller = TextEditingController();
    if (index != null) {
      controller.text = _licenses[index]['name'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "資格を追加" : "資格を編集"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "例: ITパスポート"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    if (index == null) {
                      _licenses.add({'name': controller.text});
                    } else {
                      _licenses[index]['name'] = controller.text;
                    }
                  });
                  _saveData(); // 保存
                  Navigator.pop(context);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}