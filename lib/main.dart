import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentorMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
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
                      'MentorMate',
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
  final _signkeyController = TextEditingController(); // NEW: For mentee signkey

  String _selectedRole = 'mentee';

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _studentNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signkeyController.dispose(); // NEW
    super.dispose();
  }

  String _generateSignKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<String?> _findMentorBySignKey(String signkey) async {
    try {
      final mentorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('signkey', isEqualTo: signkey)
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorSnapshot.docs.isNotEmpty) {
        return mentorSnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error finding mentor: $e');
      return null;
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
      Fluttertoast.showToast(
        msg: "Passwords do not match",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        String? uid = userCredential.user?.uid;

        if (uid != null) {
          Map<String, dynamic> userData = {
            'fName': fName,
            'lName': lName,
            'role': _selectedRole,
            'studentNo': _studentNumberController.text,
            'profile': imageUrl,
            'createdAt': FieldValue.serverTimestamp(),
          };

          if (_selectedRole == 'mentor') {
            String signkey = _generateSignKey();
            userData['signkey'] = signkey; // Store signkey for mentor

            await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
            _showMentorSignKeyDialog(signkey);
          } else if (_selectedRole == 'mentee') {
            if (_signkeyController.text.isEmpty) {
              Fluttertoast.showToast(
                msg: "Please enter your mentor's signkey",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );
              return;
            }

            String? mentorId = await _findMentorBySignKey(_signkeyController.text);
            if (mentorId == null) {
              Fluttertoast.showToast(
                msg: "Invalid signkey. Please check with your mentor.",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );
              return;
            }

            userData['mentor_id'] = mentorId;
            userData['signkey'] = _signkeyController.text; // Store signkey for mentee too

            await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

            Fluttertoast.showToast(msg: "Account successfully created!");
            Navigator.push(context, MaterialPageRoute(builder: (_) => SignInPage()));
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Fluttertoast.showToast(
            msg: "Password is too weak.",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
          );
        } else if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
            msg: "Student number already exists.",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
          );
        } else {
          Fluttertoast.showToast(
            msg: "${e.message}",
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
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
                    'Join MentorMate as a mentor or mentee',
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

                                // NEW: Signkey Field (only shown for mentees)
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

  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _login()async{
    String email=_studentNumberController.text+"@students.wits.ac.za";
    String password=_passwordController.text;
    Fluttertoast.showToast(msg: "Login successful.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
    String? uid;
    try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          uid=FirebaseAuth.instance.currentUser?.uid;
          DocumentSnapshot doc=await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if(doc['role']=='mentee'){

              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MenteeHomePage()));
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (_)=>MentorHomePage()));
            }

    }on FirebaseAuthException catch(e){
        Fluttertoast.showToast(msg: "Login failed :${e.message}");
    }
  }
