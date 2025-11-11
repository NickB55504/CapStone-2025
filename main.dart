import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(GreenDotApp());

class GreenDotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Dot Solutions',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Sans Serif',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  @override
  _MainShellState createState() => _MainShellState();
}

class Database {
  static late MySQLConnection conn;

  static Future<void> databaseConnect() async {
    conn = await MySQLConnection.createConnection(
      host: 'Redacted',
      port: 25060,
      userName: 'Redacted',
      password: 'Redacted',
      databaseName: 'Redacted',
    );

    await conn.connect();
  }

  static Future<void> databaseDisconnect() async {
    conn.close();
  }

  static Future<Map<String, dynamic>?> getCustomerByEmail(String email) async {
    var result = await conn.execute(
      "SELECT * FROM Customers WHERE email = :email;",
      {'email': email},
    );

    if (result.rows.isEmpty) return null;
    return result.rows.first.assoc();
  }

  static Future<bool> checkPassword(String email, String password) async {
    var result = await conn.execute(
      "SELECT password FROM Customers WHERE email = :email;",
      {'email': email},
    );
    if (result.rows.isEmpty) {
      return false;
    }
    var customer = result.rows.first.assoc();
    var hashedPassword = customer['password'].toString();
    if (BCrypt.checkpw(password, hashedPassword)) {
      return true;
    }
    return false;
  }
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _loggedIn = false;
  String? _currentEmail = '';

  void _onNavTap(int idx) async {
    if (idx == 1) {
      await Database.databaseConnect();

      if (_loggedIn) {
        setState(() {
          _selectedIndex = idx;
        });
        return;
      }
      setState(() {
        _selectedIndex = idx;
      });
    } else {
      setState(() => _selectedIndex = idx);
    }
  }

  void _onDrawerNavigate(int idx) {
    Navigator.pop(context);
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      _loggedIn
          ? ProfilePage(currentEmail: _currentEmail!)
          : SignInPage(
              onSignInSuccess: (email) {
                setState(() {
                  _loggedIn = true;
                  _currentEmail = email;
                  _selectedIndex = 1;
                });
              },
            ),
      ContactPage(),
      FollowPage(),
      AboutPage(),
    ];

