
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

import 'package:uuid/uuid.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentorMenteeConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StartUpPage(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewInsets: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
    );
  }
}
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}
class StartUpPage extends StatefulWidget {
  const StartUpPage({super.key});

  @override
  State<StartUpPage> createState() => _StartUpPageState();
}
class _StartUpPageState extends State<StartUpPage> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool loggedIn = prefs.getBool("loggedIn") ?? false;
    String? role = prefs.getString("role");
    String? expiryString = prefs.getString("sessionExpiry");

    // Check expiry
    if (expiryString != null) {
      DateTime expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        loggedIn = false;
      }
    }

    if (!loggedIn || role == null) {
      // USER IS LOGGED OUT
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
      return;
    }

    // USER IS LOGGED IN → CHECK ROLE
    if (role == "mentor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MentorHomePage()),
      );
    } else if (role == "mentee") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenteeHomePage()),
      );
    } else {
      // In case of unknown role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MentorMenteeConnect',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Smart mentorship platform\nStreamline meetings and communication',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),


                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        _buildFeatureCard(
                          title: 'Smart Scheduling',
                          subtitle: 'AI-powered meeting suggestions',
                          description: 'Find optimal times for mentor-mentee meetings',
                          icon: Icons.schedule_outlined,
                        ),

                        const SizedBox(height: 12),


                        _buildFeatureCard(
                          title: 'Anonymous Feedback',
                          subtitle: 'Safe communication channel',
                          description: 'Share concerns and suggestions privately',
                          icon: Icons.announcement_outlined,
                        ),

                        const SizedBox(height: 12),


                        _buildFeatureCard(
                          title: 'Shared Calendar',
                          subtitle: 'Coordinated scheduling',
                          description: 'View combined timetables and assessments',
                          icon: Icons.calendar_month_outlined,
                        ),

                        const SizedBox(height: 12),


                        _buildFeatureCard(
                          title: 'Topic Suggestions',
                          subtitle: 'Structured meeting agendas',
                          description: 'Collect and discuss relevant topics',
                          icon: Icons.lightbulb_outline,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),


                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_)=>SignUpPage()));},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667eea),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF667eea),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _signkeyController = TextEditingController();
  bool isError=true;
  String _selectedRole = 'mentee';
  @override
  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _studentNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signkeyController.dispose();
    super.dispose();
  }

  String _generateSignKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789qwertyuioplkjhgfdsazxcvbnm';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<String?> _findMentorBySignKey(String signkey) async {
    try {
      final mentorSnapshot = await FirebaseFirestore.instance
          .collection('signkeys')
          .where('signkey', isEqualTo: signkey)
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorSnapshot.docs.isNotEmpty) {
        return mentorSnapshot.docs.first.id;
      }
      return null;
    } catch (e) {

      return null;
    }
  }
  Future<void>addSignKey(String key)async {
    try {
      await FirebaseFirestore.instance.collection('signkeys').add(
          {
            'signkey': key,
            'role': 'mentor',
          }
      );
      print("Signkey added successfully!");
    } catch (e) {

      print("Error: failed to add key!$e");
    }
  }
  void createAccount() async {
    String fName = _nameController.text;
    String lName = _surnameController.text;
    String email = _studentNumberController.text + "@students.wits.ac.za";
    String password = _passwordController.text;
    String cpassword = _confirmPasswordController.text;
    String? imageUrl = "";

    if (password != cpassword) {
      _showToast("Passwords do not match", isError: true);
      return;
    }

    try {
      String? mentorId = await _findMentorBySignKey(_signkeyController.text);
      if (mentorId == null && _selectedRole == "mentee") {
        _showToast("Invalid signkey. Please check with your mentor.", isError: true);
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        'fName': fName,
        'uid': uid,
        'lName': lName,
        'role': _selectedRole,
        'studentNo': _studentNumberController.text,
        'email': email,
        'profile': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_selectedRole == 'mentor') {
        String signkey = _generateSignKey();
        userData['signkey'] = signkey;
        await addSignKey(signkey);
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
        _showMentorSignKeyDialog(signkey);
      } else {
        if (_signkeyController.text.isEmpty) {
          _showToast("Please enter your mentor's signkey", isError: true);
          return;
        }
        userData['mentor_id'] = mentorId;
        userData['signkey'] = _signkeyController.text;
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
      }

      await userCredential.user!.sendEmailVerification();
      await userCredential.user!.reload();
      _showToast("Account created! Check your email to verify your account.");
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showToast("Password is too weak.", isError: true);
      } else if (e.code == 'email-already-in-use') {
        _showToast("Student number already exists.", isError: true);
      } else {
        _showToast(e.message ?? "Unknown error occurred.", isError: true);
      }
    }
  }

  void _showMentorSignKeyDialog(String signkey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.vpn_key, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('Your Mentor Sign Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share this code with your mentees for them to sign up:',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF667eea)),
              ),
              child: Center(
                child: Text(
                  signkey,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Important: Save this code securely! You cannot change it later.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SignInPage()));
            },
            child: Text('Continue to Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Join MentorMenteeConnect as a mentor or mentee',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedRole = 'mentee';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _selectedRole == 'mentee'
                                                ? const Color(0xFF667eea)
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.school_outlined,
                                                color: _selectedRole == 'mentee'
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                size: 24,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Mentee',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedRole == 'mentee'
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedRole = 'mentor';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _selectedRole == 'mentor'
                                                ? const Color(0xFF667eea)
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.people_outline,
                                                color: _selectedRole == 'mentor'
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                size: 24,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Mentor',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _selectedRole == 'mentor'
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _surnameController,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _studentNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'Student Number',
                                    prefixIcon: Icon(Icons.numbers_outlined, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your student number';
                                    }
                                    return null;
                                  },
                                ),
                                if (_selectedRole == 'mentee') ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _signkeyController,
                                    decoration: InputDecoration(
                                      labelText: 'Mentor Sign Key *',
                                      prefixIcon: Icon(Icons.vpn_key, color: Colors.grey[600]),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      hintText: 'Enter 6-character code',
                                      helperText: 'Get this code from your assigned mentor',
                                    ),
                                    validator: (value) {
                                      if (_selectedRole == 'mentee' && (value == null || value.isEmpty)) {
                                        return 'Please enter your mentor sign key';
                                      }
                                      if (value != null && value.length != 6) {
                                        return 'Sign key must be exactly 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  createAccount();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667eea),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => SignInPage()));
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}
class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  void saveLoginSession(String uid, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("loggedIn", true);
    prefs.setString("uid", uid);
    prefs.setString("role", role);

  }


  Future<bool> getConfirm()async{
  User? user= FirebaseAuth.instance.currentUser;
      bool isConfirm=user?.emailVerified ??false;

   return isConfirm;

}


  Future<void>_resend()async{
    try {
      String email=_studentNumberController.text+"@students.wits.ac.za";
      String password=_passwordController.text;
      if(email.isEmpty || password.isEmpty){
        _showToast("All fields are required!",isError:true);
        return;
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = FirebaseAuth.instance.currentUser;
      user?.sendEmailVerification();
      _showToast("Verification email sent!",isError:false);
    }catch(e){
      _showToast("Failed to send verification email! $e",isError:true);
    }

  }
  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _login() async {
    String email = _studentNumberController.text.trim() + "@students.wits.ac.za";
    String password = _passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showToast("Login failed. Please try again.", isError: true);
        return;
      }

      if (!user.emailVerified) {
        _showToast("Please verify your email to log in.", isError: true);
        await FirebaseAuth.instance.signOut();
        return;
      }

      String? uid = user.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      _showToast("Login successful.");

      if (doc['role'] == 'mentee') {
        saveLoginSession(uid!, 'mentee');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MenteeHomePage()),
        );
      } else {
        saveLoginSession(uid!, 'mentor');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MentorHomePage()),
        );
      }



    } on FirebaseAuthException catch (e) {
      String message = "Login failed. Please try again.";

      switch (e.code) {
        case "invalid-email":
          message = "Invalid student number or email format.";
          break;

        case "user-not-found":
          message = "No user found with this student number.";
          break;

        case "wrong-password":
          message = "Incorrect password.";
          break;

        case "user-disabled":
          message = "Your account has been disabled. Contact support.";
          break;

        case "too-many-requests":
          message = "Too many attempts. Try again later or reset your password.";
          break;

        case "network-request-failed":
          message = "No internet connection. Please check your network.";
          break;

        default:
          message = "Error: ${e.message}";
      }

      _showToast(message, isError: true);

    } catch (e) {
      _showToast("Something went wrong. Please try again.:$e", isError: true);
    }
  }
  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
void _changePass()async{
    String email=_studentNumberController.text+"@students.wits.ac.za";
    if(!_studentNumberController.text.isEmpty){
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    _showToast(  "Recovery email sent."
        );}
    else{
      _showToast(  "Student number is required!.",isError:true
     );
    }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to your MentorMenteeConnect account',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 50),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _studentNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'Student Number',
                                    prefixIcon: Icon(Icons.numbers_outlined, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your student number';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      _changePass();

                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: const Color(0xFF667eea),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                      _login();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667eea),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_)=>SignUpPage()));
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: (){
                              _resend();

                            },
                            child:  Text("Resend verification email!",
                                style:TextStyle(
                                  color:Colors.white
                                )),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class MentorHomePage extends StatefulWidget {
  const MentorHomePage({super.key});

  @override
  State<MentorHomePage> createState() => _MentorHomePageState();
}
class _MentorHomePageState extends State<MentorHomePage> {
  int _currentIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late Timestamp todayTimestamp = Timestamp.fromDate(today);
  TextEditingController _announcementTitleController = TextEditingController();
  TextEditingController _announcementDescriptionController = TextEditingController();
  DateTime _announcementSelectedDate = DateTime.now();
  TimeOfDay _announcementSelectedTime = TimeOfDay.now();

  TextEditingController _meetingTitleController = TextEditingController();
  TextEditingController _meetingVenueController = TextEditingController();
  DateTime _meetingSelectedDate = DateTime.now();
  TimeOfDay _meetingSelectedTime = TimeOfDay.now();

  CollectionReference get announcementsRef => _firestore.collection('announcements');
  CollectionReference get meetingsRef => _firestore.collection('meetings');
  CollectionReference get quizzesRef => _firestore.collection('quizzes');

