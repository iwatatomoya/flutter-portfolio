import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- プロフィールデータ ---
  String _name = "";
  String _englishName = "";
  String _affiliation = "";
  String _researchField = "";
  
  String _birthDate = "";
  String _gender = "";
  String _location = "";
  
  String _industry = "";
  String _jobType = "";
  String _company = "";
  
  String _introduction = "";
  String _portfolioUrl = "";

  @override
  void initState() {
    super.initState();
    _loadData(); // アプリ起動時にデータを読み込む
  }

  // --- データの読み込み ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('p_name') ?? "";
      _englishName = prefs.getString('p_englishName') ?? "";
      _affiliation = prefs.getString('p_affiliation') ?? "";
      _researchField = prefs.getString('p_researchField') ?? "";
      
      _birthDate = prefs.getString('p_birthDate') ?? "";
      _gender = prefs.getString('p_gender') ?? "";
      _location = prefs.getString('p_location') ?? "";
      
      _industry = prefs.getString('p_industry') ?? "";
      _jobType = prefs.getString('p_jobType') ?? "";
      _company = prefs.getString('p_company') ?? "";
      
      _introduction = prefs.getString('p_introduction') ?? "";
      _portfolioUrl = prefs.getString('p_portfolioUrl') ?? "";
    });
  }

  // --- データの保存 (共通関数) ---
  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    String display(String value) => value.isEmpty ? "(未入力)" : value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("プロフィール (Profile)"),
        backgroundColor: Colors.blue[50],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _name.isEmpty ? Colors.grey[300] : Colors.blueAccent,
                  child: Text(
                    _name.isEmpty ? "?" : _name.substring(0, 1),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showBasicInfoDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            Text(
              display(_name),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _name.isEmpty ? Colors.grey : Colors.black),
            ),
            Text(
              display(_englishName),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            
            Text(
              display(_affiliation),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "専門・研究: ${display(_researchField)}",
                style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 20),

            _buildEditableCard(
              title: "基本データ",
              icon: Icons.info,
              onEdit: () => _showPersonalDataDialog(),
              children: [
                _buildProfileItem(Icons.calendar_month, "生年月日", display(_birthDate)),
                const Divider(height: 1),
                _buildProfileItem(Icons.person, "性別", display(_gender)),
                const Divider(height: 1),
                _buildProfileItem(Icons.location_on, "居住地", display(_location)),
              ],
            ),

            _buildEditableCard(
              title: "就活ステータス",
              icon: Icons.work,
              onEdit: () => _showJobStatusDialog(),
              children: [
                _buildProfileItem(Icons.business, "志望業界", display(_industry)),
                const Divider(height: 1),
                _buildProfileItem(Icons.work_outline, "志望職種", display(_jobType)),
                const Divider(height: 1),
                _buildProfileItem(Icons.domain, "希望企業", display(_company)),
              ],
            ),

            _buildEditableCard(
              title: "自己紹介・趣味",
              icon: Icons.face,
              onEdit: () => _showIntroDialog(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    display(_introduction),
                    style: TextStyle(fontSize: 15, height: 1.5, color: _introduction.isEmpty ? Colors.grey : Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Card(
              color: Colors.blueGrey[50],
              child: ListTile(
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text("ポートフォリオURL"),
                subtitle: Text(display(_portfolioUrl)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showUrlDialog(),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: onEdit,
            ),
          ],
        ),
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String content) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }

  // --- ダイアログ (保存処理を追加) ---

  void _showBasicInfoDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final engCtrl = TextEditingController(text: _englishName);
    final affCtrl = TextEditingController(text: _affiliation);
    final resCtrl = TextEditingController(text: _researchField);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("基本情報の編集"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "名前 (漢字)")),
              TextField(controller: engCtrl, decoration: const InputDecoration(labelText: "名前 (英語)")),
              TextField(controller: affCtrl, decoration: const InputDecoration(labelText: "所属 (大学・学部)")),
              TextField(controller: resCtrl, decoration: const InputDecoration(labelText: "専門分野 (研究分野)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _name = nameCtrl.text;
                _englishName = engCtrl.text;
                _affiliation = affCtrl.text;
                _researchField = resCtrl.text;
              });
              // 個別に保存
              _saveString('p_name', _name);
              _saveString('p_englishName', _englishName);
              _saveString('p_affiliation', _affiliation);
              _saveString('p_researchField', _researchField);
              
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  void _showPersonalDataDialog() {
    final birthCtrl = TextEditingController(text: _birthDate);
    final genderCtrl = TextEditingController(text: _gender);
    final locCtrl = TextEditingController(text: _location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("基本データの編集"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: birthCtrl, decoration: const InputDecoration(labelText: "生年月日")),
            TextField(controller: genderCtrl, decoration: const InputDecoration(labelText: "性別")),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: "居住地")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _birthDate = birthCtrl.text;
                _gender = genderCtrl.text;
                _location = locCtrl.text;
              });
              _saveString('p_birthDate', _birthDate);
              _saveString('p_gender', _gender);
              _saveString('p_location', _location);
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  void _showJobStatusDialog() {
    final indCtrl = TextEditingController(text: _industry);
    final jobCtrl = TextEditingController(text: _jobType);
    final comCtrl = TextEditingController(text: _company);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("就活ステータスの編集"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: indCtrl, decoration: const InputDecoration(labelText: "志望業界")),
            TextField(controller: jobCtrl, decoration: const InputDecoration(labelText: "志望職種")),
            TextField(controller: comCtrl, decoration: const InputDecoration(labelText: "希望企業")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _industry = indCtrl.text;
                _jobType = jobCtrl.text;
                _company = comCtrl.text;
              });
              _saveString('p_industry', _industry);
              _saveString('p_jobType', _jobType);
              _saveString('p_company', _company);
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  void _showIntroDialog() {
    final introCtrl = TextEditingController(text: _introduction);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("自己紹介・趣味の編集"),
        content: TextField(
          controller: introCtrl,
          decoration: const InputDecoration(hintText: "自己紹介や趣味を入力"),
          maxLines: 5,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _introduction = introCtrl.text;
              });
              _saveString('p_introduction', _introduction);
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  void _showUrlDialog() {
    final urlCtrl = TextEditingController(text: _portfolioUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("URLの編集"),
        content: TextField(
          controller: urlCtrl,
          decoration: const InputDecoration(hintText: "https://..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _portfolioUrl = urlCtrl.text;
              });
              _saveString('p_portfolioUrl', _portfolioUrl);
              Navigator.pop(context);
            },
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }
}