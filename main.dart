import 'database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Initialize app runtime.
void main() => runApp(GreenDotApp());

// Construct app foundation.
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

// Initialize abstract app frame.
class MainShell extends StatefulWidget {
  @override
  _MainShellState createState() => _MainShellState();
}


// Implement abstract main shell.
class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _loggedIn = false;
  String? _currentEmail = '';

  // Logic for page switching.
  void _onNavTap(int idx) async {
    // if page id = 1 and the user is logged in,
    if (idx == 1) {
      await Database.databaseConnect();

      // point them to the profile page.
      if (_loggedIn) {
        setState(() {
          _selectedIndex = idx;
        });
        return;
      // Otherwise, point to sign in page.
      }
      setState(() {
        _selectedIndex = idx;
      });
    } else {
      // If the selected page isn't the profile or sign in,
      // point to the selected page.
      setState(() => _selectedIndex = idx);
    }
  }

  // Point to selected page in the hamburger menu
  void _onDrawerNavigate(int idx) {
    Navigator.pop(context);
    setState(() => _selectedIndex = idx);
  }

  @override
  // List of pages and their constructors.
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      _loggedIn
          ? ProfilePage(currentEmail: _currentEmail!, onNavTap: _onNavTap,)
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
      PasswordPage(currentEmail: _currentEmail!),
    ];

    // App scaffolding (persistent widgets/features)
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

  // Bottom navigation bar
  Widget _navButton(String label, IconData icon, int idx) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          // If the page is selected, the button will be green.
          // Otherwise, it will be white.
          backgroundColor: _selectedIndex == idx
              ? Colors.green.shade100
              : Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        // Calls page switch function.
        onPressed: () => _onNavTap(idx),
        child: Column(
          // The icon and button text changes colors as well, if selected or not
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

// Implement home page.
class HomePage extends StatelessWidget {
  // Define function to launch GDS website link.
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
          // Logo, added in assets folder.
          imagePath: 'assets/images/Green-dot-solutions_logo_70x70.png',
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image with center "Get Started" pill button.
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image for main page, added in assets folder.
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
                    // Button to open link
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

// Top of app's menu.
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
                // If the logo isn't provided, display title instead.
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
              // Hamburger menu button
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

// Define abstract sign in page.
class SignInPage extends StatefulWidget {
  final void Function(String email) onSignInSuccess;


  const SignInPage({required this.onSignInSuccess});

  @override
  _SignInPageState createState() => _SignInPageState();
}

// Implement sign in page.
class _SignInPageState extends State<SignInPage> {
  // Initialize text fields to enter customer credentials.
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Show loading screen if successful.
  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Attempt a connection.
    try {
      await Database.databaseConnect();
      bool success = await Database.checkPassword(
        _emailCtrl.text,
        _passwordCtrl.text,
      );

      if (success) {
        // Tell parent that login succeeded.
        widget.onSignInSuccess(_emailCtrl.text);
      } else {
        setState(() => _error = 'Invalid email or password');
      }
    // Error fetching customer data.
    } catch (e) {
      setState(() => _error = 'Database error');
    // If no errors, disable loading screen.
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
            // Construct text fields.
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
            // Confirm sign in button.
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

// Initialize abstract profile page.
class ProfilePage extends StatefulWidget {
  // Current email points to customer that is signed in.
  final String currentEmail;
  final void Function(int idx) onNavTap;

  const ProfilePage({required this.currentEmail, required this.onNavTap});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// Implement profile page.
class _ProfilePageState extends State<ProfilePage> {
  // Initialize database.
  final db = Database();
  // Create controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _trashdayCtrl = TextEditingController();
  final _trashtimeCtrl = TextEditingController();
  final _planCtrl = TextEditingController();

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
    final iv = data?['iv'] ?? '';

    if (mounted) {
      setState(() {
        customer = data;
        _loading = false;

        // Fill the controllers with database values (or defaults)
        _firstNameCtrl.text = customer?['first_name'] ?? '';
        _lastNameCtrl.text = customer?['last_name'] ?? '';
        _emailCtrl.text = customer?['email'] ?? '';
        _phoneCtrl.text = db.decrypt((customer?['phone_number'] ?? ''), iv);
        _addr1Ctrl.text = db.decrypt((customer?['street_address'] ?? ''), iv);
        _cityCtrl.text = db.decrypt((customer?['city'] ?? ''), iv);
        _stateCtrl.text = customer?['state'] ?? '';
        _zipCtrl.text = db.decrypt((customer?['zip_code'] ?? ''), iv);
        _trashdayCtrl.text = customer?['trash_day'] ?? '';
        _trashtimeCtrl.text = customer?['pickup_time'] ?? '';
        _planCtrl.text = customer?['subscription_plan'] ?? '';
      });
    }
  }

  // Close editors when finished.
  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addr1Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _trashdayCtrl.dispose();
    _trashtimeCtrl.dispose();
    _planCtrl.dispose();
    super.dispose();
  }

  // Constructor for profile sections.
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
    // Loading screen.
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Construct account sections.
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
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _firstNameCtrl,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'First',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _lastNameCtrl,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Last',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          TextField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'email@email.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const Divider(),
                          TextField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '8001234567',
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
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _addr1Ctrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Street',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _cityCtrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _stateCtrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _zipCtrl,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ),

                // ORDER INFO
                labeledField(
                  'ORDER INFO',
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
                            controller: _trashdayCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Day',
                            ),
                          ),
                          const Divider(),
                          TextField(
                            controller: _trashtimeCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '00:00:00',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const Divider(),
                          TextField(
                            controller: _planCtrl,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Plan',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Button points to change password page.
                ElevatedButton(onPressed: () => widget.onNavTap(5),
                  child: Text('Change Password'),
                ),
                Center(
                  // Save information button.
                  child: ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile saved')));
                        await db.updateCustomer(
                          oldEmail: widget.currentEmail,
                          firstName: _firstNameCtrl.text,
                          lastName: _lastNameCtrl.text,
                          email: _emailCtrl.text,
                          phone: _phoneCtrl.text,
                          street: _addr1Ctrl.text,
                          city: _cityCtrl.text,
                          state: _stateCtrl.text,
                          zip: _zipCtrl.text,
                          trashDay: _trashdayCtrl.text,
                          pickupTime: _trashtimeCtrl.text,
                          plan: _planCtrl.text,
                          iv: customer?['iv'] ?? '',
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

// Construct abstract Password page
class PasswordPage extends StatefulWidget {
  final String currentEmail;

  const PasswordPage({required this.currentEmail});

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

// Implementation of Password page
class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  // Change password page frame.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                    // Obscure the old password with *.
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrent = !_obscureCurrent;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                // Obscure the new password with *.
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  suffixIcon: IconButton(
                    // Obscure confirmation password
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  String salt = await Database.getSalt(widget.currentEmail);
                  await Database.changePassword(widget.currentEmail, _currentPasswordController.text, _newPasswordController.text, _confirmPasswordController.text, salt);
                },
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
    );
  }

  @override
  // Close text editors.
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Implement hamburger menu
class AppDrawer extends StatelessWidget {
  final void Function(int idx) onNavigate;

  const AppDrawer({required this.onNavigate});

  // Constructor to make page with tap function.
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
            // Construct each page.
            tile(context, Icons.phone, 'Contact Us', ContactPage(), 2),
            tile(context, Icons.share, 'Follow Us', FollowPage(), 3),
            tile(context, Icons.info, 'About Us', AboutPage(), 4),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
            ),
          ],
        ),
      ),
    );
  }
}

// Implement contact page.
class ContactPage extends StatelessWidget {
  // Call launcher library.
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
          // Call url launcher function.
          onTap: () => _makePhoneCall('15732250881'),
          child: Text('+1 573 225 0881', style: const TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}

// Implement follow page
class FollowPage extends StatelessWidget {
  // Call launcher library function.
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

// Implement about page.
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