    return Scaffold(
      drawer: AppDrawer(onNavigate: _onDrawerNavigate),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navButton('Home', Icons.home, 0),
              Container(width: 2, color: Colors.black12),
              _navButton('Profile', Icons.person, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(String label, IconData icon, int idx) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: _selectedIndex == idx
              ? Colors.green.shade100
              : Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () => _onNavTap(idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: _selectedIndex == idx
                  ? Colors.green.shade800
                  : Colors.black54,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: _selectedIndex == idx
                    ? Colors.green.shade800
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  Future<void> _launchFlutter() async {
    Uri url = Uri.parse('https://greendotsolutions.org/getstarted/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          imagePath: 'assets/images/Green-dot-solutions_logo_70x70.png',
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Hero Image with center "Get Started" pill button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Replace AssetImage with a local asset added to pubspec.yaml
                    Container(
                      height: 420,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.asset(
                          'assets/images/trash_can.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _launchFlutter,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link),
                          SizedBox(width: 8),
                          Text('Get Started'),
                        ],
                      ),
                    ),
                  ],
                ),

                // Company blurb
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Why Choose Us?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Bin there, done that? You’re halfway to work when it hits you—you forgot to roll the cans out. Or worse, a holiday throws off the schedule and suddenly your trash is the only one left standing at the curb. One small slip-up and your whole week stinks (literally).',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Life’s already messy—why let trash day add to it? With our subscription service, you can relax while we handle the hassle. Rain, snow, or those last-minute dashes when you’ve forgotten—we’ll get your cans to the curb so you don’t have to.',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '*We like to keep things simple—our service area is flexible! If you’re not sure whether we serve your address, just send us a quick message and we’ll let you know.',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Select your plan, set your address and special instructions, then put your bin out on pickup day—we’ll take care of the rest.',
                        style: TextStyle(fontSize: 18, height: 1.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 90), // allow room above bottom nav
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? imagePath;

  const AppHeader({this.title, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(color: Colors.greenAccent.shade400),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: imagePath != null
                    ? Image.asset(
                        'assets/images/Green-dot-solutions_logo_70x70.png',
                        height: 96, // adjust as needed
                        fit: BoxFit.fitHeight,
                      )
                    : Text(
                        title ?? 'Green Dot Solutions',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Sans Serif',
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, size: 28),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(128);
}

class SignInPage extends StatefulWidget {
  final void Function(String email) onSignInSuccess;

  const SignInPage({required this.onSignInSuccess});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Database.databaseConnect();
      bool success = await Database.checkPassword(
        _emailCtrl.text,
        _passwordCtrl.text,
      );

      if (success) {
        // Tell parent that login succeeded
        widget.onSignInSuccess(_emailCtrl.text);
      } else {
        setState(() => _error = 'Invalid email or password');
      }
    } catch (e) {
      setState(() => _error = 'Database error');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'Sign In'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _handleSignIn,
              child: _loading ? CircularProgressIndicator() : Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String currentEmail;

  const ProfilePage({required this.currentEmail});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Create controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _specialCtrl = TextEditingController();

  bool _loading = true; // to show a loader while fetching
  Map<String, dynamic>? customer;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    // Fetch the customer record asynchronously
    final data = await Database.getCustomerByEmail(widget.currentEmail);

    if (mounted) {
      setState(() {
        customer = data;
        _loading = false;

        // Fill the controllers with database values (or defaults)
        _nameCtrl.text = data?['first_name'] ?? '';
        _emailCtrl.text = data?['email'] ?? '';
        _phoneCtrl.text = data?['phone_number'] ?? '';
        _addr1Ctrl.text = data?['street_address'] ?? '';
        _specialCtrl.text = data?['special_notes'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addr1Ctrl.dispose();
    _specialCtrl.dispose();
    super.dispose();
  }

  Widget labeledField(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AppHeader(
          imagePath: 'assets/images/Green-dot-solutions_logo_70x70.png',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Sans Serif',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ACCOUNT INFO
                labeledField(
                  'ACCOUNT INFO',
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Dylan Doe',
                            ),
                          ),
                          const Divider(),
                          TextField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'udkm57@gmail.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const Divider(),
                          TextField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '5551234567',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ADDRESS
                labeledField(
                  'ADDRESS',
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _addr1Ctrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ),

                // SUBSCRIPTION PLAN
                labeledField(
                  'SUBSCRIPTION PLAN',
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text(
                        'Basic Plan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Renews on July 15'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Upgrade',
                          style: TextStyle(color: Colors.green.shade900),
                        ),
                      ),
                    ),
                  ),
                ),

                // BILLING INFO
                labeledField(
                  'BILLING INFO',
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('VISA ending in 1234'),
                      trailing: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Billing History',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ),
                  ),
                ),

                // SPECIAL INSTRUCTIONS
                labeledField(
                  'SPECIAL INSTRUCTIONS',
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _specialCtrl,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'e.g. Leave by driveway',
                        ),
                        maxLines: 4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile saved')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontFamily: 'Sans Serif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppDrawer extends StatelessWidget {
  final void Function(int idx) onNavigate;

  const AppDrawer({required this.onNavigate});

  Widget tile(
    BuildContext c,
    IconData icon,
    String title,
    Widget page,
    int idx,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => onNavigate(idx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Text(
                'Green Dot Solutions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            Divider(),
            tile(context, Icons.phone, 'Contact Us', ContactPage(), 2),
            tile(context, Icons.share, 'Follow Us', FollowPage(), 3),
            tile(context, Icons.info, 'About Us', AboutPage(), 4),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('v1.0', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    await launchUrl(phoneUri);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: 'Contact Us'),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, color: Colors.green),
            Text(
              'Call Us',
              style: TextStyle(color: Colors.green, fontSize: 30),
            ),
          ],
        ),
        InkWell(
          onTap: () => _makePhoneCall('15732250881'),
          child: Text('+1 573 225 0881', style: const TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}

class FollowPage extends StatelessWidget {
  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch');
    }
  }

  Widget socialTile(String name, IconData icon, String url) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.green.shade700),
      title: Text(name),
      onTap: () => _launchUrl(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: 'Follow Us'),
        SizedBox(height: 18),
        Text(
          'Stay connected with Green Dot Solutions',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        socialTile(
          'Facebook',
          Icons.facebook,
          'https://www.facebook.com/greendotpaintco/',
        ),
        socialTile('Instagram', Icons.camera_alt, 'google.com'),
        socialTile('X / Twitter', Icons.chat_bubble, 'google.com'),
        socialTile('LinkedIn', Icons.business, 'google.com'),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: 'About Us'),
        Container(
          height: 180,
          width: double.infinity,
          child: Image.asset('assets/images/trash_can.jpg', fit: BoxFit.cover),
        ),
        SizedBox(height: 12),
        Text(
          'Our Mission',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            'To provide dependable, eco-friendly trash pickup that keeps our communities clean and green.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Why Choose Us?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Affordable Plans',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            Text(
              'Choose from a variety of subscription\n options that fit your budget and lifestyle.\n',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Customer Support',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            Text(
              'Our team is ready to assist you with\n any questions or special requests.\n',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Reliable Service',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            Text(
              'Count on us to be there, rain or shine.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