void _changePass()async{
    String email=_studentNumberController.text+"@students.wits.ac.za";
    if(!_studentNumberController.text.isEmpty){
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    Fluttertoast.showToast(msg: "Recovery email sent.",
        toastLength:Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);}
    else{
      Fluttertoast.showToast(msg: "Failed to send recovery email.",
      toastLength:Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM);
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
                    'Sign in to your MentorMate account',
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


  TextEditingController _announcementTitleController = TextEditingController();
  TextEditingController _announcementDescriptionController = TextEditingController();
  DateTime _announcementSelectedDate = DateTime.now();
  TimeOfDay _announcementSelectedTime = TimeOfDay.now();

  TextEditingController _quizTitleController = TextEditingController();
  TextEditingController _quizDescriptionController = TextEditingController();
  TextEditingController _quizDueDateController = TextEditingController();
  List<Map<String, dynamic>> _quizQuestions = [];

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
                                  // Query meetings for this mentor (no ordering so no index required)
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

                                  // If there are multiple meetings, choose the latest by createdAt locally
                                  final docs = List<QueryDocumentSnapshot>.from(meetingSnapshot.docs);

                                  docs.sort((a, b) {
                                    final aData = a.data() as Map<String, dynamic>;
                                    final bData = b.data() as Map<String, dynamic>;

                                    final aTs = aData['createdAt'] as Timestamp?;
                                    final bTs = bData['createdAt'] as Timestamp?;

                                    // Treat null timestamps as very old
                                    final aMillis = aTs?.millisecondsSinceEpoch ?? 0;
                                    final bMillis = bTs?.millisecondsSinceEpoch ?? 0;

                                    return bMillis.compareTo(aMillis); // descending -> latest first
                                  });

                                  final chosenDoc = docs.first;
                                  final meetingData = chosenDoc.data() as Map<String, dynamic>;

                                  // IMPORTANT: get the Firestore doc ID from the snapshot, NOT from the fields
                                  final meetingId = chosenDoc.id;

                                  final date = meetingData['date'] ?? '';
                                  final title = meetingData['title'] ?? 'the meeting';

                                  // Calculate expiration time (24 hours from now)
                                  final expiresAt = DateTime.now().add(Duration(hours: 24));
                                  final signKey=await getKey(currentUserId);
                                  await FirebaseFirestore.instance.collection('registers').add({
                                    'question': 'Did you attend "$title" on $date?',
                                    'options': ['Yes', 'No'],
                                    'title': title,
                                    'date': date,
                                    'meetingId': meetingId, // <-- correct: doc.id
                                    'mentorId': currentUserId,
                                    'createdAt': FieldValue.serverTimestamp(),
                                    'expiresAt': Timestamp.fromDate(expiresAt),
                                    'attendedStudents': [],
                                    'attendancePercentage': 0,
                                  });
                                  final event = {
                                    'title': title,
                                    'description':'Register reminder due on $date?',
                                    'signkey':signKey,
                                    'dateTime': date,
                                    'uid': FirebaseAuth.instance.currentUser!.uid,
                                  };
                                  await FirebaseFirestore.instance
                                      .collection('Events')
                                      .add(event);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Register generated - expires in 24 hours'),
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
                                    final signKey=await getKey(currentUserId);
                                    if (_announcementTitleController.text.isNotEmpty) {
                                      try {
                                        final newAnnouncement = {
                                          'title': _announcementTitleController.text,
                                          'description': _announcementDescriptionController.text,
                                          'date': '${_announcementSelectedDate.day}/${_announcementSelectedDate.month}/${_announcementSelectedDate.year} • ${_announcementSelectedTime.format(context)}',
                                          'type': 'announcement',
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'signkey':signKey,
                                          'createdBy': currentUserId,
                                        };

                                        await announcementsRef.add(newAnnouncement);
                                        final event = {
                                          'title': _announcementTitleController.text,
                                          'description':'Announcement reminder',
                                          'signkey':signKey,
                                          'dateTime': '${_announcementSelectedDate.day}/${_announcementSelectedDate.month}/${_announcementSelectedDate.year} • ${_announcementSelectedTime.format(context)}',
                                          'uid': FirebaseAuth.instance.currentUser!.uid,
                                        };
                                        await FirebaseFirestore.instance
                                            .collection('Events')
                                            .add(event);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Announcement created successfully!'),
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
  Widget showDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with App Bar
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 40, bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "MentorMate",
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



          // Menu Items
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
            onTap: () {},
          ),

          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

          // Logout
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

          // Version Info
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
  await FirebaseAuth.instance.signOut();
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
              insetPadding: EdgeInsets.all(16), // fixes overflow issues
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
                            // TITLE
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

                            // VENUE
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

                            // DATE + TIME PICKERS
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  // DATE PICKER
                                  ListTile(
                                    leading: Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                                    title: Text(
                                        '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year}'
                                    ),
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context, // FIXED
                                        initialDate: _meetingSelectedDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100), // FIXED (was 2025)
                                      );

                                      if (picked != null) {
                                        setState(() => _meetingSelectedDate = picked);
                                      }
                                    },
                                  ),

                                  // TIME PICKER
                                  ListTile(
                                    leading: Icon(Icons.access_time, color: Color(0xFF667eea)),
                                    title: Text(_meetingSelectedTime.format(context)),
                                    onTap: () async {
                                      final TimeOfDay? picked = await showTimePicker(
                                        context: context, // FIXED
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
                                        // GET MENTOR SIGNKEY
                                        final signkey = await getKey(currentUserId);
                                        final event = {
                                          'title': _meetingTitleController.text,
                                          'description':"Meeting reminder",
                                          'signkey':signkey,
                                          'dateTime': '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year} • ${_meetingSelectedTime.format(context)}',
                                          'uid': FirebaseAuth.instance.currentUser!.uid,
                                        };
                                        // GET MENTEES COUNT
                                        final menteesSnapshot = await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('role', isEqualTo: 'mentee')
                                            .where('mentor_id', isEqualTo: currentUserId)
                                            .get();

                                        int totalMentees = menteesSnapshot.docs.length;

                                        // SAVE MEETING
                                        await meetingsRef.add({
                                          'title': _meetingTitleController.text,
                                          'venue': _meetingVenueController.text,
                                          'date': '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year}',
                                          'time': _meetingSelectedTime.format(context),
                                          'dateTime': Timestamp.fromDate(_meetingSelectedDate),
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'createdBy': currentUserId,
                                          'signkey': signkey,
                                          'mentorId': currentUserId,
                                          'attendedStudents': [],
                                          'totalMentees': totalMentees,
                                          'attendancePercentage': 0.0,
                                        });


                                        await announcementsRef.add({
                                          'title': _meetingTitleController.text,
                                          'date': '${_meetingSelectedDate.day}/${_meetingSelectedDate.month}/${_meetingSelectedDate.year} • ${_meetingSelectedTime.format(context)}',
                                          'type': 'meeting',
                                          'venue': _meetingVenueController.text,
                                          'createdAt': FieldValue.serverTimestamp(),
                                          'createdBy': currentUserId,
                                          'signkey': signkey,
                                        });


                                        await FirebaseFirestore.instance
                                            .collection('Events')
                                            .add(event);

                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Meeting scheduled successfully!'),
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

                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: meetings.length,
                        itemBuilder: (context, index) {
                          final meeting = meetings[index];
                          final data = meeting.data() as Map<String, dynamic>;

                          final attendedCount = (data['attendedStudents'] as List?)?.length ?? 0;
                          final totalMentees = data['totalMentees'] ?? 15;
                          final percentage = data['attendancePercentage'] ?? 0.0;

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
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF667eea)),
                      radius: 20,
                    ),
                    SizedBox(width: 12),
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
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
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
          // Latest Meeting Attendance Card
          StreamBuilder<QuerySnapshot>(
            stream: meetingsRef
                .where('createdBy', isEqualTo: currentUserId)
                .orderBy('dateTime', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
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

              final meetings = snapshot.data!.docs;
              if (meetings.isEmpty) {
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

              final meeting = meetings.first;
              final data = meeting.data() as Map<String, dynamic>;
              final attendedCount = (data['attendedStudents'] as List?)?.length ?? 0;
              final totalMentees = data['totalMentees'] ?? 15;
              final percentage = data['attendancePercentage'] ?? 0.0;

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

          // Announcements & Upcoming Meetings Card
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
                  stream: announcementsRef
                      .where('createdBy', isEqualTo: currentUserId)
                      .orderBy('createdAt', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading announcements');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final announcements = snapshot.data!.docs;

                    if (announcements.isEmpty) {
                      return Text('No announcements yet');
                    }

                    return Column(
                      children: announcements.map((doc) {
                        final announcement = doc.data() as Map<String, dynamic>;
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
                                    color: Color(0xFF667eea).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    announcement['type'] == 'meeting'
                                        ? Icons.groups
                                        : Icons.announcement,
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
                                        announcement['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        announcement['date'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (announcement['venue'] != null) ...[
                                        SizedBox(height: 2),
                                        Text(
                                          'Venue: ${announcement['venue']}',
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
    "Clubs & Societies / CSOs (Student‑Run Clubs)",
    "Wits Food Programme / Wits Food Bank",
    "Campus Health & Wellness Centre (CHWC)",
    "Gender Equity Office (GEO)",
    "Disability Rights Unit (DRU)",
    "Wits Postgraduate Association (PGA)",
    "International Students Sub‑Council (ISSC)",
    "Wits Sports Council / Wits Sport",
    "Wits Vuvuzela (Student Newspaper)"
  ];

  final List<String> suggestions = [];
  bool _isLoading = false;
  bool _showResults = false;
  TextEditingController _mentorPromptController = TextEditingController();
  List<dynamic> _aiSuggestions = [];
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  String? path_url;
  String buildGeminiPrompt() {
    return """
You are an AI mentor assistant. Your task is to generate 3 mentorship session suggestions for university students.

Requirements:
1. Each suggestion must include:
   - "topic": a short title (1–7 words)
   - "description": 1–2 sentences explaining why this topic is relevant
   - "iceBreakers": 2–3 ice-breakers per topic
   - "resources": 3 general resources (websites, articles, apps, or provided institution resources if any)
2. Output must ALWAYS be JSON, structured exactly as:
{
  "suggestions": [
    {
      "topic": "string",
      "description": "string",
      "iceBreakers": ["string1", "string2", "string3"],
      "resources": ["string1", "string2", "string3"]
    },
    { "...": "3 topics total" }
  ]
}
3. Use the provided context to make the suggestions more relevant.
4. Keep content culturally neutral, safe, and appropriate for students. Avoid politics, religion, medical, or financial advice.

Context:
- Mentor Notes / Text: ${_mentorPromptController.text}
- Stored Topics: ${suggestions.join(', ')}
- Institution Resources: ${campusResources.join(', ')}

Now generate 3 relevant session suggestions based on the above context.
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
      print('Error fetching suggestions: $e');
    }
  }
  String? apiKey;
  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    await dotenv.load(fileName: ".env");
    apiKey = dotenv.get('GEMINI_API_KEY');
    path_url=dotenv.get('path_url');

    await loadSuggestions();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<Map<String, dynamic>> _callGeminiAPI(String prompt) async {
    // Load key
    final String? key = apiKey;
    final String? path=path_url;

    if (key == null || key.isEmpty) {
      throw Exception("❌ API key is NULL or EMPTY!");
    }



    final Uri uri = Uri.parse('$path?key=$key');

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 2048,
      }
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String textResponse =
      responseData['candidates'][0]['content']['parts'][0]['text'];
      return _parseGeminiResponse(textResponse);
    } else {
      throw Exception(
          'Failed to load suggestions: ${response.statusCode} | ${response.body}');
    }
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
      final Map<String, dynamic> response = await _callGeminiAPI(prompt);

      if (response.containsKey('suggestions') && response['suggestions'] is List) {
        setState(() {
          _aiSuggestions = response['suggestions'];
          _isLoading = false;
          _showResults = true;
        });
      } else {
        throw Exception('Invalid response format from AI');
      }

      // Auto-scroll to show new suggestions
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating suggestions: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      print('Error calling Gemini API: $e');
    }
  }
  Map<String, dynamic> _parseGeminiResponse(String textResponse) {
    try {
      // Clean the response - remove markdown code blocks if present
      String cleanResponse = textResponse.replaceAll('```json', '').replaceAll('```', '').trim();

      // Parse the JSON
      return jsonDecode(cleanResponse);
    } catch (e) {
      print('Error parsing Gemini response: $e');
      print('Raw response: $textResponse');
      throw Exception('Failed to parse AI response');
    }
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
              // Header Section - Always visible
              _buildHeader(),

              // Input Section - Only show when no results
              if (!_showResults) _buildInputSection(),

              // Content Section - Takes full space when results shown
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
                  'Session Topic Suggestions',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Mini retry button - Only show when results are visible
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
                ? 'AI-generated session topics for your mentee'
                : 'Get AI-powered session ideas for your mentees',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
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
                'Mentee Context',
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
              hintText: 'Enter context prompt for the session...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF667eea)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              helperText: 'Describe your mentee\'s current challenges, goals, or interests',
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
                    'Generate Session Topics',
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
          // Section Title - Only show when we have content
          if (_showResults || _isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF667eea), size: 24),
                  SizedBox(width: 8),
                  Text(
                    _isLoading ? 'Generating Topics...' : 'Suggested Session Topics',
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

          // Content with proper scrolling
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
              'Creating personalized session topics...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),

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
                'Ready to Generate Session Topics',
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
                  'Enter your mentee\'s context above to get AI-powered session topic suggestions tailored to their specific needs',
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
            // Context summary bar
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

            // Suggestions
            ..._aiSuggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return _buildSuggestionCard(suggestion, index);
            }).toList(),

            SizedBox(height: 20),

            // Retry button at bottom
            if (_showResults)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton.icon(
                  onPressed: _retryWithNewContext,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Search with Different Context'),
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

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF667eea).withOpacity(0.1),
                  Color(0xFF764ba2).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              suggestion['topic'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  suggestion['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),

                // Ice Breakers
                _buildSection(
                  icon: Icons.chat_bubble_outline,
                  title: 'Conversation Starters',
                  items: suggestion['iceBreakers'],
                ),
                SizedBox(height: 20),

                // Resources
                _buildSection(
                  icon: Icons.assignment_outlined,
                  title: 'Campus Resources',
                  items: suggestion['resources'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required List<dynamic> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chevron_right, size: 16, color: Color(0xFF667eea)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
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
  @override
  void initState() {
    super.initState();
    _loadEventsFromFirebase();
    _loadEventsFromFirebase2();
  }
  Future <String> getKey(String uid)async {
    DocumentSnapshot doc= await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['signkey'];
  }

  void _addEvent(DateTime date, String title, String description, TimeOfDay? time) async {
    DateTime finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    String? uid =await FirebaseAuth.instance.currentUser?.uid;
    final signKey=await  getKey(uid!);

    final event = {
      'title': title,
      'description': description,
      'signkey':signKey,
      'dateTime': finalDateTime,
      'uid': FirebaseAuth.instance.currentUser!.uid,
    };

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .add(event);

      Fluttertoast.showToast(
        msg: "Event added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to add event: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
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
                      SizedBox(height: 8),
                      if (event['time'] != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Color(0xFF667eea)),
                              SizedBox(width: 8),
                              Text(
                                (event['time'] as TimeOfDay).format(context),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        event['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
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
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  void _loadEventsFromFirebase() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final signKey=await getKey(uid);
    FirebaseFirestore.instance
        .collection('events')
        .where('uid', isEqualTo: uid)
        .where('signkey',isEqualTo: signKey)
        .snapshots()
        .listen((snapshot) {
      Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime dt = (data['dateTime'] as Timestamp).toDate();

        DateTime dayOnly = DateTime(dt.year, dt.month, dt.day);

        if (newEvents[dayOnly] == null) {
          newEvents[dayOnly] = [data];
        } else {
          newEvents[dayOnly]!.add(data);
        }
      }

      setState(() {
        _events = newEvents;
      });
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
      Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Parse the string date instead of treating it as Timestamp
        final String dateString = data['dateTime'] as String;
        final DateTime dt = _parseDateString(dateString);

        DateTime dayOnly = DateTime(dt.year, dt.month, dt.day);

        if (newEvents[dayOnly] == null) {
          newEvents[dayOnly] = [data];
        } else {
          newEvents[dayOnly]!.add(data);
        }
      }

      setState(() {
        _events = newEvents;
      });
    });
  }

  DateTime _parseDateString(String dateString) {
    try {
      // Handle "27/11/2025 • 12:01 AM" format
      if (dateString.contains('•')) {
        final parts = dateString.split('•');
        final datePart = parts[0].trim(); // "27/11/2025"
        final dateParts = datePart.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        return DateTime(year, month, day);
      }
      // Handle "23/11/2025" format
      else if (dateString.contains('/')) {
        final dateParts = dateString.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        return DateTime(year, month, day);
      }
      // Fallback
      return DateTime.now();
    } catch (e) {
      print('Error parsing date: $dateString');
      return DateTime.now();
    }
  }


  void _processAndUpdateEvents(List<QueryDocumentSnapshot> docs) {
    // Remove duplicates by document ID
    final uniqueDocs = docs.fold<Map<String, QueryDocumentSnapshot>>({}, (map, doc) {
      map[doc.id] = doc;
      return map;
    }).values.toList();

    Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

    for (var doc in uniqueDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final DateTime dt = (data['dateTime'] as Timestamp).toDate();
      DateTime dayOnly = DateTime(dt.year, dt.month, dt.day);

      if (newEvents[dayOnly] == null) {
        newEvents[dayOnly] = [data];
      } else {
        newEvents[dayOnly]!.add(data);
      }
    }

    setState(() {
      _events = newEvents;
    });
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
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2025, 12, 31),
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
                            _focusedDay = focusedDay;
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
                                  final time = event['time'] as TimeOfDay?;
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(Icons.event, color: Color(0xFF667eea)),
                                      title: Text(event['title']),
                                      subtitle: time != null
                                          ? Text(time.format(context))
                                          : null,
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

  @override
  void initState() {
    super.initState();
    _loadMenteesWithAttendance();
  }
  Future <String>getUsername()async{
    final uid=FirebaseAuth.instance.currentUser?.uid;
    DocumentSnapshot doc=await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc['fName']+" " +doc['lName'];
  }
  Future<void> _loadMenteesWithAttendance() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Loading mentees for mentor: $currentUserId');

      // Get all mentees assigned to this mentor using mentor_id
      final menteesSnapshot = await usersRef
          .where('role', isEqualTo: 'mentee')
          .where('mentor_id', isEqualTo: currentUserId)
          .get();

      print('Found ${menteesSnapshot.docs.length} mentees');

      // Get all meetings for this mentor
      final meetingsSnapshot = await meetingsRef
          .where('mentorId', isEqualTo: currentUserId)
          .get();

      print('Found ${meetingsSnapshot.docs.length} meetings');

      List<Map<String, dynamic>> menteesData = [];

      for (var menteeDoc in menteesSnapshot.docs) {
        final mentee = menteeDoc.data() as Map<String, dynamic>;
        final menteeId = menteeDoc.id;

        print('Processing mentee: ${mentee['fName']} ${mentee['lName']}');

        // Calculate attendance for this mentee
        final attendanceData = await _calculateMenteeAttendance(menteeId, meetingsSnapshot.docs);

        menteesData.add({
          'id': menteeId,
          'name': mentee['fName'] ?? '',
          'surname': mentee['lName'] ?? '',
          'studentNumber': mentee['studentNo'] ?? '',
          'email': mentee['email'] ?? '',
          'profileImage': mentee['profile'] ?? 'https://via.placeholder.com/100',
          ...attendanceData,
        });
      }

      setState(() {
        _menteesWithAttendance = menteesData;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading mentees: $e');
      setState(() {
        _errorMessage = 'Error loading mentees: $e';
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

    // Sort meetings by date (newest first)
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
                              // Overview Tab
                              SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Student Info
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(mentee['profileImage']),
                                            backgroundColor: Colors.grey[200],
                                          ),
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

                                    // Attendance Stats
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
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(mentee['profileImage']),
                            backgroundColor: Colors.grey[200],
                          ),
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
      print('Error loading mentee data: $e');
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF667eea)),
                  radius: 20,
                ),
                SizedBox(width: 12),
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
          // Header with App Bar
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 40, bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "MentorMate",
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

          // User Profile Section
          Container(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: Colors.blue.shade700),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "John Doe", // Replace with actual user name
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Mentor", // Replace with user role
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          // Menu Items
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
            onTap: () {},
          ),

          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

          // Logout
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

          // Version Info
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

  // Helper method to build consistent menu items
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
    await FirebaseAuth.instance.signOut();
  }
  // Logout confirmation dialog
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
          // Today's Overview Card
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
                // Simplified stats without complex queries
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

          // Latest Announcements Card - SIMPLIFIED QUERY
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
                      'Latest Announcements',
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
                  stream: announcementsRef.snapshots(), // Simple query without filters
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading announcements');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final allAnnouncements = snapshot.data!.docs;

                    // Filter locally by signkey
                    final announcements = allAnnouncements.where((doc) {
                      final announcement = doc.data() as Map<String, dynamic>;
                      return announcement['signkey'] == _menteeSignKey;
                    }).toList();

                    if (announcements.isEmpty) {
                      return Text('No announcements yet');
                    }

                    // Sort locally by createdAt
                    announcements.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      return (bTime ?? Timestamp.now()).compareTo(aTime ?? Timestamp.now());
                    });

                    final recentAnnouncements = announcements.take(5).toList();

                    return Column(
                      children: recentAnnouncements.map((doc) {
                        final announcement = doc.data() as Map<String, dynamic>;
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
                                        color: Color(0xFF667eea).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        announcement['type'] == 'meeting'
                                            ? Icons.groups
                                            : Icons.announcement,
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
                                            announcement['title'] ?? 'No Title',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          Text(
                                            announcement['date'] ?? '',
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
                                if (announcement['description'] != null) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    announcement['description'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                                if (announcement['venue'] != null) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Venue: ${announcement['venue']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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

          // Upcoming Meetings Card - SIMPLIFIED QUERY
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
                    Icon(Icons.upcoming, color: Color(0xFF667eea)),
                    SizedBox(width: 8),
                    Text(
                      'Upcoming Meetings',
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
                  stream: meetingsRef.snapshots(), // Simple query without filters
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading meetings');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final allMeetings = snapshot.data!.docs;

                    // Filter locally by mentorId and future dates
                    final meetings = allMeetings.where((doc) {
                      final meeting = doc.data() as Map<String, dynamic>;
                      final isMyMentor = meeting['mentorId'] == _mentorId;
                      final dateTime = meeting['dateTime'] as Timestamp?;
                      final isFuture = dateTime != null &&
                          dateTime.toDate().isAfter(DateTime.now());
                      return isMyMentor && isFuture;
                    }).toList();

                    if (meetings.isEmpty) {
                      return Text('No upcoming meetings');
                    }

                    // Sort locally by dateTime
                    meetings.sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['dateTime'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['dateTime'] as Timestamp?;
                      return (aTime ?? Timestamp.now()).compareTo(bTime ?? Timestamp.now());
                    });

                    final upcomingMeetings = meetings.take(5).toList();

                    return Column(
                      children: upcomingMeetings.map((doc) {
                        final meeting = doc.data() as Map<String, dynamic>;
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
                                    color: Color(0xFF667eea).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.groups,
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
                                        meeting['title'] ?? 'No Title',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        '${meeting['date']} • ${meeting['time']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Venue: ${meeting['venue']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegistersContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: registersRef.snapshots(), // Simple query without filters
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading registers'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final allRegisters = snapshot.data!.docs;

        // Filter locally by mentorId and expiration
        final registers = allRegisters.where((doc) {
          final register = doc.data() as Map<String, dynamic>;
          final isMyMentor = register['mentorId'] == _mentorId;
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
      // 1. Update the register table - add user to attendedStudents
      await registersRef.doc(registerId).update({
        'attendedStudents': FieldValue.arrayUnion([userId])
      });

      // 2. Get the meeting ID from register data
      final meetingId = registerData['meetingId'];
      if (meetingId != null) {
        // 3. Get the current meeting data
        final meetingDoc = await meetingsRef.doc(meetingId).get();
        if (meetingDoc.exists) {
          final meetingData = meetingDoc.data() as Map<String, dynamic>;
          final currentAttendedStudents = List<String>.from(meetingData['attendedStudents'] ?? []);
          final totalMentees = meetingData['totalMentees'] ?? 1;

          // 4. Add user to meeting's attendedStudents if not already there
          if (!currentAttendedStudents.contains(userId)) {
            currentAttendedStudents.add(userId);

            // 5. Calculate new attendance percentage
            final newAttendancePercentage = (currentAttendedStudents.length / totalMentees) * 100;

            // 6. Update meeting table
            await meetingsRef.doc(meetingId).update({
              'attendedStudents': currentAttendedStudents,
              'attendancePercentage': newAttendancePercentage,
            });
          }
        }
      }

      // Show success message
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
          // Search Section
          _buildSearchSection(),

          // Suggestions List
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
      future: getKey(FirebaseAuth.instance.currentUser!.uid), // Your exact method
      builder: (context, keySnapshot) {
        // Handle signKey loading states
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

        // Now use the signKey in your StreamBuilder
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
              return Center(child: Text('Error loading suggestions'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            var suggestions = snapshot.data!.docs;

            // Apply search filter
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
              // Suggestion Text
              Text(
                suggestion,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),

              // Date and Delete Button
              Row(
                children: [
                  // Date
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

                  // Delete Button
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
  void submit()async{
    final uid=await FirebaseAuth.instance.currentUser?.uid;
    final signkey=await getKey(uid!);
    await FirebaseFirestore.instance.collection('suggestions').add({
      'suggestion': _topicController.text,
      'signkey':signkey,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    });
    Fluttertoast.showToast(msg: "Suggestion added successfully.",toastLength:Toast.LENGTH_SHORT,gravity:ToastGravity.BOTTOM);
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

    // Simulate submission
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isSubmitting = false;
      });

      // Add to recent suggestions
      setState(() {
        submit();
      });

      // Show success
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
                      'Thanks! 👍',
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
                'Suggest Topics',
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
                      // Quick examples
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

                      // Main input area
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
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: "John Doe");
  final TextEditingController _emailController = TextEditingController(text: "john.doe@email.com");
  final TextEditingController _bioController = TextEditingController(text: "Experienced mobile developer passionate about mentoring and sharing knowledge with aspiring developers.");
  final TextEditingController _skillsController = TextEditingController(text: "Flutter, Dart, UI/UX, Mobile Development");

  String _role = "Mentor";
  String _experience = "3-5 years";
  bool _isEditing = false;
  String _profileImageUrl = ""; // Add your image URL here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Save profile changes
                  _saveProfile();
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header with Picture
            _buildProfileHeader(),
            SizedBox(height: 32),

            // Personal Information
            _buildSectionHeader("Personal Information"),
            _buildInfoCard(),
            SizedBox(height: 24),


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
              ),
              child: ClipOval(
                child: _profileImageUrl.isEmpty
                    ? Container(
                  color: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                )
                    : Image.network(
                  _profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
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
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  onPressed: _changeProfilePicture,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          _nameController.text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _role == "Mentor" ? Colors.blue.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _role == "Mentor" ? Colors.blue.shade200 : Colors.green.shade200,
            ),
          ),
          child: Text(
            _role,
            style: TextStyle(
              color: _role == "Mentor" ? Colors.blue.shade700 : Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEditableField(
              label: "Full Name",
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            SizedBox(height: 16),
            _buildEditableField(
              label: "Email Address",
              controller: _emailController,
              icon: Icons.email_outlined,
              isEmail: true,
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isEmail = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              TextField(
                controller: controller,
                readOnly: !_isEditing,
                keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: value,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  // Implement image picker from gallery
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  // Implement camera functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text("Remove Photo", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImageUrl = "";
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    // Implement your profile saving logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
}