  String get currentUserId => _auth.currentUser?.uid ?? '';
Future <String> getKey(String uid)async {
  DocumentSnapshot doc= await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc['signkey'];
}
  Widget showDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 40, bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "MentorMenteeConnect",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildMenuItem(
            icon: Icons.person_outline,
            title: "My Profile",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            },
          ),
          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

          _buildMenuItem(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>MentorHelpSupportPage()));
            },
          ),

          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Add Content',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.announcement, color: Color(0xFF667eea)),
                        title: Text('Add Announcement'),
                        onTap: () {
                          Navigator.pop(context);
                          _showAddAnnouncementDialog();
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.quiz, color: Color(0xFF667eea)),
                        title: Text('Add Register'),
                        onTap: () {
                          Navigator.pop(context);
                          _showAddRegisterDialog();
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                        title: Text('Schedule Meeting'),
                        onTap: () {
                          Navigator.pop(context);
                          _showScheduleMeetingDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showScheduleMeetingDialog() {
    _meetingTitleController.clear();
    _meetingVenueController.clear();
    _meetingSelectedDate = DateTime.now();
    _meetingSelectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Schedule Meeting',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _meetingTitleController,
                              decoration: InputDecoration(
                                labelText: 'Meeting Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _meetingVenueController,
                              decoration: InputDecoration(
                                labelText: 'Venue',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                                    title: Text(
                                        '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year}'
                                    ),
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: _meetingSelectedDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setState(() => _meetingSelectedDate = picked);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.access_time, color: Color(0xFF667eea)),
                                    title: Text(_meetingSelectedTime.format(context)),
                                    onTap: () async {
                                      final TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: _meetingSelectedTime,
                                      );
                                      if (picked != null) {
                                        setState(() => _meetingSelectedTime = picked);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Color(0xFF667eea)),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Color(0xFF667eea)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_meetingTitleController.text.isEmpty ||
                                          _meetingVenueController.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Please fill all fields'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      try {

                                        final signkey = await getKey(currentUserId);
                                        final meetingDateTime = DateTime(
                                          _meetingSelectedDate.year,
                                          _meetingSelectedDate.month,
                                          _meetingSelectedDate.day,
                                          _meetingSelectedTime.hour,
                                          _meetingSelectedTime.minute,
                                        );
                                        final displayDate = '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year} • ${_meetingSelectedTime.format(context)}';
                                        final menteesSnapshot = await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('role', isEqualTo: 'mentee')
                                            .where('mentor_id', isEqualTo: currentUserId)
                                            .get();

                                        int totalMentees = menteesSnapshot.docs.length;
                                        await meetingsRef.add({
                                          'title': _meetingTitleController.text,
                                          'venue': _meetingVenueController.text,
                                          'date': '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year}',
                                          'time': _meetingSelectedTime.format(context),
                                          'dateTime': Timestamp.fromDate(meetingDateTime),
                                          'isoDateTime': meetingDateTime.toIso8601String(),
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'expiresAt': Timestamp.fromDate(meetingDateTime),
                                          'createdBy': currentUserId,
                                          'signkey': signkey,
                                          'mentorId': currentUserId,
                                          'attendedStudents': [],
                                          'totalMentees': totalMentees,
                                          'attendancePercentage': 0.0,
                                        });

                                        await announcementsRef.add({
                                          'title': _meetingTitleController.text,
                                          'date': displayDate,
                                          'type': 'meeting',
                                          'venue': _meetingVenueController.text,
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'expiresAt': Timestamp.fromDate(meetingDateTime),
                                          'createdBy': currentUserId,
                                          'signkey': signkey,
                                          'isoDate': meetingDateTime.toIso8601String(),
                                        });

                                        final event = {
                                          'title': _meetingTitleController.text,
                                          'description': "Meeting: ${_meetingVenueController.text}",
                                          'signkey': signkey,
                                          'dateTime': displayDate,
                                          'timestamp': Timestamp.fromDate(meetingDateTime),
                                          'isoDate': meetingDateTime.toIso8601String(),
                                          'uid': FirebaseAuth.instance.currentUser!.uid,
                                          'type': 'meeting',
                                          'reminderType': 'immediate',
                                          'expiresAt': Timestamp.fromDate(
                                            meetingDateTime.add(const Duration(hours: 1)),
                                          ),
                                          'venue': _meetingVenueController.text,
                                          'createdAt': FieldValue.serverTimestamp(),
                                        };

                                        await FirebaseFirestore.instance
                                            .collection('Events')
                                            .add(event);

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Meeting scheduled! Notification sent to all mentees.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error scheduling meeting: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF667eea),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text('Schedule Meeting'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddRegisterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Generate Register',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Color(0xFF667eea)),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF667eea)),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  final meetingSnapshot = await FirebaseFirestore.instance
                                      .collection('meetings')
                                      .where('mentorId', isEqualTo: currentUserId)
                                      .get();

                                  if (meetingSnapshot.docs.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('No meeting found'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final docs = List<QueryDocumentSnapshot>.from(meetingSnapshot.docs);
                                  docs.sort((a, b) {
                                    final aData = a.data() as Map<String, dynamic>;
                                    final bData = b.data() as Map<String, dynamic>;
                                    final aTs = aData['createdAt'] as Timestamp?;
                                    final bTs = bData['createdAt'] as Timestamp?;
                                    final aMillis = aTs?.millisecondsSinceEpoch ?? 0;
                                    final bMillis = bTs?.millisecondsSinceEpoch ?? 0;
                                    return bMillis.compareTo(aMillis);
                                  });

                                  final chosenDoc = docs.first;
                                  final meetingData = chosenDoc.data() as Map<String, dynamic>;
                                  final meetingId = chosenDoc.id;

                                  final date = meetingData['date'] ?? '';
                                  final title = meetingData['title'] ?? 'the meeting';
                                  final isoDate = meetingData['isoDateTime'] ?? DateTime.now().toIso8601String();

                                  final expiresAt = DateTime.now().add(Duration(hours: 24));
                                  final signKey = await getKey(currentUserId);

                                  await FirebaseFirestore.instance.collection('registers').add({
                                    'question': 'Did you attend "$title" on $date?',
                                    'options': ['Yes', 'No'],
                                    'title': title,
                                    'date': date,
                                    'isoDate': isoDate,
                                    'meetingId': meetingId,
                                    'signkey':signKey,
                                    'mentorId': currentUserId,
                                    'createdAt': FieldValue.serverTimestamp(),
                                    'expiresAt': Timestamp.fromDate(expiresAt),
                                    'attendedStudents': [],
                                    'attendancePercentage': 0,
                                  });
                                  final event = {
                                    'title': 'Register for $title',
                                    'description': 'Attendance register is available. Please mark your attendance within 24 hours.',
                                    'signkey': signKey,
                                    'dateTime': date,
                                    'timestamp': Timestamp.fromDate(DateTime.now()),
                                    'isoDate': DateTime.now().toIso8601String(),
                                    'uid': FirebaseAuth.instance.currentUser!.uid,
                                    'type': 'register',
                                    'reminderType': 'immediate',
                                    'expiresAt': Timestamp.fromDate(expiresAt),
                                    'createdAt': FieldValue.serverTimestamp(),
                                  };

                                  await FirebaseFirestore.instance
                                      .collection('Events')
                                      .add(event);

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Register generated! Notification sent to all mentees.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error generating register: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF667eea),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Generate Register'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddAnnouncementDialog() {
    _announcementTitleController.clear();
    _announcementDescriptionController.clear();
    _announcementSelectedDate = DateTime.now();
    _announcementSelectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Add Announcement',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _announcementTitleController,
                            decoration: InputDecoration(
                              labelText: 'Announcement Title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _announcementDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description (Optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                                  title: Text(
                                    '${_announcementSelectedDate.day}/${_announcementSelectedDate.month}/${_announcementSelectedDate.year}',
                                  ),
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: _announcementSelectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null && picked != _announcementSelectedDate) {
                                      setState(() {
                                        _announcementSelectedDate = picked;
                                      });
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.access_time, color: Color(0xFF667eea)),
                                  title: Text('${_announcementSelectedTime.format(context)}'),
                                  onTap: () async {
                                    final TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: _announcementSelectedTime,
                                    );
                                    if (picked != null && picked != _announcementSelectedTime) {
                                      setState(() {
                                        _announcementSelectedTime = picked;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Color(0xFF667eea)),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xFF667eea)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final signKey = await getKey(currentUserId);
                                    if (_announcementTitleController.text.isNotEmpty) {
                                      try {
                                        final dt=DateTime(
                                          _announcementSelectedDate.year,
                                          _announcementSelectedDate.month,
                                          _announcementSelectedDate.day,
                                          _announcementSelectedTime.hour,
                                          _announcementSelectedTime.minute);
                                        final announcementDateTime = DateTime(
                                          _announcementSelectedDate.year,
                                          _announcementSelectedDate.month,
                                          _announcementSelectedDate.day,
                                          _announcementSelectedTime.hour,
                                          _announcementSelectedTime.minute,
                                        );
                                        final displayDate = '${_announcementSelectedDate.day}/${_announcementSelectedDate.month}/${_announcementSelectedDate.year} • ${_announcementSelectedTime.format(context)}';
                                        final newAnnouncement = {
                                          'title': _announcementTitleController.text,
                                          'description': _announcementDescriptionController.text,
                                          'date': displayDate,
                                          'isoDate': announcementDateTime.toIso8601String(),
                                          'type': 'announcement',
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'expiresAt': Timestamp.fromDate(dt),
                                          'signkey': signKey,
                                          'createdBy': currentUserId,
                                        };
                                        await announcementsRef.add(newAnnouncement);
                                        final event = {
                                          'title': _announcementTitleController.text,
                                          'description': _announcementDescriptionController.text.isNotEmpty
                                              ? _announcementDescriptionController.text
                                              : 'New announcement',
                                          'signkey': signKey,
                                          'dateTime': displayDate,
                                          'timestamp': Timestamp.fromDate(announcementDateTime),
                                          'isoDate': announcementDateTime.toIso8601String(),
                                          'uid': FirebaseAuth.instance.currentUser!.uid,
                                          'expiresAt': Timestamp.fromDate(dt),
                                          'type': 'announcement',
                                          'reminderType': 'immediate',
                                          'createdAt': FieldValue.serverTimestamp(),
                                        };

                                        await FirebaseFirestore.instance
                                            .collection('Events')
                                            .add(event);

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Announcement created! Notification sent to all mentees.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error creating announcement: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Please enter a title'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF667eea),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.push(context, MaterialPageRoute(builder: (_)=>SignInPage()));

      },
              child: Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade700, size: 22),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
void _logout()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const SignInPage()),
  );
}

Future <String>getUsername()async{
  final uid=FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot doc=await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc['fName']+" " +doc['lName'];
}
  void _showAttendanceReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: meetingsRef
                        .where('createdBy', isEqualTo: currentUserId)
                        .orderBy('dateTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final meetings = snapshot.data!.docs;

                      if (meetings.isEmpty) {
                        return Center(child: Text('No meetings found'));
                      }

                      return FutureBuilder<int>(
                        future: _getTotalMenteesCount(),
                        builder: (context, menteeCountSnapshot) {
                          if (menteeCountSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (menteeCountSnapshot.hasError) {
                            return Center(child: Text('Error loading mentee count'));
                          }

                          final totalMentees = menteeCountSnapshot.data ?? 0;

                          return ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: meetings.length,
                            itemBuilder: (context, index) {
                              final meeting = meetings[index];
                              final data = meeting.data() as Map<String, dynamic>;

                              final attendedCount = (data['attendedStudents'] as List?)?.length ?? 0;
                              final percentage = totalMentees > 0
                                  ? (attendedCount / totalMentees * 100)
                                  : 0.0;

                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Icon(Icons.groups, color: Color(0xFF667eea)),
                                  title: Text(data['title'] ?? 'Meeting'),
                                  subtitle: Text('${data['date']} • ${data['time']}'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667eea),
                                        ),
                                      ),
                                      Text(
                                        '$attendedCount/$totalMentees',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _getTotalMenteesCount() async {
    try {
      final mentorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final mentorSignkey = mentorDoc['signkey'];
      final menteesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'mentee')
          .where('signkey', isEqualTo: mentorSignkey)
          .get();
      return menteesSnapshot.docs.length;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:showDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
          iconTheme: IconThemeData(
          color: Colors.white),
                title: Row(
                  children: [

                    SizedBox(width: 2),
                    FutureBuilder<String>(
                      future: getUsername(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox(
                            width: 80,
                            height: 20,
                            child: LinearProgressIndicator(color: Colors.white),
                          );
                        }

                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),

                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.auto_mode, color: Colors.white),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>SmartMeetingSchedulerPage()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.lightbulb_outline, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SuggestionsView()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: _showAddContentDialog,
                  ),

                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: _getCurrentPage(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Mentees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              label: 'Topic Aid',
            )
          ],
        ),
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return MenteesPage();
      case 2:
        return CalendarPage();
      case 3:
        return SuggestionsPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _getLatestMeetingWithAttendance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Error loading meeting data'),
                );
              }
              final meetingData = snapshot.data!;
              final hasMeetings = meetingData['hasMeetings'] ?? false;
              if (!hasMeetings) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Latest Meeting Attendance',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: _showAttendanceReport,
                            child: Text(
                              'View Report',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('No meetings scheduled yet'),
                    ],
                  ),
                );
              }
              final data = meetingData['meetingData'];
              final attendedCount = (data['attendedStudents'] as List?)?.length ?? 0;
              final totalMentees = meetingData['totalMentees'] ?? 0;
              final percentage = totalMentees > 0
                  ? (attendedCount / totalMentees * 100)
                  : 0.0;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Meeting Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: _showAttendanceReport,
                          child: Text(
                            'View Report',
                            style: TextStyle(
                              color: Color(0xFF667eea),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF667eea).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] ?? 'Meeting',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${data['date']} • ${data['time']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '$attendedCount/$totalMentees Mentees attended',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcements & Upcoming Meetings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  // Remove the where clause to get all announcements and meetings
                  stream: announcementsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading announcements');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final allItems = snapshot.data!.docs;
                    final now = DateTime.now();

                    final filteredItems = allItems.where((doc) {
                      final item = doc.data() as Map<String, dynamic>;

                      // Check if it's created by current user
                      if (item['createdBy'] != currentUserId) {
                        return false;
                      }

                      // Check if it's either announcement or meeting
                      final type = item['type'] as String?;
                      if (type != 'announcement' && type != 'meeting') {
                        return false;
                      }

                      final expiresAt = item['expiresAt'] as Timestamp?;
                      if (expiresAt == null) {
                        return false;
                      }

                      final expiresDateTime = expiresAt.toDate();
                      return expiresDateTime.isAfter(now);
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No upcoming announcements or meetings',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    filteredItems.sort((a, b) {
                      final aExpiresAt = (a.data() as Map<String, dynamic>)['expiresAt'] as Timestamp;
                      final bExpiresAt = (b.data() as Map<String, dynamic>)['expiresAt'] as Timestamp;
                      return aExpiresAt.compareTo(bExpiresAt);
                    });

                    final recentItems = filteredItems.take(5).toList();

                    return Column(
                      children: recentItems.map((doc) {
                        final item = doc.data() as Map<String, dynamic>;
                        final expiresAt = item['expiresAt'] as Timestamp;
                        final isMeeting = item['type'] == 'meeting';
                        final expiresDateTime = expiresAt.toDate();

                        String timeRemaining = '';
                        final difference = expiresDateTime.difference(now);

                        if (difference.inDays > 0) {
                          timeRemaining = '${difference.inDays}d remaining';
                        } else if (difference.inHours > 0) {
                          timeRemaining = '${difference.inHours}h remaining';
                        } else if (difference.inMinutes > 0) {
                          timeRemaining = '${difference.inMinutes}m remaining';
                        } else {
                          timeRemaining = 'Starting now';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isMeeting
                                        ? Color(0xFF667eea).withOpacity(0.1)
                                        : Color(0xFF48bb78).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isMeeting ? Icons.groups : Icons.announcement,
                                    color: isMeeting ? Color(0xFF667eea) : Color(0xFF48bb78),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        item['date'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        timeRemaining,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isMeeting ? Color(0xFF667eea) : Color(0xFF48bb78),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (item['venue'] != null) ...[
                                        SizedBox(height: 2),
                                        Text(
                                          'Venue: ${item['venue']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                      // Show time for meetings
                                      if (isMeeting && item['time'] != null) ...[
                                        SizedBox(height: 2),
                                        Text(
                                          'Time: ${item['time']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<Map<String, dynamic>> _getLatestMeetingWithAttendance() async {
    try {
      final meetingsSnapshot = await meetingsRef
          .where('createdBy', isEqualTo: currentUserId)
          .orderBy('dateTime', descending: true)
          .limit(1)
          .get();
      if (meetingsSnapshot.docs.isEmpty) {
        return {'hasMeetings': false};
      }
      final mentorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final mentorSignkey = mentorDoc['signkey'];
      final menteesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'mentee')
          .where('signkey', isEqualTo: mentorSignkey)
          .get();

      final totalMentees = menteesSnapshot.docs.length;

      final meeting = meetingsSnapshot.docs.first;
      final data = meeting.data() as Map<String, dynamic>;

      return {
        'hasMeetings': true,
        'meetingData': data,
        'totalMentees': totalMentees,
      };

    } catch (e) {
      print(e);
      return {'hasMeetings': false};

    }
  }
}
class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}
class _SuggestionsPageState extends State<SuggestionsPage> {
  final List<String> campusResources = [
    "SRC (Student Representative Council)",
    "CCDU (Counselling and Careers Development Unit)",
    "Centre for Student Development (CSD)",
    "DLU (Development and Leadership Unit)",
    "WCCO (Wits Citizenship and Community Outreach)",
    "SGO (Student Governance Office)",
    "STPU (Student Transitions and Persistence Unit)",
    "FYE (First Year Experience) Program",

    "Academic Development Unit (ADU)",
    "Writing Centre",
    "Maths & Science Learning Centre (MSLC)",
    "Library Learning & Research Services",
    "Faculty Academic Advisors",
    "Tutoring & Supplemental Instruction (SI) Programmes",
    "Examinations Office",

    "Financial Aid Office (NSFAS & Bursaries)",
    "Fees & Student Accounts Office",
    "Hardship & Emergency Funding",
    "Wits Food Programme / Wits Food Bank",
    "Residence Admissions Office",
    "Off-Campus Accommodation Office",

    "Campus Health & Wellness Centre (CHWC)",
    "Student Wellness Programme",
    "Peer Wellness Ambassadors",
    "Crisis Support & Referral Services",

    "Gender Equity Office (GEO)",
    "Disability Rights Unit (DRU)",
    "Transformation Office",
    "Sexual Harassment & Gender-Based Violence (GBV) Support Services",
    "LGBTIQ+ Support Services",
    "International Students Sub-Council (ISSC)",
    "Faith & Spiritual Life (Multi-Faith Services)",

    "Faculty Student Councils (FSCs)",
    "House Committees (Residence Leadership)",
    "Residence Life Programme",
    "Student Discipline Office",

    "Centre for Student Organisations (CSO Council)",
    "Academic & Faculty-Based Societies",
    "Cultural & Arts Societies",
    "Debating & Public Speaking Societies",
    "Community Engagement & Volunteering Societies",
    "Technology & Coding Societies",
    "Entrepreneurship Societies",

    "Wits Sports Council / Wits Sport",
    "Intramural Sports Programme",
    "Campus Gyms & Fitness Centres",

    "Wits Postgraduate Association (PGA)",
    "Peer Mentorship Programme",
    "Orientation & Transition Programmes",

    "Wits Vuvuzela (Student Newspaper)",
    "VOW FM / Wits Radio Academy",
    "Student Media Platforms",

    "Campus Protection Services",
    "Student Support Desk",
    "IT Helpdesk & eLearning Support"
  ];
  final List<String> suggestions = [];
  bool _isLoading = false;
  bool _showResults = false;
  TextEditingController _mentorPromptController = TextEditingController();
  List<dynamic> _aiSuggestions = [];
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;


  String buildGeminiPrompt() {
    return """
You are a mentorship expert at Wits University. Generate 1 COMPLETE TOPIC IDEA for mentors to use with their mentees.

IMPORTANT: You MUST return ONLY valid JSON. Do not include any explanations, introductions, or text outside the JSON structure.

CRITICAL REQUIREMENTS:
1. Generate EXACTLY 1 topic suggestion
2. The topic must include ALL these elements:
   - "topic": A clear, engaging title (4-8 words)
     Examples: "Effective Time Management for Academic Success", "Building Resilience in University Life", "Career Exploration and Goal Setting"
   
   - "description": A detailed paragraph (4-6 sentences) explaining what this topic covers, why it's important, and how it benefits students
   
   - "keyDiscussionPoints": 4-5 main areas to explore within this topic
   
   - "iceBreakers": 3 conversation starters related to this topic
   
   - "questionsForMentees": 5-6 specific questions mentors can ask their mentees
   
   - "takeawaysForMentees": 3-4 key learnings or actions mentees should gain
   
   - "campusResources": EXACTLY 2 specific institutional resources from the provided list
   
   - "externalResources": EXACTLY 1-2 quality external resources

3. Make description DETAILED and HELPFUL (4-6 sentences)

CRITICAL RESOURCE SELECTION RULES:
- Campus Resources: MUST select EXACTLY 2 from this list: ${campusResources.join(', ')}
- External Resources: Include 1-2 high-quality, credible, free resources

MENTEE CONTEXT TO CONSIDER:
- Current situation: ${_mentorPromptController.text}
- Previously discussed topics: ${suggestions.join(', ')}

OUTPUT FORMAT - THIS IS CRITICAL:
Return ONLY valid JSON with this exact structure:
{
  "suggestions": [
    {
      "topic": "Clear and Engaging Topic Title",
      "description": "A detailed 4-6 sentence explanation of what this topic covers. Explain why this topic is important for university students. Describe how discussing this topic can help mentees in their academic and personal development. Include specific benefits and outcomes students can expect from exploring this topic.",
      "keyDiscussionPoints": ["Comprehensive point 1", "Detailed point 2", "Specific point 3", "Practical point 4", "Additional point 5"],
      "iceBreakers": ["Engaging question 1 that relates to the topic", "Thought-provoking question 2", "Personal reflection question 3"],
      "questionsForMentees": ["Specific question 1", "Detailed question 2", "Reflective question 3", "Practical question 4", "Forward-looking question 5", "Action-oriented question 6"],
      "takeawaysForMentees": ["Clear learning outcome 1", "Practical skill 2", "Actionable insight 3", "Resource awareness 4"],
      "campusResources": ["Specific Resource 1 from list", "Specific Resource 2 from list"],
      "externalResources": ["Useful external resource 1", "Additional tool or website 2"]
    }
  ]
}

IMPORTANT: Generate EXACTLY 1 topic suggestion. Return a JSON array with exactly one object in the "suggestions" array.
""";
  }

  Future<void> loadSuggestions() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('suggestions').get();
      suggestions.clear();
      for (var doc in querySnapshot.docs) {
        if (doc['suggestion'] != null) {
          suggestions.add(doc['suggestion'].toString());
        }
      }
    } catch (e) {
     print("Error loading suggestions: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    await loadSuggestions();
    setState(() {
      _isInitialized = true;
    });
  }
  Future<void> _generateAISuggestions() async {
    if (_mentorPromptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please describe the mentee\'s situation first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = false;
    });

    try {
      final String prompt = buildGeminiPrompt();
      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('generateTopicSuggestions');

      final result = await callable.call({
        'prompt': prompt,
        'campusResources': campusResources,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        List<dynamic> suggestions = data['suggestions'] ?? [];


        setState(() {
          _aiSuggestions = suggestions;
          _isLoading = false;
          _showResults = true;
        });
      } else {
        setState(() {
          _aiSuggestions = [_createDefaultTopic(1)];
          _isLoading = false;
          _showResults = true;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Failed to generate suggestions';
      if (e is FirebaseFunctionsException) {
        errorMessage = 'Server error: ${e.message}';
      } else if (e is PlatformException) {
        errorMessage = 'Network error: ${e.message}';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );

      setState(() {
        _aiSuggestions = [_createDefaultTopic(1)];
        _showResults = true;
      });
    }
  }

  Map<String, dynamic> _createDefaultTopic(int number) {
    return {
      "topic": "Academic Success Strategy $number",
      "description": "This comprehensive topic helps students develop effective strategies for academic achievement in university. We explore various study techniques, time management approaches, and resource utilization methods that can significantly improve academic performance. Students will learn how to create personalized study plans, manage their coursework effectively, and leverage campus resources to enhance their learning experience. The discussion focuses on practical, actionable strategies that can be implemented immediately to improve grades and reduce academic stress.",
      "keyDiscussionPoints": [
        "Effective study habits and learning techniques",
        "Time management and prioritization strategies",
        "Utilizing academic support services effectively",
        "Balancing academic workload with personal life",
        "Exam preparation and stress management techniques"
      ],
      "iceBreakers": [
        "What study methods have worked best for you so far?",
        "How do you currently organize your study schedule?",
        "What academic achievement are you most proud of?"
      ],
      "questionsForMentees": [
        "What specific academic goals do you have for this semester?",
        "How do you currently prepare for exams and assignments?",
        "What times of day are you most productive for studying?",
        "How do you handle difficult or challenging course material?",
        "What academic support resources have you used before?",
        "How do you balance your academic work with other responsibilities?"
      ],
      "takeawaysForMentees": [
        "A personalized study plan for current courses",
        "Practical time management strategies for academic success",
        "Knowledge of available campus academic support resources",
        "Tools for tracking and improving academic performance"
      ],
      "campusResources": [
        "Centre for Student Development (CSD)",
        "CCDU (Counselling and Careers Development Unit)"
      ],
      "externalResources": ["Khan Academy for supplementary learning", "Pomodoro Technique timer apps"]
    };
  }


  void _retryWithNewContext() {
    setState(() {
      _showResults = false;
      _mentorPromptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (!_showResults) _buildInputSection(),
              Expanded(
                child: _buildContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Topic Suggestions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_showResults && !_isLoading)
                  IconButton(
                    onPressed: _retryWithNewContext,
                    icon: Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'New Search',
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              _showResults
                  ? '${_aiSuggestions.length} complete topic ideas for your mentorship sessions'
                  : 'Generate topic ideas for your mentees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        )
        );
    }

  Widget _buildInputSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Color(0xFF667eea), size: 20),
              SizedBox(width: 8),
              Text(
                'Mentee Context & Situation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: _mentorPromptController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe your mentee\'s current challenges, interests, or goals...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF667eea)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              helperText: 'What specific areas would benefit your mentee right now?',
              helperStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateAISuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Generate Topic Ideas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          if (_showResults || _isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF667eea), size: 24),
                  SizedBox(width: 8),
                  Text(
                    _isLoading ? 'Creating Topic Ideas...' : 'Your Topic Ideas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  if (_showResults && !_isLoading)
                    Text(
                      '${_aiSuggestions.length} topics',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            SizedBox(height: 16),
            Text(
              'Creating topic ideas...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (!_showResults) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 80, color: Colors.grey[300]),
              SizedBox(height: 20),
              Text(
                'Ready to Generate Topic Ideas',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Describe your mentee\'s situation to get complete topic ideas with discussion points, questions, and resources',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF667eea).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF667eea)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Based on: ${_mentorPromptController.text}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ..._aiSuggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return _buildTopicCard(suggestion, index);
            }).toList(),

            SizedBox(height: 20),
            if (_showResults)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton.icon(
                  onPressed: _retryWithNewContext,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Generate New Topics'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF667eea),
                    side: BorderSide(color: Color(0xFF667eea)),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> suggestion, int index) {
    Map<String, dynamic> safeSuggestion = Map<String, dynamic>.from(suggestion);
    safeSuggestion['topic'] ??= 'Topic ${index + 1}';
    safeSuggestion['description'] ??= 'A comprehensive discussion topic for mentorship sessions that helps students navigate university challenges and develop essential skills for academic and personal success.';
    safeSuggestion['keyDiscussionPoints'] ??= ['Discussion area 1', 'Discussion area 2', 'Discussion area 3'];
    safeSuggestion['iceBreakers'] ??= ['Ice breaker 1', 'Ice breaker 2', 'Ice breaker 3'];
    safeSuggestion['questionsForMentees'] ??= ['Question 1', 'Question 2', 'Question 3', 'Question 4'];
    safeSuggestion['takeawaysForMentees'] ??= ['Takeaway 1', 'Takeaway 2', 'Takeaway 3'];
    safeSuggestion['campusResources'] ??= ['Campus resource 1', 'Campus resource 2'];
    safeSuggestion['externalResources'] ??= ['External resource'];

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOPIC ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  safeSuggestion['topic']!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF667eea).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, size: 18, color: Color(0xFF667eea)),
                          SizedBox(width: 8),
                          Text(
                            'Topic Overview',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        safeSuggestion['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
                _buildSection(
                  title: 'Key Discussion Points',
                  items: List<String>.from(safeSuggestion['keyDiscussionPoints']!),
                  icon: Icons.list,
                  color: Color(0xFF764ba2),
                  isNumbered: true,
                ),

                SizedBox(height: 16),

                // Ice Breakers
                _buildSection(
                  title: 'Ice Breakers',
                  items: List<String>.from(safeSuggestion['iceBreakers']!),
                  icon: Icons.chat_bubble_outline,
                  color: Colors.blue,
                ),

                SizedBox(height: 16),

                // Questions for Mentees
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.question_answer, size: 18, color: Colors.green[700]),
                          SizedBox(width: 8),
                          Text(
                            'Questions for Your Mentee',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ...List<String>.from(safeSuggestion['questionsForMentees']!).asMap().entries.map((entry) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Takeaways for Mentees
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange[700]),
                          SizedBox(width: 8),
                          Text(
                            'Key Takeaways for Mentee',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ...List<String>.from(safeSuggestion['takeawaysForMentees']!).map((takeaway) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                takeaway,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Campus Resources
                _buildSection(
                  title: 'Campus Resources to Explore',
                  items: List<String>.from(safeSuggestion['campusResources']!),
                  icon: Icons.school,
                  color: Colors.purple,
                  showIcon: Icons.verified,
                ),

                SizedBox(height: 16),

                // External Resources
                _buildSection(
                  title: 'External Resources & Tools',
                  items: List<String>.from(safeSuggestion['externalResources']!),
                  icon: Icons.public,
                  color: Colors.blue,
                  showIcon: Icons.link,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
    bool isNumbered = false,
    IconData? showIcon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...items.asMap().entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNumbered)
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  )
                else if (showIcon != null)
                  Icon(showIcon, size: 16, color: color)
                else
                  Icon(Icons.chevron_right, size: 16, color: color),

                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mentorPromptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}
class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEventsFromFirebase();
    _loadEventsFromFirebase2();

  }




  void _showAddEventDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Add Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Event Title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                                  title: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2025),
                                    );
                                    if (picked != null && picked != selectedDate) {
                                      setState(() {
                                        selectedDate = picked;
                                      });
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.access_time, color: Color(0xFF667eea)),
                                  title: Text(selectedTime != null ? selectedTime!.format(context) : 'Add Time (Optional)'),
                                  onTap: () async {
                                    final TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        selectedTime = picked;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Color(0xFF667eea)),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xFF667eea)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (titleController.text.isNotEmpty) {
                                      _addEvent(
                                        selectedDate,
                                        titleController.text,
                                        descriptionController.text,
                                        selectedTime,
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF667eea),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Add Event'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> getKey(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['signkey'];
  }
  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
Future<String>getEmail ()async{

      final id = await FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection(
          'users').doc(id).get();
      return doc['email'];

}
  void _addEvent(DateTime date, String title, String description, TimeOfDay? time) async {
    DateTime finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );


    String? uid = await FirebaseAuth.instance.currentUser?.uid;
    final signKey = await getKey(uid!);
    final email=await getEmail();
    String formattedDateTime = '${date.day}/${date.month}/${date.year} • ${time != null ? time.format(context) : 'All Day'}';
    final event = {
      'title': title,
      'description': description,
      'signkey': signKey,
      'dateTime': formattedDateTime,
      'timestamp': Timestamp.fromDate(finalDateTime),
      'isoDate': finalDateTime.toIso8601String(),
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'calendar_event',
    };

    try {
      //specific email to be sent not to everyone
      // await FirebaseFirestore.instance
      //     .collection('Events')
      //     .add(event);
      await FirebaseFirestore.instance
          .collection('events')
          .add({
        'title': title,
        'description': description,
        'signkey': signKey,
        'studentEmail':email,
        'dateTime': Timestamp.fromDate(finalDateTime),
        'isoDate': finalDateTime.toIso8601String(),
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showToast( "Event added successfully"
      );

    } catch (e) {
      _showToast( "Failed to add event: $e",isError:true
      );
    }
  }

  void _showEventDetails(DateTime date, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Event Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      if (event['dateTime'] != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Color(0xFF667eea)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event['dateTime'] is String
                                      ? event['dateTime']
                                      : _formatTimestamp(event['dateTime']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event['description'] != null && event['description'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              event['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF667eea),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return timestamp.toString();
    } catch (e) {
      return 'Date not available';
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  void _loadEventsFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final signKey = await getKey(uid);

    FirebaseFirestore.instance
        .collection('events')
        .where('uid', isEqualTo: uid)
        .where('signkey', isEqualTo: signKey)
        .snapshots()
        .listen((snapshot) {
      _updateEvents(snapshot.docs);
    });
  }

  void _loadEventsFromFirebase2() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final signKey = await getKey(uid);

    FirebaseFirestore.instance
        .collection('Events')
        .where('signkey', isEqualTo: signKey)
        .snapshots()
        .listen((snapshot) {
      _updateEvents(snapshot.docs);
    });
  }

  void _updateEvents(List<QueryDocumentSnapshot> docs) {
    Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime? eventDate;
      if (data['isoDate'] != null) {
        try {
          eventDate = DateTime.parse(data['isoDate']);
        } catch (e) {

        }
      }
      if (eventDate == null && data['timestamp'] is Timestamp) {
        eventDate = (data['timestamp'] as Timestamp).toDate();
      }
      if (eventDate == null && data['dateTime'] is Timestamp) {
        eventDate = (data['dateTime'] as Timestamp).toDate();
      }
      if (eventDate == null && data['dateTime'] is String) {
        eventDate = _parseDateString(data['dateTime']);
      }

      if (eventDate != null) {
        DateTime dayOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (newEvents[dayOnly] == null) {
          newEvents[dayOnly] = [data];
        } else {
          final existingEvent = newEvents[dayOnly]!.firstWhere(
                (e) => e['title'] == data['title'] &&
                _getEventDate(e) == _getEventDate(data),
            orElse: () => {},
          );

          if (existingEvent.isEmpty) {
            newEvents[dayOnly]!.add(data);
          }
        }
      }
    }

    setState(() {
      _events = newEvents;
    });
  }

  DateTime? _getEventDate(Map<String, dynamic> event) {
    if (event['isoDate'] != null) {
      try {
        return DateTime.parse(event['isoDate']);
      } catch (e) {

      }
    }

    if (event['timestamp'] is Timestamp) {
      return (event['timestamp'] as Timestamp).toDate();
    }

    if (event['dateTime'] is Timestamp) {
      return (event['dateTime'] as Timestamp).toDate();
    }

    if (event['dateTime'] is String) {
      return _parseDateString(event['dateTime']);
    }

    return null;
  }

  DateTime _parseDateString(String dateString) {
    try {
      if (dateString.contains('•')) {
        final parts = dateString.split('•');
        final datePart = parts[0].trim();
        final dateParts = datePart.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        if (parts.length > 1) {
          final timePart = parts[1].trim();
          final time = _parseTimeString(timePart);
          return DateTime(year, month, day, time.hour, time.minute);
        }

        return DateTime(year, month, day);
      }

      else if (dateString.contains('/')) {
        final dateParts = dateString.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        return DateTime(year, month, day);
      }
      else {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      timeString = timeString.trim().toUpperCase();

      if (timeString.contains('AM') || timeString.contains('PM')) {
        final isPM = timeString.contains('PM');
        final timePart = timeString.replaceAll(RegExp(r'[APM\s]'), '');
        final parts = timePart.split(':');
        var hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        if (isPM && hour < 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      } else {
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Smart Calendar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now().subtract(Duration(days: 365)),
                          lastDay: DateTime.now().add(Duration(days: 365)),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          eventLoader: _getEventsForDay,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Color(0xFF667eea).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Color(0xFF667eea),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Color(0xFF764ba2),
                              shape: BoxShape.circle,
                            ),
                            outsideDaysVisible: false,
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                            formatButtonDecoration: BoxDecoration(
                              color: Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            formatButtonTextStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_selectedDay != null)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _showAddEventDialog,
                                    icon: Icon(Icons.add, size: 18),
                                    label: Text('Add Event'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF667eea),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _getEventsForDay(_selectedDay!).isEmpty
                                  ? Container(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                                    SizedBox(height: 8),
                                    Text(
                                      'No events for this day',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Column(
                                children: _getEventsForDay(_selectedDay!).map((event) {
                                  final dateTime = event['dateTime'];
                                  final displayTime = dateTime is String
                                      ? dateTime
                                      : _formatTimestamp(dateTime);

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(Icons.event, color: Color(0xFF667eea)),
                                      title: Text(event['title']),
                                      subtitle: Text(displayTime),
                                      onTap: () => _showEventDetails(_selectedDay!, event),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MenteesPage extends StatefulWidget {
  const MenteesPage({super.key});

  @override
  State<MenteesPage> createState() => _MenteesPageState();
}
class _MenteesPageState extends State<MenteesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get usersRef => _firestore.collection('users');
  CollectionReference get meetingsRef => _firestore.collection('meetings');

  String get currentUserId => _auth.currentUser?.uid ?? '';

  List<Map<String, dynamic>> _menteesWithAttendance = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, String> _menteeProfileImages = {};
  @override
  void initState() {
    super.initState();
    _loadMenteesWithAttendance();
  }
  Future<String> getUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid!).get();
    return doc['fName'] + " " + doc['lName'];
  }
  Widget _buildProfileAvatar(String menteeId, {double radius = 25}) {
    final profileUrl = _menteeProfileImages[menteeId] ?? '';
    if (profileUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(profileUrl),
        onBackgroundImageError: (exception, stackTrace) {
        },
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Color(0xFF667eea).withOpacity(0.1),
        child: Icon(
          Icons.person,
          color: Color(0xFF667eea),
          size: radius,
        ),
      );
    }
  }

  Future<void> _loadMenteesWithAttendance() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final currentUserDoc = await usersRef.doc(currentUserId).get();
      final signkey = currentUserDoc['signkey'];
      final menteesSnapshot = await usersRef
          .where('role', isEqualTo: 'mentee')
          .where('signkey', isEqualTo: signkey)
          .get();
      List<Map<String, dynamic>> menteesData = [];
      Map<String, String> profileImages = {};

      for (var menteeDoc in menteesSnapshot.docs) {
        final mentee = menteeDoc.data() as Map<String, dynamic>;
        final menteeId = menteeDoc.id;
        profileImages[menteeId] = mentee['profile'] ?? '';
        final meetingsSnapshot = await meetingsRef
            .where('signkey', isEqualTo: signkey)
            .get();

        final attendanceData = await _calculateMenteeAttendance(
            menteeId,
            meetingsSnapshot.docs
        );

        menteesData.add({
          'id': menteeId,
          'name': mentee['fName'] ?? '',
          'surname': mentee['lName'] ?? '',
          'studentNumber': mentee['studentNo'] ?? '',
          'email': mentee['email'] ?? '',
          'profileImage': mentee['profile'] ?? '',
          ...attendanceData,
        });
      }

      setState(() {
        _menteesWithAttendance = menteesData;
        _menteeProfileImages = profileImages;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading mentees: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _calculateMenteeAttendance(
      String menteeId, List<QueryDocumentSnapshot> meetings) async {

    List<Map<String, dynamic>> meetingHistory = [];
    int attendedCount = 0;
    int totalMeetings = meetings.length;

    for (var meetingDoc in meetings) {
      final meeting = meetingDoc.data() as Map<String, dynamic>;
      final attendedStudents = List.from(meeting['attendedStudents'] ?? []);
      final attended = attendedStudents.contains(menteeId);

      if (attended) attendedCount++;

      meetingHistory.add({
        'date': meeting['date'] ?? 'Unknown Date',
        'time': meeting['time'] ?? 'Unknown Time',
        'attended': attended,
        'meetingTitle': meeting['title'] ?? 'Weekly Meeting',
        'venue': meeting['venue'] ?? '',
      });
    }
    meetingHistory.sort((a, b) => b['date'].compareTo(a['date']));

    final attendancePercentage = totalMeetings > 0
        ? ((attendedCount / totalMeetings) * 100).round()
        : 0;

    return {
      'attendance': attendancePercentage,
      'totalMeetings': totalMeetings,
      'attendedMeetings': attendedCount,
      'meetings': meetingHistory,
    };
  }

  void _showMenteeReport(Map<String, dynamic> mentee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${mentee['name']} ${mentee['surname']} - Attendance Report',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Color(0xFF667eea),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: 'Overview'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildProfileAvatar(mentee['id'], radius: 30),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${mentee['name']} ${mentee['surname']}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Student No: ${mentee['studentNumber']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                if (mentee['email'] != null && mentee['email'].isNotEmpty)
                                                  Text(
                                                    'Email: ${mentee['email']}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                '${mentee['attendance']}%',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF667eea),
                                                ),
                                              ),
                                              Text(
                                                'Attendance',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${mentee['attendedMeetings']}/${mentee['totalMeetings']}',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF667eea),
                                                ),
                                              ),
                                              Text(
                                                'Meetings Attended',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 20),
                                    Text(
                                      'Meeting History',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 16),

                                    if (mentee['meetings'].isEmpty)
                                      Text(
                                        'No meetings found',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 16,
                                        ),
                                      )
                                    else
                                      ...mentee['meetings'].map((meeting) => Card(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: meeting['attended']
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.red.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              meeting['attended'] ? Icons.check : Icons.close,
                                              color: meeting['attended'] ? Colors.green : Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(meeting['meetingTitle']),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${meeting['date']} • ${meeting['time']}'),
                                              if (meeting['venue'] != null && meeting['venue'].isNotEmpty)
                                                Text('Venue: ${meeting['venue']}'),
                                            ],
                                          ),
                                          trailing: Text(
                                            meeting['attended'] ? 'Present' : 'Absent',
                                            style: TextStyle(
                                              color: meeting['attended'] ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'My Mentees',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading mentees...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : _errorMessage.isNotEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMenteesWithAttendance,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
                    : _menteesWithAttendance.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No mentees assigned yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mentees will appear here once they sign up\nusing your sign key',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Color(0xFF667eea), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap on any mentee to view their attendance report and mark attendance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ..._menteesWithAttendance.map((mentee) => Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: _buildProfileAvatar(mentee['id'], radius: 25),
                          title: Text(
                            '${mentee['name']} ${mentee['surname']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student No: ${mentee['studentNumber']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getAttendanceColor(mentee['attendance']),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${mentee['attendance']}% Attendance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                          onTap: () => _showMenteeReport(mentee),
                        ),
                      )).toList(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceColor(int attendance) {
    if (attendance >= 90) return Colors.green;
    if (attendance >= 80) return Colors.orange;
    return Colors.red;
  }
}
class MenteeHomePage extends StatefulWidget {
  const MenteeHomePage({super.key});

  @override
  State<MenteeHomePage> createState() => _MenteeHomePageState();
}
class _MenteeHomePageState extends State<MenteeHomePage> {
  int _currentIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _menteeSignKey = '';
  String _mentorId = '';

  @override
  void initState() {
    super.initState();
    _loadMenteeData();
  }

  Future<void> _loadMenteeData() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _menteeSignKey = userData['signkey'] ?? '';
          _mentorId = userData['mentor_id'] ?? '';
        });
      }
    } catch (e) {

    }
  }
  CollectionReference get announcementsRef => _firestore.collection('announcements');
  CollectionReference get meetingsRef => _firestore.collection('meetings');
  CollectionReference get registersRef => _firestore.collection('registers');

  Future<String> getUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['fName'] + " " + doc['lName'];
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [

                SizedBox(width: 2),
                FutureBuilder<String>(
                  future: getUsername(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                        width: 80,
                        height: 20,
                        child: LinearProgressIndicator(color: Colors.white),
                      );
                    }
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: _getCurrentPage(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Register',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              label: 'Suggest',
            ),
          ],
        ),
      ),
    );
  }
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildRegistersContent();
      case 2:
        return CalendarPage();
      case 3:
        return SuggestTopicsPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget showDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 40, bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "MentorMenteeConnect",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [

                  SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mentor Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Mentor",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                   child: Icon(Icons.chevron_right, color: Colors.grey.shade500),
                    onTap: (){
                     Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewMentorPage()));
                    },

                  ),

                ],
              ),
            ),
          ),

          _buildMenuItem(
            icon: Icons.person_outline,
            title: "My Profile",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
            },
          ),
          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

          _buildMenuItem(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>MenteeHelpSupportPage()));
            },
          ),
          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade700, size: 22),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
  void _logout()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage() ),
    );
  }
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.push(context, MaterialPageRoute(builder: (_)=>SignInPage()));
              },
              child: Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today, color: Color(0xFF667eea)),
                    SizedBox(width: 8),
                    Text(
                      'Today\'s Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Active\nRegisters', 'Check', Icons.assignment),
                    _buildStatCard('Upcoming\nMeetings', 'View', Icons.event),
                    _buildStatCard('Latest\nNews', 'See', Icons.announcement),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.announcement, color: Color(0xFF667eea)),
                    SizedBox(width: 8),
                    Text(
                      'Upcoming Announcements & Meetings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: announcementsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading data');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final allItems = snapshot.data!.docs;
                    final now = DateTime.now();

                    final filteredItems = allItems.where((doc) {
                      final item = doc.data() as Map<String, dynamic>;

                      // Filter by signkey (mentee-specific)
                      if (item['signkey'] != _menteeSignKey) {
                        return false;
                      }

                      // Check if it's either announcement or meeting
                      final type = item['type'] as String?;
                      if (type != 'announcement' && type != 'meeting') {
                        return false;
                      }

                      final expiresAt = item['expiresAt'] as Timestamp?;
                      if (expiresAt == null) {
                        return false;
                      }

                      final expiresDateTime = expiresAt.toDate();
                      return expiresDateTime.isAfter(now);
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No upcoming announcements or meetings',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    filteredItems.sort((a, b) {
                      final aExpiresAt = (a.data() as Map<String, dynamic>)['expiresAt'] as Timestamp;
                      final bExpiresAt = (b.data() as Map<String, dynamic>)['expiresAt'] as Timestamp;
                      return aExpiresAt.compareTo(bExpiresAt);
                    });

                    final upcomingItems = filteredItems.take(5).toList();

                    return Column(
                      children: upcomingItems.map((doc) {
                        final item = doc.data() as Map<String, dynamic>;
                        final expiresAt = item['expiresAt'] as Timestamp;
                        final isMeeting = item['type'] == 'meeting';
                        final expiresDateTime = expiresAt.toDate();

                        String timeRemaining = '';
                        final difference = expiresDateTime.difference(now);

                        if (difference.inDays > 0) {
                          timeRemaining = '${difference.inDays}d ${difference.inHours % 24}h remaining';
                        } else if (difference.inHours > 0) {
                          timeRemaining = '${difference.inHours}h ${difference.inMinutes % 60}m remaining';
                        } else if (difference.inMinutes > 0) {
                          timeRemaining = '${difference.inMinutes}m remaining';
                        } else {
                          timeRemaining = 'Starting now';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isMeeting
                                            ? Color(0xFF667eea).withOpacity(0.1)
                                            : Color(0xFF48bb78).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isMeeting ? Icons.groups : Icons.announcement,
                                        color: isMeeting ? Color(0xFF667eea) : Color(0xFF48bb78),
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? 'No Title',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          if (item['date'] != null)
                                            Text(
                                              item['date'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          Text(
                                            timeRemaining,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isMeeting ? Color(0xFF667eea) : Color(0xFF48bb78),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    item['description'].toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                                if (item['venue'] != null && item['venue'].toString().isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Venue: ${item['venue']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                                if (isMeeting && item['time'] != null && item['time'].toString().isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Time: ${item['time']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                                // Show attendance info for past meetings that have attendance data
                                if (!expiresDateTime.isAfter(now) && isMeeting && item['attendedStudents'] != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Attendance: ${(item['attendedStudents'] as List).length} attended',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegistersContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: registersRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading registers'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final allRegisters = snapshot.data!.docs;

        final registers = allRegisters.where((doc) {
          final register = doc.data() as Map<String, dynamic>;
          final isMyMentor = register['signkey'] == _menteeSignKey;
          final expiresAt = register['expiresAt'] as Timestamp?;
          final isActive = expiresAt != null &&
              expiresAt.toDate().isAfter(DateTime.now());
          return isMyMentor && isActive;
        }).toList();
        if (registers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No Active Registers',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later for attendance registers',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: registers.length,
          itemBuilder: (context, index) {
            final register = registers[index];
            final data = register.data() as Map<String, dynamic>;
            final expiresAt = (data['expiresAt'] as Timestamp).toDate();

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.assignment, color: Color(0xFF667eea)),
                title: Text(
                  data['question'] ?? 'No Question',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      'Expires: ${DateFormat('MMM dd, yyyy - hh:mm a').format(expiresAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: Icon(Icons.radio_button_checked, color: Color(0xFF667eea)),
                onTap: () {
                  _showRegisterResponseDialog(context, register.id, data);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showRegisterResponseDialog(BuildContext context, String registerId, Map<String, dynamic> data) {
    String? selectedOption;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Attendance Register'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['question'] ?? 'No Question',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text('Select your response:'),
                  SizedBox(height: 12),
                  ...(data['options'] as List).map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: selectedOption == null ? null : () {
                    Navigator.pop(context);
                    _submitRegisterResponse(registerId, selectedOption!, data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                  ),
                  child: Text('Submit Attendance'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitRegisterResponse(String registerId, String response, Map<String, dynamic> registerData) async {
    final userId = _auth.currentUser!.uid;

    try {
      await registersRef.doc(registerId).update({
        'attendedStudents': FieldValue.arrayUnion([userId])
      });
      final meetingId = registerData['meetingId'];
      if (meetingId != null) {
        final meetingDoc = await meetingsRef.doc(meetingId).get();
        if (meetingDoc.exists) {
          final meetingData = meetingDoc.data() as Map<String, dynamic>;
          final currentAttendedStudents = List<String>.from(meetingData['attendedStudents'] ?? []);
          final totalMentees = meetingData['totalMentees'] ?? 1;
          if (!currentAttendedStudents.contains(userId)) {
            currentAttendedStudents.add(userId);
            final newAttendancePercentage = (currentAttendedStudents.length / totalMentees) * 100;
            await meetingsRef.doc(meetingId).update({
              'attendedStudents': currentAttendedStudents,
              'attendancePercentage': newAttendancePercentage,
            });
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFF667eea), size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
class SuggestionsView extends StatefulWidget {
  @override
  _SuggestionsViewState createState() => _SuggestionsViewState();
}
class _SuggestionsViewState extends State<SuggestionsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  Future<String>getKey(String uid)async{
    DocumentSnapshot doc=await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['signkey'];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Suggestions & Feedback',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: _buildSuggestionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSuggestionDialog,
        backgroundColor: Color(0xFF667eea),
        child: Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search suggestions...',
            prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return FutureBuilder<String>(
      future: getKey(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, keySnapshot) {
        if (keySnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (keySnapshot.hasError) {
          return Center(child: Text('Error loading sign key'));
        }

        if (!keySnapshot.hasData || keySnapshot.data == null) {
          return Center(child: Text('No sign key found'));
        }
        final signKey = keySnapshot.data!;
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('suggestions')
              .where('signkey', isEqualTo: signKey)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Firestore Error: ${snapshot.error}');

              return Center(child: Text('Error loading suggestions'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            var suggestions = snapshot.data!.docs;
            if (_searchController.text.isNotEmpty) {
              suggestions = suggestions.where((doc) {
                final suggestion = doc['suggestion']?.toString().toLowerCase() ?? '';
                return suggestion.contains(_searchController.text.toLowerCase());
              }).toList();
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final doc = suggestions[index];
                final data = doc.data() as Map<String, dynamic>;
                final suggestion = data['suggestion']?.toString() ?? '';
                final timestamp = data['timestamp'] as Timestamp?;
                final date = timestamp?.toDate() ?? DateTime.now();

                return _buildSuggestionCard(doc.id, suggestion, date);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestionCard(String docId, String suggestion, DateTime date) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suggestion,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteSuggestion(docId),
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'No Suggestions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Be the first to share your feedback!',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSuggestionDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Suggestion'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share your thoughts, ideas, or feedback...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addSuggestion(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }


  Future<void> _addSuggestion(String suggestion) async {
    String? signkey=await getKey( FirebaseAuth.instance.currentUser!.uid);
    try {
      await _firestore.collection('suggestions').add({
        'suggestion': suggestion,
        'signkey':signkey,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Suggestion added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add suggestion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSuggestion(String docId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Suggestion'),
        content: Text('Are you sure you want to delete this suggestion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('suggestions').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Suggestion deleted'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete suggestion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
class SuggestTopicsPage extends StatefulWidget {
  const SuggestTopicsPage({super.key});

  @override
  State<SuggestTopicsPage> createState() => _SuggestTopicsPageState();
}
class _SuggestTopicsPageState extends State<SuggestTopicsPage> {
  final TextEditingController _topicController = TextEditingController();
  bool _isSubmitting = false;


  final List<String> _recentSuggestions = [
    'How to study for finals without stress',
    'Career options after graduation',
    'Time management for multiple projects',
    'Best ways to take notes in class',
    'How to prepare for job interviews',
    'Balancing social life and studies'
  ];
  Future<String>getKey(String uid)async{
    DocumentSnapshot doc=await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['signkey'];
  }
  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  void submit()async{
    final uid=await FirebaseAuth.instance.currentUser?.uid;
    final signkey=await getKey(uid!);
    await FirebaseFirestore.instance.collection('suggestions').add({
      'suggestion': _topicController.text,
      'signkey':signkey,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    });
    _showToast( "Suggestion added successfully.");
    _topicController.clear();

  }

  void _submitSuggestion() async{
    if (_topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Type something first...'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (_topicController.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Give me a bit more to work with...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isSubmitting = false;
      });
      setState(() {
        submit();
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Thanks!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.thumb_up, color: Color(0xFF667eea), size: 50),
                        SizedBox(height: 16),
                        Text(
                          'Suggestion sent!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _topicController.clear();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF667eea),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Suggest Another'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _useExample(String example) {
    _topicController.text = example;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'What would you like to discuss with your mentor?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: Color(0xFF667eea), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Need ideas? Tap below:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _recentSuggestions.take(6).map((example) => GestureDetector(
                                onTap: () => _useExample(example),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF667eea).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Color(0xFF667eea).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    example.length > 30 ? '${example.substring(0, 30)}...' : example,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF667eea),
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _topicController,
                              decoration: InputDecoration(
                                hintText: 'Type your topic suggestion here...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: EdgeInsets.all(16),
                              ),
                              maxLines: 3,
                              maxLength: 200,
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: _isSubmitting
                                  ? ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF667eea),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Sending...'),
                                  ],
                                ),
                              )
                                  : ElevatedButton(
                                onPressed: _submitSuggestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF667eea),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Submit Suggestion',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class TimetableEvent {
  final String id;
  final String userId;
  final String signkey;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String color;
  final String day; // Monday, Tuesday, etc.

  TimetableEvent({
    required this.id,
    required this.userId,
    required this.signkey,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'signkey': signkey,
      'title': title,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'day': day,
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'color': color,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory TimetableEvent.fromMap(Map<String, dynamic> map) {
    final startParts = (map['startTime'] as String).split(':');
    final endParts = (map['endTime'] as String).split(':');

    return TimetableEvent(
      id: map['id'],
      userId: map['userId'],
      signkey: map['signkey'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      color: map['color'],
      day: map['day'],
    );
  }

  TimetableEvent copyWith({
    String? id,
    String? userId,
    String? userKey,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? color,
    String? day,
  }) {
    return TimetableEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      signkey: userKey ?? this.signkey,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      day: day ?? this.day,
    );
  }
}
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _role = "";
  bool _isEditing = false;
  String _profileImageUrl = "";
  bool _isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();
  String _signkey = "";

  bool _isEditingTimetable = false;
  List<String> _timeSlots = [
    '6:00', '7:00', '8:00', '9:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
  ];

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  OverlayEntry? _addButtonOverlay;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfilePicture();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _removeAddButtonOverlay();
    super.dispose();
  }

  Future<void> _loadProfilePicture() async {
    try {
      final userId = _auth.currentUser!.uid;
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc['profile'] != null) {
        setState(() {
          _profileImageUrl = userDoc['profile'];
        });
      }
    } catch (e) {

    }
  }

  Future<String> getRole() async {
    final uid = _auth.currentUser?.uid;
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc['role'] ?? 'Student';
  }

  Future<String> getFullName() async {
    final uid = _auth.currentUser?.uid;
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return '${doc['fName'] ?? ''} ${doc['lName'] ?? ''}'.trim();
  }

  Future<String> getEmail() async {
    final uid = _auth.currentUser?.uid;
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    final studentNo = doc['studentNo'] ?? '';
    return studentNo.isNotEmpty ? '$studentNo@students.wits.ac.za' : '';
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      input.onChange.listen((event) async {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];

          if (file.size > 15 * 1024 * 1024) {
            _showToast('Image too large (max 15MB)', isError: true);
            return;
          }

          final reader = html.FileReader();

          reader.onLoadEnd.listen((event) async {
            if (reader.result != null) {
              final bytes = reader.result as List<int>;
              await _uploadImageToFirebase(bytes, file.name);
            }
          });

          reader.onError.listen((event) {
            _showToast('Failed to read image file', isError: true);
          });

          reader.readAsArrayBuffer(file);
        }
      });
    } catch (e) {
      print('Error picking image: $e');
      _showToast('Failed to pick image', isError: true);
    }
  }

  Future<void> _uploadImageToFirebase(List<int> imageBytes, String fileName) async {
    try {
      final userId = _auth.currentUser!.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'profile_${userId}_$timestamp.jpg';

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(uniqueFileName);

      _showToast('Uploading image...');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
      );

      final uploadTask = storageRef.putData(
          Uint8List.fromList(imageBytes),
          metadata
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: $progress%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _saveImageUrlToFirestore(downloadUrl);

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      _showToast('Profile picture updated!');
    } on FirebaseException catch (e) {
      print('Firebase upload error: $e');
      _showToast('Upload failed: ${e.message}', isError: true);
    } catch (e) {
      print('Upload error: $e');
      _showToast('Failed to upload image', isError: true);
    }
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      final userId = _auth.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'profile': imageUrl,
        'profileUpdatedAt': FieldValue.serverTimestamp()
      });
    } catch (e) {
      print('Firestore error: $e');
      rethrow;
    }
  }

  Future<void> _removeProfilePicture() async {
    try {
      final userId = _auth.currentUser!.uid;
      bool? shouldDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Remove Profile Picture"),
            content: const Text("Are you sure you want to remove your profile picture?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Remove", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        await _firestore.collection('users').doc(userId).update({
          'profile': FieldValue.delete(),
        });

        setState(() {
          _profileImageUrl = "";
        });

        _showToast('Profile picture removed!');
      }
    } catch (e) {
      _showToast('Failed to remove picture', isError: true);
    }
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    _showToast('Profile updated successfully!');
  }


  Stream<List<TimetableEvent>> _getTimetableEvents() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('timetable_events')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs.map((d) => TimetableEvent.fromMap(d.data())).toList());
  }

  Future<void> _saveEvent(TimetableEvent event) async {
    try {
      if (event.id.isEmpty) {
        final newEvent = event.copyWith(id: _uuid.v4());
        await _firestore.collection('timetable_events').doc(newEvent.id).set(newEvent.toMap());
        _showToast('Event added successfully!');
      } else {
        await _firestore.collection('timetable_events').doc(event.id).update(event.toMap());
        _showToast('Event updated successfully!');
      }
    } catch (e) {
      _showToast('Error saving event', isError: true);
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('timetable_events').doc(eventId).delete();
      _showToast('Event deleted successfully!');
    } catch (e) {
      _showToast('Error deleting event', isError: true);
    }
  }

  void _addNewTimeSlot() {
    setState(() {
      final lastTime = _timeSlots.last;
      final lastHour = int.parse(lastTime.split(':')[0]);
      final newHour = lastHour + 1;
      if (newHour <= 23) {
        _timeSlots.add('$newHour:00');
      }
    });
    _showToast('New time slot added');
  }

  void _removeLastTimeSlot() {
    setState(() {
      if (_timeSlots.length > 1) {
        _timeSlots.removeLast();
      }
    });
    _showToast('Time slot removed');
  }
  void _showAddEventButton(String day, int hour) {
    _removeAddButtonOverlay();

    final overlayState = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;

    _addButtonOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeAddButtonOverlay,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: screenSize.width,
              height: screenSize.height,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.9,
                    maxHeight: screenSize.height * 0.8,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity, // Take available width
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: Colors.blue.shade100, width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add_circle,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add Event on $day',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'At ${hour.toString().padLeft(2, '0')}:00',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _removeAddButtonOverlay,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildAddEventOption(
                                  Icons.add,
                                  'Add Event at ${hour.toString().padLeft(2, '0')}:00',
                                  'Create a new event at this time',
                                      () {
                                    _openAddDialog(day, hour);
                                    _removeAddButtonOverlay();
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildAddEventOption(
                                  Icons.schedule,
                                  'Custom Time Slot',
                                  'Choose a different start time',
                                      () {
                                    _openCustomTimeDialog(day);
                                    _removeAddButtonOverlay();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState.insert(_addButtonOverlay!);
  }


  Widget _buildAddEventOption(IconData icon, String title, String description, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity, // Take full width
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeAddButtonOverlay() {
    if (_addButtonOverlay != null) {
      _addButtonOverlay!.remove();
      _addButtonOverlay = null;
    }
  }

  void _openAddDialog(String day, int hour) {
    _showToast('Adding event for $day at $hour:00');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTimetableEventDialog(
        day: day,
        presetHour: hour,
        onSave: _saveEvent,
      ),
    );
  }

  void _openCustomTimeDialog(String day) {
    showDialog(
      context: context,
      builder: (_) => CustomTimeEventDialog(
        day: day,
        onSave: _saveEvent,
      ),
    );
  }

  void _openEditDialog(TimetableEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditTimetableEventDialog(
        event: event,
        onSave: _saveEvent,
        onDelete: () => _deleteEvent(event.id),
      ),
    );
  }


  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTimeForDisplay(String time) {
    final hour = int.parse(time.split(':')[0]);
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _saveProfile();
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF667eea),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionHeader("Personal Information"),
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildWeeklyTimetable(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade300,
                  width: 3,
                ),
                gradient: _profileImageUrl.isEmpty
                    ? LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
              ),
              child: ClipOval(
                child: _profileImageUrl.isEmpty
                    ? Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue.shade700,
                )
                    : Image.network(
                  _profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue.shade700,
                    );
                  },
                ),
              ),
            ),
            if (_isEditing)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  onPressed: _changeProfilePicture,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: _role == "mentor"
                ? LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [Colors.green.shade50, Colors.green.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _role == "mentor" ? Colors.blue.shade300 : Colors.green.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _role,
            style: TextStyle(
              color: _role == "mentor" ? Colors.blue.shade800 : Colors.green.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        // Add signkey display for mentors only
        if (_role == "mentor" && _signkey.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.vpn_key,
                        size: 16,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your Signkey',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _signkey));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Signkey copied to clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      tooltip: 'Copy signkey',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _signkey,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            fontFamily: 'Monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Share this signkey with your mentees for scheduling',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _loadSignkey() async {
    try {
      final userId = _auth.currentUser!.uid;
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final loadedSignkey = userData['signkey'] as String?;

        print('Loaded signkey from DB: $loadedSignkey');

        if (loadedSignkey != null && loadedSignkey.isNotEmpty) {
          setState(() {
            _signkey = loadedSignkey;
          });

        } else {
          print('No signkey found in user document or signkey is empty');
        }
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error loading signkey: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final name = await getFullName();
      final email = await getEmail();
      final role = await getRole();

      setState(() {
        _nameController.text = name;
        _emailController.text = email;
        _role = role;
      });
      if (_role == "mentor") {
        await _loadSignkey();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _nameController.text = 'Error loading name';
        _emailController.text = 'Error loading email';
        _role = 'Unknown';
        _isLoading = false;
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person_outline,
              label: "Full Name",
              value: _nameController.text,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email Address",
              value: _emailController.text,
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTimetable() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Timetable',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    // Add Row Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, size: 18, color: Colors.blue),
                            onPressed: _addNewTimeSlot,
                            tooltip: 'Add time slot',
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18, color: Colors.red),
                            onPressed: _removeLastTimeSlot,
                            tooltip: 'Remove time slot',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Edit Toggle Button
                    Container(
                      decoration: BoxDecoration(
                        color: _isEditingTimetable ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isEditingTimetable ? Icons.check : Icons.edit,
                          size: 20,
                          color: _isEditingTimetable ? Colors.white : Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingTimetable = !_isEditingTimetable;
                          });
                          _showToast(
                              _isEditingTimetable
                                  ? 'Edit mode enabled'
                                  : 'Edit mode disabled'
                          );
                        },
                        tooltip: _isEditingTimetable ? 'Save changes' : 'Edit timetable',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tap cells to ${_isEditingTimetable ? 'add/edit events' : 'view details'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Timetable Grid
            StreamBuilder<List<TimetableEvent>>(
              stream: _getTimetableEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final events = snapshot.data ?? [];
                return _buildTimetableGrid(events);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableGrid(List<TimetableEvent> events) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Days Header
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  // Time column header
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
                    ),
                    child: const Center(
                      child: Text(
                        'Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),

                  // Day headers
                  ..._shortDays.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    final isWeekend = index >= 5;

                    return Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: index < _shortDays.length - 1
                            ? Border(right: BorderSide(color: Colors.blue.shade100, width: 1))
                            : null,
                        color: isWeekend ? Colors.red.shade50 : Colors.blue.shade50,
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isWeekend ? Colors.red.shade700 : Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _days[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: isWeekend ? Colors.red.shade500 : Colors.blue.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Time slots and events
            ..._timeSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              final hour = int.parse(time.split(':')[0]);
              final isLast = index == _timeSlots.length - 1;

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    // Time slot
                    Container(
                      width: 80,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTimeForDisplay(time),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (index < _timeSlots.length - 1)
                            Text(
                              'to ${_formatTimeForDisplay(_timeSlots[index + 1])}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Day cells
                    ..._days.asMap().entries.map((dayEntry) {
                      final dayIndex = dayEntry.key;
                      final day = dayEntry.value;
                      final isWeekend = dayIndex >= 5;

                      // Find events for this time slot and day
                      final cellEvents = events.where((event) {
                        final eventDay = event.day;
                        final eventStartHour = event.startTime.hour;
                        final eventEndHour = event.endTime.hour;

                        return eventDay.toLowerCase() == day.toLowerCase() &&
                            eventStartHour <= hour &&
                            eventEndHour > hour;
                      }).toList();

                      return GestureDetector(
                        onTap: () {
                          if (_isEditingTimetable) {
                            if (cellEvents.isEmpty) {
                              _showAddEventButton(day, hour);
                            } else {
                              _openEditDialog(cellEvents.first);
                            }
                          } else if (cellEvents.isNotEmpty) {
                            _openEditDialog(cellEvents.first);
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: isWeekend ? Colors.grey.shade50 : Colors.white,
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: cellEvents.isEmpty
                              ? _isEditingTimetable
                              ? _buildEmptyCell(day, hour)
                              : null
                              : _buildEventCell(cellEvents.first),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell(String day, int hour) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.3),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          size: 20,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildEventCell(TimetableEvent event) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor(event.color).withOpacity(0.15),
        border: Border.all(color: HexColor(event.color).withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: HexColor(event.color).withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: HexColor(event.color),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${event.startTime.format(context)}-${event.endTime.format(context)}',
            style: TextStyle(
              fontSize: 8,
              color: HexColor(event.color),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (event.description.isNotEmpty)
            Text(
              event.description,
              style: TextStyle(
                fontSize: 7,
                color: HexColor(event.color),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
class AddTimetableEventDialog extends StatefulWidget {
  final String day;
  final int presetHour;
  final Function(TimetableEvent) onSave;

  const AddTimetableEventDialog({
    super.key,
    required this.day,
    required this.presetHour,
    required this.onSave,
  });

  @override
  State<AddTimetableEventDialog> createState() => _AddTimetableEventDialogState();
}
class _AddTimetableEventDialogState extends State<AddTimetableEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _selectedColor = '#4CAF50';

  final List<Map<String, dynamic>> _colors = [
    {'color': '#4CAF50', 'name': 'Green'},
    {'color': '#2196F3', 'name': 'Blue'},
    {'color': '#FF9800', 'name': 'Orange'},
    {'color': '#F44336', 'name': 'Red'},
    {'color': '#9C27B0', 'name': 'Purple'},
    {'color': '#00BCD4', 'name': 'Cyan'},
  ];

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay(hour: widget.presetHour, minute: 0);
    _endTime = TimeOfDay(hour: widget.presetHour + 1, minute: 0);
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<String> _getUserKey() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['signkey'] ?? uid;
  }

  DateTime _getDateForDay(String day) {
    final now = DateTime.now();
    final dayIndex = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        .indexOf(day);
    final currentDayIndex = now.weekday - 1;
    return now.add(Duration(days: dayIndex - currentDayIndex));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Event',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            widget.day,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Form
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Event Title *',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.title, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.description, color: Colors.grey),
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),

          // Time Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectStartTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startTime.format(context),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectEndTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endTime.format(context),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Color Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final colorData = _colors[index];
                    final color = colorData['color'] as String;
                    final name = colorData['name'] as String;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: HexColor(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: HexColor(color).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              color: _selectedColor == color ? Colors.black : Colors.grey,
                              fontWeight: _selectedColor == color ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a title'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final auth = FirebaseAuth.instance;
                      final userKey = await _getUserKey();

                      final event = TimetableEvent(
                        id: '',
                        userId: auth.currentUser!.uid,
                        signkey: userKey,
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        date: _getDateForDay(widget.day),
                        startTime: _startTime,
                        endTime: _endTime,
                        color: _selectedColor,
                        day: widget.day,
                      );

                      await widget.onSave(event);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
class CustomTimeEventDialog extends StatefulWidget {
  final String day;
  final Function(TimetableEvent) onSave;

  const CustomTimeEventDialog({
    super.key,
    required this.day,
    required this.onSave,
  });

  @override
  State<CustomTimeEventDialog> createState() => _CustomTimeEventDialogState();
}
class _CustomTimeEventDialogState extends State<CustomTimeEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
  String _selectedColor = '#2196F3';

  final List<String> _colors = [
    '#4CAF50', '#2196F3', '#FF9800', '#F44336', '#9C27B0', '#00BCD4'
  ];

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF667eea)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF667eea)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<String> _getUserKey() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['signkey'] ?? uid;
  }

  DateTime _getDateForDay(String day) {
    final now = DateTime.now();
    final dayIndex = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        .indexOf(day);
    final currentDayIndex = now.weekday - 1;
    return now.add(Duration(days: dayIndex - currentDayIndex));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Event with Custom Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.day,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Time'),
                      const SizedBox(height: 4),
                      OutlinedButton(
                        onPressed: _selectStartTime,
                        child: Text(_startTime.format(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Time'),
                      const SizedBox(height: 4),
                      OutlinedButton(
                        onPressed: _selectEndTime,
                        child: Text(_endTime.format(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: HexColor(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty) return;

                    try {
                      final userKey = await _getUserKey();
                      final event = TimetableEvent(
                        id: '',
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        signkey: userKey,
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        date: _getDateForDay(widget.day),
                        startTime: _startTime,
                        endTime: _endTime,
                        color: _selectedColor,
                        day: widget.day,
                      );

                      await widget.onSave(event);
                      Navigator.pop(context);
                    } catch (e) {
                      // Handle error
                    }
                  },
                  child: const Text('Add Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
class EditTimetableEventDialog extends StatefulWidget {
  final TimetableEvent event;
  final Function(TimetableEvent) onSave;
  final Function() onDelete;

  const EditTimetableEventDialog({
    super.key,
    required this.event,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditTimetableEventDialog> createState() => _EditTimetableEventDialogState();
}
class _EditTimetableEventDialogState extends State<EditTimetableEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedColor;

  final List<Map<String, dynamic>> _colors = [
    {'color': '#4CAF50', 'name': 'Green'},
    {'color': '#2196F3', 'name': 'Blue'},
    {'color': '#FF9800', 'name': 'Orange'},
    {'color': '#F44336', 'name': 'Red'},
    {'color': '#9C27B0', 'name': 'Purple'},
    {'color': '#00BCD4', 'name': 'Cyan'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event.title;
    _descriptionController.text = widget.event.description;
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
    _selectedColor = widget.event.color;
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Event',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            '${widget.event.day} • ${_startTime.format(context)}-${_endTime.format(context)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Form
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Event Title *',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.title, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.description, color: Colors.grey),
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),

          // Time Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectStartTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startTime.format(context),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectEndTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endTime.format(context),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Color Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final colorData = _colors[index];
                    final color = colorData['color'] as String;
                    final name = colorData['name'] as String;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: HexColor(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: HexColor(color).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              color: _selectedColor == color ? Colors.black : Colors.grey,
                              fontWeight: _selectedColor == color ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onDelete,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a title'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final updatedEvent = widget.event.copyWith(
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        startTime: _startTime,
                        endTime: _endTime,
                        color: _selectedColor,
                      );

                      await widget.onSave(updatedEvent);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
class HexColor extends Color {
  HexColor(final String hex) : super(int.parse(hex.replaceFirst('#', '0xff')));
}
class ViewMentorPage extends StatefulWidget {
  const ViewMentorPage({super.key});
  @override
  State<ViewMentorPage> createState() => _ViewMentorPageState();
}
class _ViewMentorPageState extends State<ViewMentorPage> {
  String mentorName = 'Loading...';
  String mentorEmail = 'Loading...';
  String mentorRole = 'Loading...';
  bool isLoading = true;
  String _profileImageUrl = "";

  Future<void> _loadProfilePicture() async {
    try {
      final mentor = await getMentorDoc();

      if (mentor != null && mentor['id'] != null) {
        final DocumentSnapshot mentorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(mentor['id'])
            .get();

        if (mentorDoc.exists && mentorDoc['profile'] != null && mentorDoc['profile'].isNotEmpty) {
          setState(() {
            _profileImageUrl = mentorDoc['profile'];
          });
        } else {
          setState(() {
            _profileImageUrl = "";
          });
        }
      } else {
        setState(() {
          _profileImageUrl = "";
        });
      }
    } catch (e) {
      setState(() {
        _profileImageUrl = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMentorData();
    _loadProfilePicture();
  }

  Future<Map<String, dynamic>?> getMentorDoc() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!currentUserDoc.exists) return null;

      final String signKey = currentUserDoc['signkey'];

      QuerySnapshot mentorQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('signkey', isEqualTo: signKey)
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorQuery.docs.isEmpty) {
        return null;
      }

      DocumentSnapshot mentorDoc = mentorQuery.docs.first;

      return {
        'id': mentorDoc.id,
        'name': '${mentorDoc['fName']} ${mentorDoc['lName']}',
        'email': '${mentorDoc['studentNo']}@students.wits.ac.za',
        'role': mentorDoc['role'],
        'signkey': mentorDoc['signkey'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadMentorData() async {
    final mentor = await getMentorDoc();

    if (mentor != null) {
      setState(() {
        mentorName = mentor['name'];
        mentorEmail = mentor['email'];
        mentorRole = mentor['role'];
        isLoading = false;
      });
    } else {
      setState(() {
        mentorName = 'No Mentor Assigned';
        mentorEmail = 'N/A';
        mentorRole = 'Not Available';
        isLoading = false;
      });
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: mentorEmail,
    );

    if (!await launchUrl(emailLaunchUri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'My Mentor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
      ),
      body: isLoading
          ? _buildLoadingState()
          : _buildProfileContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF667eea),
          ),
          SizedBox(height: 16),
          Text(
            'Loading mentor profile...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF667eea).withOpacity(0.1),
                      border: Border.all(
                        color: Color(0xFF667eea),
                        width: 3,
                      ),
                    ),
                    child: _profileImageUrl.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        _profileImageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Color(0xFF667eea),
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF667eea),
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    mentorName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFF667eea).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      mentorRole,
                      style: TextStyle(
                        color: Color(0xFF667eea),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildContactSection(),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF667eea),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'About Your Mentor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your mentor is here to guide you through your learning journey. '
                        'Feel free to reach out for assistance, guidance, or any questions '
                        'you may have about your progress.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_mail,
                color: Color(0xFF667eea),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Contact Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: _sendEmail,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.email,
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          mentorEmail,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Tap the email above to contact your mentor directly',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
class MentorHelpSupportPage extends StatelessWidget {
  const MentorHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white),
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Mentor Dashboard Guide'),
            _buildInfoCard(
              'Welcome to your MentorMenteeConnect dashboard! This comprehensive guide will help you '
                  'understand all the tools and features available to manage your mentees effectively '
                  'and create an engaging learning environment.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Navigation Guide'),
            _buildFeatureItem(
              icon: Icons.dashboard,
              title: 'Dashboard Tab',
              description: 'Overview of your mentorship activities, quick stats, and recent mentee interactions.',
            ),
            _buildFeatureItem(
              icon: Icons.people,
              title: 'Mentees Tab',
              description: 'View and manage all your assigned mentees, their progress, and contact information.',
            ),
            _buildFeatureItem(
              icon: Icons.announcement,
              title: 'Announcements Tab',
              description: 'Create and manage announcements, meeting notifications, and important updates for your mentees.',
            ),
            _buildFeatureItem(
              icon: Icons.assignment,
              title: 'Registers Tab',
              description: 'Create attendance registers, track mentee participation, and manage session attendance.',
            ),
            _buildFeatureItem(
              icon: Icons.calendar_today,
              title: 'Schedule Tab',
              description: 'Create and manage meetings, set up sessions, and organize your mentorship calendar.',
            ),
            _buildFeatureItem(
              icon: Icons.auto_awesome,
              title: 'AI Suggestions Tab',
              description: 'Generate intelligent topic suggestions using Gemini AI based on your mentees\' interests and learning patterns.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Mentor Features Explained'),
            _buildFeatureCard(
              'Mentee Management',
              Icons.supervisor_account,
              'View all your assigned mentees, track their progress, and access their contact information. '
                  'Monitor attendance patterns and engagement levels.',
            ),
            _buildFeatureCard(
              'Announcement System',
              Icons.campaign,
              'Create announcements that are automatically sent to all your mentees. '
                  'Include meeting details, resource links, or general updates. Use different types '
                  '(general, meeting, resource) for better organization.',
            ),
            _buildFeatureCard(
              'Attendance Registers',
              Icons.assignment_add,
              'Create digital attendance registers for your sessions. Set questions, options, '
                  'and expiration times. Track which mentees have responded in real-time.',
            ),

            _buildFeatureCard(
              'Meeting Scheduler',
              Icons.event_note,
              'Schedule meetings with automatic notifications to mentees. Include details like '
                  'title, description, date, time, venue, and total expected mentees.',
            ),

            _buildFeatureCard(
              'AI Topic Suggestions',
              Icons.auto_awesome,
              'Leverage Google\'s Gemini AI to generate intelligent topic suggestions based on:'
                  '\n• Mentee interests and past suggestions'
                  '\n• Current learning trends'
                  '\n• Skill gaps and development areas'
                  '\n• Industry-relevant topics',
            ),

            _buildFeatureCard(
              'Attendance Analytics',
              Icons.analytics,
              'View attendance percentages and patterns for your meetings. Identify engaged '
                  'mentees and those who may need additional support.',
            ),
            SizedBox(height: 24),

            _buildSectionHeader('AI Topic Suggestions Feature'),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_motion, color: Colors.purple.shade600, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Powered by Gemini AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildAIFeatureItem(
                      'Smart Topic Generation',
                      'AI analyzes mentee interests, past suggestions, and learning patterns to generate relevant topics.',
                    ),
                    _buildAIFeatureItem(
                      'Personalized Recommendations',
                      'Get topic suggestions tailored to your specific mentee group and their skill levels.',
                    ),
                    _buildAIFeatureItem(
                      'Trend Integration',
                      'AI incorporates current industry trends and emerging technologies into suggestions.',
                    ),
                    _buildAIFeatureItem(
                      'Learning Path Optimization',
                      'Suggestions are designed to create a logical learning progression for your mentees.',
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Use AI Suggestions:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildAIStep('1. Go to AI Suggestions tab'),
                          _buildAIStep('2. Click "Generate Topics" button'),
                          _buildAIStep('3. Review AI-generated suggestions'),
                          _buildAIStep('4. Save topics you want to use'),
                          _buildAIStep('5. Schedule meetings around selected topics'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Best Practices for Mentors'),
            _buildTipItem('✓ Create announcements regularly to keep mentees engaged'),
            _buildTipItem('✓ Set up attendance registers at least 15 minutes before sessions'),
            _buildTipItem('✓ Schedule meetings well in advance and send reminders'),
            _buildTipItem('✓ Use AI suggestions to discover new relevant topics'),
            _buildTipItem('✓ Monitor attendance patterns to identify mentees needing support'),
            _buildTipItem('✓ Use different announcement types for better organization'),
            _buildTipItem('✓ Combine AI suggestions with mentee feedback for optimal topics'),
            _buildTipItem('✓ Set realistic expiration times for attendance registers'),
            SizedBox(height: 24),
            _buildSectionHeader('Troubleshooting'),
            _buildTroubleshootingItem(
              'Mentees not receiving announcements',
              'Verify your signkey is correctly set and ensure mentees have the same signkey. Check internet connectivity.',
            ),
            _buildTroubleshootingItem(
              'Attendance register not showing for mentees',
              'Confirm the register hasn\'t expired and check if the mentor ID matches your user ID.',
            ),
            _buildTroubleshootingItem(
              'AI suggestions not generating',
              'Check your internet connection and ensure the Gemini API is properly configured. Try refreshing the page.',
            ),
            _buildTroubleshootingItem(
              'Meeting notifications not working',
              'Ensure all meeting details are properly saved and check the meeting date/time is in the future.',
            ),
            _buildTroubleshootingItem(
              'Can\'t view mentee list',
              'Verify you have assigned mentees and check your internet connection. Refresh the page.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Quick Actions Guide'),
            _buildQuickActionItem(
              'Create Announcement',
              'Go to Announcements tab → Tap + button → Fill details → Choose type → Publish',
            ),
            _buildQuickActionItem(
              'Setup Attendance Register',
              'Go to Registers tab → Create Register → Set question/options → Set expiry → Activate',
            ),
            _buildQuickActionItem(
              'Schedule Meeting',
              'Go to Schedule tab → Add Meeting → Enter details → Set date/time → Save',
            ),
            _buildQuickActionItem(
              'Generate AI Topics',
              'Go to AI Suggestions tab → Click Generate → Review suggestions → Save selected topics',
            ),
            _buildQuickActionItem(
              'Check Mentee Progress',
              'Go to Mentees tab → Select mentee → View profile and attendance history',
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.deepPurple.shade600, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'AI Suggestions Best Practices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Maximize the effectiveness of AI-generated topic suggestions with these strategies:',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAITip('Use AI suggestions as starting points for discussion'),
                          _buildAITip('Combine multiple AI topics into comprehensive sessions'),
                          _buildAITip('Modify AI suggestions based on your expertise'),
                          _buildAITip('Use trending topics to keep content current'),
                          _buildAITip('Balance AI suggestions with mentee-requested topics'),
                          _buildAITip('Track which AI-generated topics resonate most with mentees'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Color(0xFF667eea), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Mentor Resources',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Maximize your impact as a mentor with these additional resources and tips '
                          'for effective mentorship and engagement.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Effective Mentorship Tips:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildResourceTip('Set clear expectations with your mentees'),
                          _buildResourceTip('Provide regular, constructive feedback'),
                          _buildResourceTip('Encourage mentee participation and questions'),
                          _buildResourceTip('Use a variety of teaching methods'),
                          _buildResourceTip('Track progress and celebrate achievements'),
                          _buildResourceTip('Leverage AI to discover new teaching angles'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.orange.shade600, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Technical Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'For technical issues, system errors, AI feature problems, or feature requests, please contact the development team. '
                          'Include detailed information about the issue for faster resolution.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange.shade600),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Report AI or system issues immediately to ensure smooth operation for all users',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF667eea), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFeatureCard(String title, IconData icon, String description) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF667eea), size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAIFeatureItem(String feature, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: Colors.purple.shade600, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIStep(String step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        step,
        style: TextStyle(
          color: Colors.purple.shade700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildAITip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_outlined, color: Colors.deepPurple.shade600, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.deepPurple.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String issue, String solution) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            solution,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: Colors.green.shade600, size: 16),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String action, String steps) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            action,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            steps,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }


}
class MenteeHelpSupportPage extends StatelessWidget {
  const MenteeHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white),
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Welcome to MentorMenteeConnect'),
            _buildInfoCard(
              'MentorMenteeConnect is your dedicated platform for connecting with mentors, '
                  'managing your learning journey, and accessing educational resources. '
                  'This guide will help you understand all the features available to you.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Navigation Guide'),
            _buildFeatureItem(
              icon: Icons.home,
              title: 'Home Tab',
              description: 'View your dashboard with announcements, upcoming meetings, and quick overview of your activities.',
            ),
            _buildFeatureItem(
              icon: Icons.assignment,
              title: 'Register Tab',
              description: 'Submit attendance for mentor sessions and respond to attendance registers.',
            ),
            _buildFeatureItem(
              icon: Icons.calendar_today,
              title: 'Schedule Tab',
              description: 'View your meeting calendar, see upcoming sessions, and manage your schedule.',
            ),
            _buildFeatureItem(
              icon: Icons.lightbulb_outline,
              title: 'Suggest Tab',
              description: 'Share topic suggestions with your mentor for future sessions or discussions.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Key Features Explained'),

            _buildFeatureCard(
              'Announcements',
              Icons.announcement,
              'Stay updated with important notices from your mentor. You\'ll see meeting reminders, '
                  'resource updates, and general announcements here.',
            ),

            _buildFeatureCard(
              'Attendance Registers',
              Icons.assignment_turned_in,
              'When your mentor creates an attendance register, you\'ll receive a notification. '
                  'Tap on the register and select your response to mark your attendance.',
            ),

            _buildFeatureCard(
              'Meeting Schedule',
              Icons.event_available,
              'View all your scheduled meetings with date, time, and venue details. '
                  'Never miss an important session with your mentor.',
            ),

            _buildFeatureCard(
              'Topic Suggestions',
              Icons.lightbulb,
              'Have an idea for a discussion topic? Use the suggest feature to share your '
                  'learning interests with your mentor.',
            ),

            _buildFeatureCard(
              'Profile Management',
              Icons.person,
              'Update your personal information, view your mentor\'s details, and manage '
                  'your account settings.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Troubleshooting'),
            _buildTroubleshootingItem(
              'I can\'t see any announcements',
              'Make sure you\'re connected to the internet and check if your mentor has posted any announcements recently.',
            ),
            _buildTroubleshootingItem(
              'Attendance register not working',
              'Ensure you\'re submitting before the expiration time. If issues persist, contact your mentor directly.',
            ),
            _buildTroubleshootingItem(
              'Can\'t view meeting schedule',
              'Check your internet connection and verify that your mentor has scheduled upcoming meetings.',
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Quick Tips'),
            _buildTipItem('✓ Check the app regularly for new announcements'),
            _buildTipItem('✓ Submit attendance promptly when registers are available'),
            _buildTipItem('✓ Use the suggestion feature to guide your learning'),
            _buildTipItem('✓ Keep your profile information up to date'),
            _buildTipItem('✓ Contact your mentor directly for urgent matters'),
            SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Color(0xFF667eea), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Need More Help?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'If you\'re experiencing technical issues or need additional assistance, '
                          'please contact your mentor directly or reach out to our support team.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'For Technical Support:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Contact your mentor first for app-related questions',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF667eea), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String description) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF667eea), size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingItem(String issue, String solution) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            solution,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
enum MeetingFrequency {
  daily('Daily', Icons.event_repeat, 'Every day'),
  weekly('Weekly', Icons.calendar_today, 'Once a week'),
  biWeekly('Bi-Weekly', Icons.calendar_view_week, 'Every two weeks'),
  monthly('Monthly', Icons.date_range, 'Once a month'),
  quarterly('Quarterly', Icons.calendar_view_month, 'Every 3 months'),
  custom('Custom', Icons.settings, 'Custom schedule');

  final String title;
  final IconData icon;
  final String description;

  const MeetingFrequency(this.title, this.icon, this.description);

  int get minDaysAhead {
    switch (this) {
      case MeetingFrequency.daily:
        return 2;
      case MeetingFrequency.weekly:
        return 7;
      case MeetingFrequency.biWeekly:
        return 14;
      case MeetingFrequency.monthly:
        return 30;
      case MeetingFrequency.quarterly:
        return 90;
      case MeetingFrequency.custom:
        return 7;
    }
  }
}
class CombinedScheduleEvent {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String title;
  final String source;
  final String? signkey;

  CombinedScheduleEvent({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.source,
    this.signkey,
  });

  Map<String, dynamic> toJson() {
    String formatTime(String timeStr) {
      final time = GeminiMeetingSuggestionEngine._parseTimeString(timeStr);
      if (time != null) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
      return timeStr;
    }

    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'startTime': formatTime(startTime),
      'endTime': formatTime(endTime),
      'title': title,
      'source': source,
      'signkey': signkey,
    };
  }
}
class TimePreferences {
  final TimeOfDay? preferredStartTime;
  final TimeOfDay? preferredEndTime;
  final Duration? meetingDuration;

  TimePreferences({
    this.preferredStartTime,
    this.preferredEndTime,
    this.meetingDuration,
  });

  bool get hasTimeRange => preferredStartTime != null && preferredEndTime != null;

  Map<String, dynamic> toJson() {
    return {
      'hasTimeRange': hasTimeRange,
      'preferredStartTime': preferredStartTime?.format24Hour(),
      'preferredEndTime': preferredEndTime?.format24Hour(),
      'meetingDuration': meetingDuration?.inMinutes,
    };
  }
}
extension TimeOfDayExtension on TimeOfDay {
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
class GeminiMeetingSuggestionEngine {
  static Future<List<Map<String, dynamic>>> findOptimalTimesWithAI({
    required List<CombinedScheduleEvent> allEvents,
    required MeetingFrequency frequency,
    required String userSignkey,
    required String meetingTitle,
    required TimePreferences timePreferences,
    int numberOfSuggestions = 3,
  }) async {
    try {
      final now = DateTime.now();
      final candidateDates = _generateCandidateDates(frequency);

      final requestData = {
        'allEvents': allEvents.map((e) => e.toJson()).toList(),
        'frequency': {
          'title': frequency.title,
          'description': frequency.description,
          'minDaysAhead': frequency.minDaysAhead,
        },
        'userSignkey': userSignkey,
        'meetingTitle': meetingTitle,
        'timePreferences': {
          'hasTimeRange': timePreferences.hasTimeRange,
          'preferredStartTime': timePreferences.preferredStartTime?.format24Hour(),
          'preferredEndTime': timePreferences.preferredEndTime?.format24Hour(),
          'meetingDuration': timePreferences.meetingDuration?.inMinutes ?? 60,
        },
        'numberOfSuggestions': numberOfSuggestions,
        'now': now.toIso8601String(),
        'candidateDates': candidateDates.map((d) => d.toIso8601String()).toList(),
      };

      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('generateMeetingSuggestions');

      final result = await callable.call(requestData);
      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        List<dynamic> suggestions = data['suggestions'] ?? [];
        return _parseCloudFunctionResponse(
          suggestions,
          now,
          frequency,
          numberOfSuggestions,
          allEvents,
          timePreferences,
          candidateDates,
          userSignkey,
        );
      } else {
        return _getFallbackSuggestions(
          allEvents,
          frequency,
          timePreferences,
          candidateDates,
          userSignkey,
          numberOfSuggestions,
        );
      }
    } catch (e) {
      return _getFallbackSuggestions(
        allEvents,
        frequency,
        timePreferences,
        _generateCandidateDates(frequency),
        userSignkey,
        numberOfSuggestions,
      );
    }
  }

  static List<Map<String, dynamic>> _parseCloudFunctionResponse(
      List<dynamic> suggestions,
      DateTime now,
      MeetingFrequency frequency,
      int numberOfSuggestions,
      List<CombinedScheduleEvent> allEvents,
      TimePreferences timePreferences,
      List<DateTime> candidateDates,
      String userSignkey,
      ) {
    final List<Map<String, dynamic>> results = [];

    for (var suggestion in suggestions) {
      try {
        final suggestionMap = suggestion as Map<String, dynamic>;
        final date = DateTime.parse(suggestionMap['date']);
        final daysAhead = suggestionMap['daysAhead'] ?? date.difference(now).inDays;

        if (daysAhead < frequency.minDaysAhead || date.weekday == DateTime.sunday) {
          continue;
        }

        final timeStr = suggestionMap['time'] as String;
        if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeStr)) {
          continue;
        }

        final timetableConflict = suggestionMap['timetableConflict'] ?? false;
        if (timetableConflict) {
          continue;
        }

        final timeParts = timeStr.split(':');
        final startTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        final durationMinutes = timePreferences.meetingDuration?.inMinutes ?? 60;

        final conflicts = _checkConflictsForTime(
          date,
          startTime,
          durationMinutes,
          allEvents,
          userSignkey,
        );

        if (conflicts > 0) {
          continue;
        }

        results.add({
          'date': date,
          'time': timeStr,
          'score': suggestionMap['score'] ?? 0,
          'conflicts': conflicts,
          'reasoning': suggestionMap['reasoning'] ?? '',
          'matchesPreferences': suggestionMap['matchesPreferences'] ?? false,
          'preferenceMatches': List<String>.from(suggestionMap['preferenceMatches'] ?? []),
          'foundInGap': suggestionMap['foundInGap'] ?? false,
          'daysAhead': daysAhead,
          'timetableConflict': timetableConflict,
        });
      } catch (e) {
        continue;
      }
    }

    if (results.length < numberOfSuggestions) {
      final fallbackResults = _getFallbackSuggestions(
        allEvents,
        frequency,
        timePreferences,
        candidateDates,
        userSignkey,
        numberOfSuggestions - results.length,
      );
      results.addAll(fallbackResults);
    }

    return results.take(numberOfSuggestions).toList();
  }

  static List<DateTime> _generateCandidateDates(MeetingFrequency frequency) {
    final now = DateTime.now();
    final List<DateTime> dates = [];

    for (int i = frequency.minDaysAhead; i <= 90; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      if (date.weekday != DateTime.sunday) {
        dates.add(date);
      }
    }

    return dates;
  }

  static int _checkConflictsForTime(
      DateTime date,
      TimeOfDay startTime,
      int durationMinutes,
      List<CombinedScheduleEvent> allEvents,
      String userSignkey,
      ) {
    int conflicts = 0;
    final dateEvents = allEvents.where((event) =>
    event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day
    ).toList();

    final suggestedStartMinutes = startTime.hour * 60 + startTime.minute;
    final suggestedEndMinutes = suggestedStartMinutes + durationMinutes;

    for (final event in dateEvents) {
      final eventStart = _parseTimeString(event.startTime);
      final eventEnd = _parseTimeString(event.endTime);

      if (eventStart != null && eventEnd != null) {
        final eventStartMinutes = eventStart.hour * 60 + eventStart.minute;
        final eventEndMinutes = eventEnd.hour * 60 + eventEnd.minute;

        final hasConflict = (
            suggestedStartMinutes < eventEndMinutes &&
                suggestedEndMinutes > eventStartMinutes
        );

        if (hasConflict) {
          if (event.source == 'timetable' && event.signkey == userSignkey) {
            return 1000;
          }
          conflicts++;
        }
      }
    }

    return conflicts;
  }

  static List<Map<String, dynamic>> _getFallbackSuggestions(
      List<CombinedScheduleEvent> allEvents,
      MeetingFrequency frequency,
      TimePreferences timePreferences,
      List<DateTime> candidateDates,
      String userSignkey,
      int numberOfSuggestions,
      ) {
    final results = <Map<String, dynamic>>[];
    final durationMinutes = timePreferences.meetingDuration?.inMinutes ?? 60;
    final now = DateTime.now();

    for (var date in candidateDates) {
      if (results.length >= numberOfSuggestions) break;
      if (date.weekday == DateTime.sunday) continue;

      final daysAhead = date.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (daysAhead < frequency.minDaysAhead) {
        continue;
      }

      final dateEvents = allEvents.where((event) =>
      event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day
      ).toList();

      final workingStart = const TimeOfDay(hour: 8, minute: 0);
      final workingEnd = const TimeOfDay(hour: 20, minute: 0);
      final effectiveStartTime = timePreferences.preferredStartTime ?? workingStart;
      final effectiveEndTime = timePreferences.preferredEndTime ?? workingEnd;

      TimeOfDay? suggestedTime;
      bool matchesPreferences = false;
      bool foundInGap = false;
      List<String> matchedPrefs = [];
      String reasoning = '';

      List<TimeOfDay> candidateTimes = [];

      if (dateEvents.isEmpty) {
        if (_hasSufficientGap(effectiveStartTime, effectiveEndTime, durationMinutes)) {
          suggestedTime = effectiveStartTime;
          matchesPreferences = timePreferences.hasTimeRange;
          if (matchesPreferences) matchedPrefs.add('time');
          reasoning = 'Completely free day';
          candidateTimes.add(suggestedTime);
        }
      } else {
        dateEvents.sort((a, b) {
          final timeA = _parseTimeString(a.startTime);
          final timeB = _parseTimeString(b.startTime);
          if (timeA == null || timeB == null) return 0;
          return (timeA.hour * 60 + timeA.minute).compareTo(timeB.hour * 60 + timeB.minute);
        });

        candidateTimes.addAll(_findAvailableSlotsInDay(
          dateEvents,
          durationMinutes,
          effectiveStartTime,
          effectiveEndTime,
          workingStart,
          workingEnd,
        ));
      }

      for (final candidateTime in candidateTimes) {
        final conflicts = _checkConflictsForTime(
          date,
          candidateTime,
          durationMinutes,
          dateEvents,
          userSignkey,
        );

        if (conflicts == 0) {
          suggestedTime = candidateTime;
          matchesPreferences = _isTimeInRange(suggestedTime, effectiveStartTime, effectiveEndTime);
          if (matchesPreferences) matchedPrefs.add('time');

          final eventIndex = _findGapForTime(dateEvents, candidateTime, durationMinutes);
          if (eventIndex >= 0) {
            foundInGap = true;
            reasoning = 'Found gap between events';
          } else if (dateEvents.isEmpty) {
            reasoning = 'Free day';
          } else {
            reasoning = 'Available slot';
          }
          break;
        }
      }

      if (suggestedTime != null) {
        final conflicts = _checkConflictsForTime(
          date,
          suggestedTime,
          durationMinutes,
          allEvents,
          userSignkey,
        );

        if (conflicts > 0) {
          continue;
        }

        final isInTimeRange = _isTimeInRange(suggestedTime, effectiveStartTime, effectiveEndTime);
        final score = _calculateFallbackScore(
          matchesPreferences,
          foundInGap,
          dateEvents.length,
          date.weekday <= 5,
          daysAhead,
          frequency.minDaysAhead,
          isInTimeRange,
        );

        results.add({
          'date': date,
          'time': '${suggestedTime.hour.toString().padLeft(2, '0')}:${suggestedTime.minute.toString().padLeft(2, '0')}',
          'score': score,
          'conflicts': conflicts,
          'reasoning': '$reasoning ($daysAhead days ahead)',
          'matchesPreferences': matchesPreferences,
          'preferenceMatches': matchedPrefs,
          'foundInGap': foundInGap,
          'daysAhead': daysAhead,
          'timetableConflict': false,
        });
      }
    }

    if (results.isEmpty) {
      for (var date in candidateDates) {
        if (results.length >= numberOfSuggestions) break;

        if (date.weekday == DateTime.sunday) continue;

        final daysAhead = date.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (daysAhead < frequency.minDaysAhead) continue;

        final dateEvents = allEvents.where((event) =>
        event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day
        ).toList();

        if (dateEvents.isEmpty && date.weekday <= 5) {
          TimeOfDay defaultTime;
          if (timePreferences.hasTimeRange) {
            final preferredTime = timePreferences.preferredStartTime!;
            defaultTime = _isTimeInRange(preferredTime,
                timePreferences.preferredStartTime!, timePreferences.preferredEndTime!)
                ? preferredTime
                : const TimeOfDay(hour: 9, minute: 0);
          } else {
            defaultTime = const TimeOfDay(hour: 10, minute: 0);
          }

          final conflicts = _checkConflictsForTime(
            date,
            defaultTime,
            durationMinutes,
            allEvents,
            userSignkey,
          );

          if (conflicts > 0) {
            continue;
          }

          final isInPreferredRange = timePreferences.hasTimeRange ?
          _isTimeInRange(defaultTime, timePreferences.preferredStartTime!, timePreferences.preferredEndTime!) : false;

          results.add({
            'date': date,
            'time': '${defaultTime.hour.toString().padLeft(2, '0')}:${defaultTime.minute.toString().padLeft(2, '0')}',
            'score': isInPreferredRange ? 70 : 60,
            'conflicts': 0,
            'reasoning': 'No conflicts for $durationMinutes minutes ($daysAhead days ahead)',
            'matchesPreferences': isInPreferredRange,
            'preferenceMatches': isInPreferredRange ? ['time'] : [],
            'foundInGap': false,
            'daysAhead': daysAhead,
            'timetableConflict': false,
          });
        }
      }
    }

    return results;
  }

  static List<TimeOfDay> _findAvailableSlotsInDay(
      List<CombinedScheduleEvent> events,
      int durationMinutes,
      TimeOfDay preferredStart,
      TimeOfDay preferredEnd,
      TimeOfDay workingStart,
      TimeOfDay workingEnd,
      ) {
    final List<TimeOfDay> slots = [];

    final effectiveStart = _maxTimeOfDay(preferredStart, workingStart);
    final effectiveEnd = _minTimeOfDay(preferredEnd, workingEnd);

    if (events.isEmpty) {
      if (_hasSufficientGap(effectiveStart, effectiveEnd, durationMinutes)) {
        slots.add(effectiveStart);
      }
      return slots;
    }

    events.sort((a, b) {
      final timeA = _parseTimeString(a.startTime);
      final timeB = _parseTimeString(b.startTime);
      if (timeA == null || timeB == null) return 0;
      return (timeA.hour * 60 + timeA.minute).compareTo(timeB.hour * 60 + timeB.minute);
    });

    final firstEventStart = _parseTimeString(events.first.startTime);
    if (firstEventStart != null) {
      if (_hasSufficientGap(effectiveStart, firstEventStart, durationMinutes) &&
          _isTimeInRange(effectiveStart, workingStart, workingEnd)) {
        slots.add(effectiveStart);
      }
    }

    for (int i = 0; i < events.length - 1; i++) {
      final currentEventEnd = _parseTimeString(events[i].endTime);
      final nextEventStart = _parseTimeString(events[i + 1].startTime);

      if (currentEventEnd != null && nextEventStart != null) {
        if (_hasSufficientGap(currentEventEnd, nextEventStart, durationMinutes) &&
            _isTimeInRange(currentEventEnd, workingStart, workingEnd) &&
            _isTimeInRange(currentEventEnd, preferredStart, preferredEnd)) {
          slots.add(currentEventEnd);
        }
      }
    }

    final lastEventEnd = _parseTimeString(events.last.endTime);
    if (lastEventEnd != null) {
      if (_hasSufficientGap(lastEventEnd, effectiveEnd, durationMinutes) &&
          _isTimeInRange(lastEventEnd, workingStart, workingEnd) &&
          _isTimeInRange(lastEventEnd, preferredStart, preferredEnd)) {
        slots.add(lastEventEnd);
      }
    }

    if (slots.isEmpty) {
      final anySlot = _findAnyAvailableSlot(
        events,
        durationMinutes,
        workingStart,
        workingEnd,
      );
      if (anySlot != null) {
        slots.add(anySlot);
      }
    }

    return slots;
  }

  static int _findGapForTime(
      List<CombinedScheduleEvent> events,
      TimeOfDay time,
      int durationMinutes,
      ) {
    events.sort((a, b) {
      final timeA = _parseTimeString(a.startTime);
      final timeB = _parseTimeString(b.startTime);
      if (timeA == null || timeB == null) return 0;
      return (timeA.hour * 60 + timeA.minute).compareTo(timeB.hour * 60 + timeB.minute);
    });

    final timeInMinutes = time.hour * 60 + time.minute;
    final endTimeInMinutes = timeInMinutes + durationMinutes;

    if (events.isEmpty) return -1;

    final firstEventStart = _parseTimeString(events.first.startTime);
    if (firstEventStart != null) {
      final firstStartMinutes = firstEventStart.hour * 60 + firstEventStart.minute;
      if (endTimeInMinutes <= firstStartMinutes) {
        return -2;
      }
    }

    for (int i = 0; i < events.length - 1; i++) {
      final currentEventEnd = _parseTimeString(events[i].endTime);
      final nextEventStart = _parseTimeString(events[i + 1].startTime);

      if (currentEventEnd != null && nextEventStart != null) {
        final currentEndMinutes = currentEventEnd.hour * 60 + currentEventEnd.minute;
        final nextStartMinutes = nextEventStart.hour * 60 + nextEventStart.minute;

        if (timeInMinutes >= currentEndMinutes &&
            endTimeInMinutes <= nextStartMinutes) {
          return i;
        }
      }
    }

    final lastEventEnd = _parseTimeString(events.last.endTime);
    if (lastEventEnd != null) {
      final lastEndMinutes = lastEventEnd.hour * 60 + lastEventEnd.minute;
      if (timeInMinutes >= lastEndMinutes) {
        return events.length - 1;
      }
    }

    return -3;
  }

  static TimeOfDay? _findAnyAvailableSlot(
      List<CombinedScheduleEvent> events,
      int durationMinutes,
      TimeOfDay startBoundary,
      TimeOfDay endBoundary,
      ) {
    if (events.isEmpty) {
      return startBoundary;
    }

    events.sort((a, b) {
      final timeA = _parseTimeString(a.startTime);
      final timeB = _parseTimeString(b.startTime);
      if (timeA == null || timeB == null) return 0;
      return (timeA.hour * 60 + timeA.minute).compareTo(timeB.hour * 60 + timeB.minute);
    });

    final firstEventStart = _parseTimeString(events.first.startTime);
    if (firstEventStart != null) {
      if (_hasSufficientGap(startBoundary, firstEventStart, durationMinutes)) {
        return startBoundary;
      }
    }

    for (int i = 0; i < events.length - 1; i++) {
      final currentEventEnd = _parseTimeString(events[i].endTime);
      final nextEventStart = _parseTimeString(events[i + 1].startTime);

      if (currentEventEnd != null && nextEventStart != null) {
        if (_hasSufficientGap(currentEventEnd, nextEventStart, durationMinutes)) {
          return currentEventEnd;
        }
      }
    }

    final lastEventEnd = _parseTimeString(events.last.endTime);
    if (lastEventEnd != null) {
      if (_hasSufficientGap(lastEventEnd, endBoundary, durationMinutes)) {
        return lastEventEnd;
      }
    }

    return null;
  }

  static bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeInMinutes = time.hour * 60 + time.minute;
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;

    return timeInMinutes >= startInMinutes && timeInMinutes <= endInMinutes;
  }

  static TimeOfDay _maxTimeOfDay(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes >= bMinutes ? a : b;
  }

  static TimeOfDay _minTimeOfDay(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes <= bMinutes ? a : b;
  }

  static TimeOfDay? _parseTimeString(String timeString) {
    try {
      timeString = timeString.trim().toLowerCase();

      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          var hour = int.tryParse(parts[0]);
          var minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));

          if (hour != null && minute != null) {
            if (parts[1].contains('pm') && hour < 12) {
              hour += 12;
            } else if (parts[1].contains('am') && hour == 12) {
              hour = 0;
            }

            if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              return TimeOfDay(hour: hour, minute: minute);
            }
          }
        }
      }

      final regex = RegExp(r'(\d+):(\d+)\s*(am|pm)');
      final match = regex.firstMatch(timeString);
      if (match != null) {
        var hour = int.tryParse(match.group(1)!);
        var minute = int.tryParse(match.group(2)!);
        final period = match.group(3)!;

        if (hour != null && minute != null) {
          if (period == 'pm' && hour < 12) {
            hour += 12;
          } else if (period == 'am' && hour == 12) {
            hour = 0;
          }

          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      }

      final simpleMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeString);
      if (simpleMatch != null) {
        final hour = int.tryParse(simpleMatch.group(1)!);
        final minute = int.tryParse(simpleMatch.group(2)!);

        if (hour != null && minute != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      print('Error parsing time string: $timeString - $e');
    }
    return null;
  }

  static bool _hasSufficientGap(TimeOfDay start, TimeOfDay end, int durationMinutes) {
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;
    return (endInMinutes - startInMinutes) >= durationMinutes;
  }

  static int _calculateFallbackScore(
      bool matchesPrefs,
      bool foundInGap,
      int conflicts,
      bool isWeekday,
      int daysAhead,
      int minDaysAhead,
      bool isInTimeRange,
      ) {
    int score = 50;

    if (matchesPrefs) score += 15;
    if (foundInGap) score += 10;
    if (isWeekday) score += 10;
    if (isInTimeRange) score += 10;

    if (daysAhead >= minDaysAhead && daysAhead <= minDaysAhead * 2) {
      score += 15;
    } else if (daysAhead > minDaysAhead * 2 && daysAhead <= minDaysAhead * 3) {
      score += 10;
    } else if (daysAhead > minDaysAhead * 3) {
      score += 5;
    } else {
      score = 0;
    }

    score -= (conflicts * 3);

    if (!isWeekday) score -= 15;

    return score.clamp(0, 100);
  }
}
class SmartMeetingSchedulerPage extends StatefulWidget {
  const SmartMeetingSchedulerPage({super.key});

  @override
  State<SmartMeetingSchedulerPage> createState() =>
      _SmartMeetingSchedulerPageState();
}
class _SmartMeetingSchedulerPageState extends State<SmartMeetingSchedulerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '60');
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _venueFocusNode = FocusNode();
  final FocusNode _durationFocusNode = FocusNode();

  MeetingFrequency _selectedFrequency = MeetingFrequency.weekly;
  List<Map<String, dynamic>> _availableDates = [];
  bool _isFindingDates = false;
  int _retryCount = 0;
  final int _maxRetries = 5;
  String? _userSignkey;
  List<CombinedScheduleEvent> _allEvents = [];
  bool _isLoadingSignkey = false;
  bool _hasLoadError = false;

  TimeOfDay? _preferredStartTime;
  TimeOfDay? _preferredEndTime;
  bool _showTimePreferences = false;

  @override
  void initState() {
    super.initState();
    _initializeSignkey();

  }


  Future<void> _initializeSignkey() async {
    if (_isLoadingSignkey) return;

    setState(() {
      _isLoadingSignkey = true;
      _hasLoadError = false;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final signkey = userData?['signkey'] as String?;

        if (signkey != null && signkey.isNotEmpty) {
          setState(() {
            _userSignkey = signkey;
            _hasLoadError = false;
          });
        } else {
          throw Exception('Signkey not found in user profile. Please update your profile.');
        }
      } else {
        throw Exception('User profile not found. Please complete your profile setup.');
      }
    } catch (e) {
      setState(() {
        _hasLoadError = true;
        _userSignkey = null;
      });
      _showSnackBar('Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    } finally {
      setState(() {
        _isLoadingSignkey = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _durationController.dispose();
    _titleFocusNode.dispose();
    _venueFocusNode.dispose();
    _durationFocusNode.dispose();
    super.dispose();
  }

  Future<List<CombinedScheduleEvent>> _getAllScheduleEvents() async {
    final List<CombinedScheduleEvent> allEvents = [];

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('User not authenticated. Please sign in again.', isError: true);
        return allEvents;
      }

      if (_userSignkey == null) {
        _showSnackBar('User profile not loaded. Please wait or retry.', isError: true);
        return allEvents;
      }

      final now = DateTime.now();
      final next90Days = now.add(const Duration(days: 90));
      try {
        final timetableSnapshot = await _firestore
            .collection('timetable_events')
            .where('signkey', isEqualTo: _userSignkey)
            .limit(200)
            .get();

        final weekdayMap = {
          'Monday': DateTime.monday,
          'Tuesday': DateTime.tuesday,
          'Wednesday': DateTime.wednesday,
          'Thursday': DateTime.thursday,
          'Friday': DateTime.friday,
          'Saturday': DateTime.saturday,
          'Sunday': DateTime.sunday,
        };

        for (final doc in timetableSnapshot.docs) {
          final data = doc.data();
          try {
            final dayName = data['day'] as String?;
            final startTime = data['startTime']?.toString() ?? '09:00';
            final endTime = data['endTime']?.toString() ?? '10:00';
            final title = data['title']?.toString() ?? 'Timetable Event';
            final signkey = data['signkey']?.toString();
            final eventUserId = data['userId']?.toString();

            if (dayName != null) {
              final targetWeekday = weekdayMap[dayName];
              if (targetWeekday != null) {
                DateTime currentDate = now;
                while (currentDate.isBefore(next90Days) || currentDate.isAtSameMomentAs(next90Days)) {
                  if (currentDate.weekday == targetWeekday) {
                    final isMenteeEvent = eventUserId != null && eventUserId != userId;
                    final displayTitle = isMenteeEvent ? '$title (Mentee)' : title;

                    allEvents.add(CombinedScheduleEvent(
                      date: DateTime(currentDate.year, currentDate.month, currentDate.day),
                      startTime: startTime,
                      endTime: endTime,
                      title: displayTitle,
                      source: 'timetable',
                      signkey: signkey,
                    ));
                  }
                  currentDate = currentDate.add(const Duration(days: 1));
                }
              }
            }
          } catch (e) {

          }
        }
      } catch (e) {

      }
      try {
        final eventsSnapshot = await _firestore
            .collection('Events')
            .where('signkey', isEqualTo: _userSignkey)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .where('timestamp', isLessThan: Timestamp.fromDate(next90Days))
            .limit(100)
            .get();

        for (final doc in eventsSnapshot.docs) {
          final data = doc.data();
          try {
            final timestamp = data['timestamp'] as Timestamp?;
            if (timestamp != null) {
              final dateTime = timestamp.toDate();
              final title = data['title']?.toString() ?? 'Event';
              final dateTimeStr = data['dateTime']?.toString() ?? '';
              final isAllDay = dateTimeStr.contains('All Day');

              String startTime;
              String endTime;

              if (isAllDay) {
                startTime = '00:00';
                endTime = '23:59';
              } else {
                startTime = data['startTime']?.toString() ?? DateFormat('HH:mm').format(dateTime);
                endTime = data['endTime']?.toString() ??
                    DateFormat('HH:mm').format(dateTime.add(const Duration(hours: 1)));
              }

              allEvents.add(CombinedScheduleEvent(
                date: DateTime(dateTime.year, dateTime.month, dateTime.day),
                startTime: startTime,
                endTime: endTime,
                title: isAllDay ? '$title (All Day)' : title,
                source: 'events',
                signkey: data['signkey']?.toString(),
              ));
            }
          } catch (e) {
            print('Error parsing Events entry ${doc.id}: $e');
          }
        }
      } catch (e) {
        print('Error fetching Events: $e');
      }
      try {
        final calendarSnapshot = await _firestore
            .collection('events')
            .where('uid', isEqualTo: userId)
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .where('dateTime', isLessThan: Timestamp.fromDate(next90Days))
            .limit(100)
            .get();

        for (final doc in calendarSnapshot.docs) {
          final data = doc.data();
          try {
            final dateTime = (data['dateTime'] as Timestamp?)?.toDate();
            if (dateTime != null) {
              allEvents.add(CombinedScheduleEvent(
                date: DateTime(dateTime.year, dateTime.month, dateTime.day),
                startTime: data['startTime']?.toString() ?? '09:00',
                endTime: data['endTime']?.toString() ?? '17:00',
                title: data['title']?.toString() ?? 'Calendar Event',
                source: 'calendar',
                signkey: _userSignkey,
              ));
            }
          } catch (e) {
            print('Error parsing calendar event ${doc.id}: $e');
          }
        }
      } catch (e) {

      }


    } catch (e) {
      print('Error fetching schedule events: $e');
      _showSnackBar('Error loading schedule events: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    }

    return allEvents;
  }

  Future<void> _findAvailableDates() async {
    if (_userSignkey == null || _userSignkey!.isEmpty) {
      _showSnackBar('Please wait, still loading your profile...', isError: true);
      await _initializeSignkey();
      if (_userSignkey == null) {
        return;
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a meeting title first', isError: true);
      _titleFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isFindingDates = true;
      _availableDates = [];
    });

    try {


      _allEvents = await _getAllScheduleEvents();

      final durationText = _durationController.text.trim();
      final durationMinutes = int.tryParse(durationText) ?? 60;

      if (durationMinutes <= 0) {
        _showSnackBar('Please enter a valid duration (positive number)', isError: true);
        setState(() { _isFindingDates = false; });
        return;
      }

      final timePreferences = TimePreferences(
        preferredStartTime: _preferredStartTime,
        preferredEndTime: _preferredEndTime,
        meetingDuration: Duration(minutes: durationMinutes),
      );

      final suggestions = await GeminiMeetingSuggestionEngine.findOptimalTimesWithAI(
        allEvents: _allEvents,
        frequency: _selectedFrequency,
        userSignkey: _userSignkey!,
        meetingTitle: _titleController.text.trim(),
        timePreferences: timePreferences,
        numberOfSuggestions: 3,
      );

      setState(() {
        _availableDates = suggestions;
        _isFindingDates = false;
        _retryCount = 0;
      });

      if (suggestions.isEmpty) {
        _showSnackBar('No optimal dates found for $durationMinutes minutes. Try changing duration, time preferences, or frequency.');
      } else {
        final matchesCount = suggestions.where((s) => (s['matchesPreferences'] as bool?) ?? false).length;
        final gapCount = suggestions.where((s) => (s['foundInGap'] as bool?) ?? false).length;
        String extraInfo = '';
        if (matchesCount > 0) extraInfo += '($matchesCount match preferences) ';
        if (gapCount > 0) extraInfo += '($gapCount found in gaps)';
        final earliestDate = suggestions.map((s) => s['date'] as DateTime).reduce((a, b) => a.isBefore(b) ? a : b);
        final earliestDays = earliestDate.difference(DateTime.now()).inDays;

        _showSnackBar('Found ${suggestions.length} optimal meeting times! Earliest: $earliestDays days ahead. $extraInfo');
      }
    } catch (e) {
      print('Error in _findAvailableDates: $e');
      setState(() {
        _isFindingDates = false;
      });
      _showSnackBar('Error finding available dates: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    }
  }

  Future<void> _retryFindDates() async {
    if (_retryCount >= _maxRetries) {
      _showSnackBar('Maximum retries reached. Try changing the frequency or preferences.');
      return;
    }

    setState(() {
      _isFindingDates = true;
      _retryCount++;
    });

    await Future.delayed(const Duration(seconds: 1));
    await _findAvailableDates();
  }

  void _onFrequencyChanged(MeetingFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
    if (_availableDates.isNotEmpty) {
      _findAvailableDates();
    }
  }

  Future<void> _scheduleMeeting(Map<String, dynamic> dateInfo) async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a meeting title', isError: true);
      return;
    }

    if (_userSignkey == null) {
      _showSnackBar('User profile not loaded', isError: true);
      return;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('User not authenticated', isError: true);
      return;
    }

    try {
      final date = dateInfo['date'] as DateTime;
      final timeSlot = dateInfo['time'] as String;
      final timeParts = timeSlot.split(':');
      final startTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      final durationText = _durationController.text.trim();
      final durationMinutes = int.tryParse(durationText) ?? 60;

      final totalMinutes = startTime.hour * 60 + startTime.minute + durationMinutes;
      final endTime = TimeOfDay(
        hour: totalMinutes ~/ 60,
        minute: totalMinutes % 60,
      );

      final meetingDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      final eventId = '${DateTime.now().millisecondsSinceEpoch}_${date.millisecondsSinceEpoch}';
      final eventData = {
        'id': eventId,
        'uid': userId,
        'signkey': _userSignkey,
        'title': _titleController.text.trim(),
        'description': 'Meeting: ${_venueController.text.isNotEmpty ? _venueController.text : "No venue specified"}\nDuration: ${durationMinutes} minutes\nFrequency: ${_selectedFrequency.title}',
        'venue': _venueController.text.trim(),
        'type': 'meeting',
        'duration': durationMinutes,
        'frequency': _selectedFrequency.title,
        'timestamp': Timestamp.fromDate(meetingDateTime),
        'isoDate': DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(meetingDateTime),
        'dateTime': DateFormat('d/M/yyyy • HH:mm').format(meetingDateTime),
        'reminderType': 'immediate',
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('Events').doc(eventId).set(eventData);
      final timetableId = 'timetable_$eventId';
      final timetableData = TimetableEvent(
        id: timetableId,
        userId: userId,
        signkey: _userSignkey!,
        title: _titleController.text.trim(),
        description: 'Meeting: ${_venueController.text.isNotEmpty ? _venueController.text : "No venue specified"}\nDuration: ${durationMinutes} minutes\nFrequency: ${_selectedFrequency.title}',
        date: date,
        startTime: startTime,
        endTime: endTime,
        color: '#2196F3',
        day: DateFormat('EEEE').format(date),
      ).toMap();

      await _firestore.collection('timetable_events').doc(timetableId).set(timetableData);

      final daysAhead = date.difference(DateTime.now()).inDays;
      _showSnackBar(
        '${_selectedFrequency.title} meeting scheduled for ${DateFormat('EEE, MMM d').format(date)} at ${startTime.format(context)} (${durationMinutes} min, $daysAhead days ahead)!',
      );

      _titleController.clear();
      _venueController.clear();
      _findAvailableDates();
    } catch (e) {
      print('Error scheduling meeting: $e');
      _showSnackBar('Error scheduling meeting: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    }
  }

  void _ignoreDate(int index) {
    setState(() {
      _availableDates.removeAt(index);
    });
    if (_availableDates.isEmpty) {
      _showSnackBar('Date ignored. Finding new dates...');
      _findAvailableDates();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFrequencySelectionDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (context) => _FrequencySelectionDialog(
        selectedFrequency: _selectedFrequency,
        onFrequencySelected: _onFrequencyChanged,
      ),
    );
  }

  void _showTimeRangeSelectionDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Preferred Time Range'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(_preferredStartTime != null
                    ? 'From: ${_preferredStartTime!.format(context)}'
                    : 'Select start time'
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _preferredStartTime ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) {
                    setState(() {
                      _preferredStartTime = picked;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: Text(_preferredEndTime != null
                    ? 'To: ${_preferredEndTime!.format(context)}'
                    : 'Select end time'
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _preferredEndTime ?? const TimeOfDay(hour: 17, minute: 0),
                  );
                  if (picked != null) {
                    setState(() {
                      _preferredEndTime = picked;
                    });
                  }
                },
              ),
              if (_preferredStartTime != null && _preferredEndTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Selected: ${_preferredStartTime!.format(context)} - ${_preferredEndTime!.format(context)}',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _getConfidenceLabel(int score) {
    if (score >= 85) return 'High';
    if (score >= 50) return 'Medium';
    return 'Low';
  }

  Color _getConfidenceColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String? _getTimeRangeText() {
    if (_preferredStartTime != null && _preferredEndTime != null) {
      return '${_preferredStartTime!.format(context)} - ${_preferredEndTime!.format(context)}';
    }
    return null;
  }

  String _getFrequencyTimingInfo() {
    final now = DateTime.now();
    final minDate = now.add(Duration(days: _selectedFrequency.minDaysAhead));
    return 'Planning meetings after ${DateFormat('MMM d').format(minDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final timeRangeText = _getTimeRangeText();
    final durationText = _durationController.text.trim();
    final durationMinutes = int.tryParse(durationText) ?? 60;
    final frequencyTimingInfo = _getFrequencyTimingInfo();

    return GestureDetector(
      onTap: () {
        if (!_titleFocusNode.hasFocus &&
            !_venueFocusNode.hasFocus &&
            !_durationFocusNode.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Smart Scheduler',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
          ),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            const SizedBox(width: 8),
            if (_availableDates.isNotEmpty && !_isFindingDates)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _findAvailableDates,
                tooltip: 'Refresh dates',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI-Powered Meeting Scheduler',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Powered by Google Gemini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userSignkey != null
                            ? 'Ready to analyze your schedule'
                            : 'Loading your profile information...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meeting Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Meeting title...',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _venueController,
                        focusNode: _venueFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Meeting venue (optional)...',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              focusNode: _durationFocusNode,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Duration (minutes)...',
                                prefixIcon: const Icon(Icons.timer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('min'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Time Preferences',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showTimePreferences ? Icons.expand_less : Icons.expand_more,
                            ),
                            onPressed: () {
                              setState(() {
                                _showTimePreferences = !_showTimePreferences;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_showTimePreferences) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _showTimeRangeSelectionDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Preferred Time Range',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        timeRangeText ?? 'Tap to set preferred time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  timeRangeText != null
                                      ? Icons.check_circle
                                      : Icons.arrow_drop_down,
                                  color: timeRangeText != null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (timeRangeText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'AI will prioritize $timeRangeText',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667eea),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Meeting Frequency',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _showFrequencySelectionDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedFrequency.icon,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedFrequency.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFrequency.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                frequencyTimingInfo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'AI-Suggested Meeting Times',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!_isFindingDates)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.search, size: 18),
                              label: const Text('Find Times'),
                              onPressed: _findAvailableDates,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                backgroundColor: Color(0xFF667eea),
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Looking for ${_selectedFrequency.title.toLowerCase()} meetings',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (_isFindingDates)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Color(0xFF667eea)),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  Text(
                                    'AI is analyzing your schedule...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Finding $durationMinutes minute slots...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  if (timeRangeText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Prioritizing $timeRangeText',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF667eea),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (!_isFindingDates && _availableDates.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Found optimal times for $durationMinutes minutes:',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            ..._availableDates.asMap().entries.map((entry) {
                              final index = entry.key;
                              final dateInfo = entry.value;
                              final date = dateInfo['date'] as DateTime;
                              final time = dateInfo['time'] as String;
                              final score = dateInfo['score'] as int;
                              final conflicts = dateInfo['conflicts'] as int;
                              final reasoning = dateInfo['reasoning'] as String;
                              final matchesPreferences = (dateInfo['matchesPreferences'] as bool?) ?? false;
                              final preferenceMatches = List<String>.from(dateInfo['preferenceMatches'] ?? []);
                              final foundInGap = (dateInfo['foundInGap'] as bool?) ?? false;
                              final daysAhead = (dateInfo['daysAhead'] as int?) ?? date.difference(DateTime.now()).inDays;
                              final isRecommended = index == 0 && matchesPreferences;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: _buildAIDateCard(
                                  date,
                                  time,
                                  score,
                                  conflicts,
                                  reasoning,
                                  matchesPreferences,
                                  preferenceMatches,
                                  foundInGap,
                                  isRecommended,
                                  index,
                                  durationMinutes,
                                  daysAhead,
                                ),
                              );
                            }).toList(),
                            if (_retryCount < _maxRetries)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    'Find Different Times (${_maxRetries - _retryCount} left)',
                                  ),
                                  onPressed: _retryFindDates,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange.shade700,
                                    side: BorderSide(
                                        color: Colors.orange.shade300),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      if (!_isFindingDates &&
                          _availableDates.isEmpty &&
                          _retryCount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.schedule_send,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No optimal times found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No $durationMinutes minute slots available. Try changing duration, time preferences, or frequency',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIDateCard(
      DateTime date,
      String time,
      int score,
      int conflicts,
      String reasoning,
      bool matchesPreferences,
      List<String> preferenceMatches,
      bool foundInGap,
      bool isRecommended,
      int index,
      int durationMinutes,
      int daysAhead,
      ) {
    final timeParts = time.split(':');
    final startTime = TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    final totalMinutes = startTime.hour * 60 + startTime.minute + durationMinutes;
    final endTime = TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );

    return Card(
      elevation: isRecommended ? 4 : (matchesPreferences || foundInGap) ? 3 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecommended
              ? Colors.green.shade300
              : matchesPreferences
              ? Colors.blue.shade300
              : foundInGap
              ? Colors.purple.shade300
              : Colors.grey.shade200,
          width: isRecommended ? 2 : (matchesPreferences || foundInGap) ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: matchesPreferences
                        ? Colors.blue.shade50
                        : foundInGap
                        ? Colors.purple.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    matchesPreferences ? Icons.thumb_up
                        : foundInGap ? Icons.schedule
                        : Icons.calendar_today,
                    color: matchesPreferences
                        ? Colors.blue.shade700
                        : foundInGap
                        ? Colors.purple.shade700
                        : Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d').format(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: matchesPreferences
                              ? Colors.blue.shade800
                              : foundInGap
                              ? Colors.purple.shade800
                              : Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '${startTime.format(context)} - ${endTime.format(context)} ($durationMinutes min)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: daysAhead >= _selectedFrequency.minDaysAhead
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$daysAhead days ahead',
                          style: TextStyle(
                            fontSize: 10,
                            color: daysAhead >= _selectedFrequency.minDaysAhead
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (matchesPreferences)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PREFERRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  )
                else if (foundInGap)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'GAP FOUND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(score).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_getConfidenceLabel(score)} Confidence',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getConfidenceColor(score),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (conflicts > 0)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$conflicts event${conflicts == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
              ],
            ),
            if (reasoning.isNotEmpty && reasoning.length < 100) ...[
              const SizedBox(height: 8),
              Text(
                reasoning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: matchesPreferences
                      ? Colors.blue.shade800
                      : foundInGap
                      ? Colors.purple.shade800
                      : Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_titleController.text.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Ignore'),
                      onPressed: () => _ignoreDate(index),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.schedule, size: 18),
                      label: const Text('Schedule'),
                      onPressed: () => _scheduleMeeting(_availableDates[index]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: matchesPreferences
                            ? Colors.blue.shade600
                            : foundInGap
                            ? Colors.purple.shade600
                            : Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Enter meeting title to schedule',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _FrequencySelectionDialog extends StatelessWidget {
  final MeetingFrequency selectedFrequency;
  final Function(MeetingFrequency) onFrequencySelected;

  const _FrequencySelectionDialog({
    required this.selectedFrequency,
    required this.onFrequencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.repeat,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Frequency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'How often should meetings occur?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MeetingFrequency.values.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final frequency = MeetingFrequency.values[index];
                  final isSelected = selectedFrequency == frequency;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        frequency.icon,
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      frequency.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade800,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          frequency.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Plans ${frequency.minDaysAhead}+ days ahead',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(
                      Icons.check_circle,
                      color: Colors.blue.shade700,
                    )
                        : null,
                    onTap: () {
                      onFrequencySelected(frequency);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: isSelected ? Colors.blue.shade50 : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}