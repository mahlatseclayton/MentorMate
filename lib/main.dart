import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'package:hexcolor/hexcolor.dart';

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
  final _signkeyController = TextEditingController();
  String _selectedRole = 'mentee';
  @override
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
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';//hide this key
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
      Fluttertoast.showToast(msg: "Passwords do not match");
      return;
    }

    try {

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = FirebaseAuth.instance.currentUser;
      String? uid = user?.uid;

      if (uid == null) {
        Fluttertoast.showToast(msg: "Account creation failed.");
        return;
      }
      Map<String, dynamic> userData = {
        'fName': fName,
        'lName': lName,
        'role': _selectedRole,
        'studentNo': _studentNumberController.text,
        'email':_studentNumberController.text+'@students.wits.ac.za',
        'profile': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_selectedRole == 'mentor') {
        String signkey = _generateSignKey();
        userData['signkey'] = signkey;

        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
        _showMentorSignKeyDialog(signkey);

      } else if (_selectedRole == 'mentee') {
        if (_signkeyController.text.isEmpty) {
          Fluttertoast.showToast(msg: "Please enter your mentor's signkey");
          return;
        }

        String? mentorId = await _findMentorBySignKey(_signkeyController.text);
        if (mentorId == null) {
          Fluttertoast.showToast(msg: "Invalid signkey. Please check with your mentor.");
          return;
        }

        userData['mentor_id'] = mentorId;
        userData['signkey'] = _signkeyController.text;

        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
      }

      if (user != null) {
        await user.sendEmailVerification();
        await user.reload();
        Fluttertoast.showToast(
          msg: "Account created! Check your email to verify your account.",
          toastLength: Toast.LENGTH_LONG,
        );
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignInPage()),
        );

      } else {
        Fluttertoast.showToast(msg: "Failed to send verification email.");
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: "Password is too weak.");
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: "Student number already exists.");
      } else {
        Fluttertoast.showToast(msg: e.message ?? "Unknown error occurred.");
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
Future<bool> getConfirm()async{
  User? user= FirebaseAuth.instance.currentUser;
      bool isConfirm=user?.emailVerified ??false;
   return isConfirm;

}

  Future<void> initializeFCMToken() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }
  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _login()async{
    String email=_studentNumberController.text+"@students.wits.ac.za";
    String password=_passwordController.text;
    // bool  c=await getConfirm();
    bool c=true;

    String? uid;
    try {

          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          uid=FirebaseAuth.instance.currentUser?.uid;
          DocumentSnapshot doc=await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if(c==true){
            Fluttertoast.showToast(msg: "Login successful.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM);
            if(doc['role']=='mentee'){


              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MenteeHomePage()));
            }
            else{
              Navigator.push(context, MaterialPageRoute(builder: (_)=>MentorHomePage()));
            }
            initializeFCMToken();
          }
          else{
            Fluttertoast.showToast(msg: "Verify your email to log in.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM);
            return;
          }


    }on FirebaseAuthException catch(e){
        Fluttertoast.showToast(msg: "Incorrect password or student number ");
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
  await FirebaseAuth.instance.signOut();
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
    }
  }
  Map<String, dynamic> _parseGeminiResponse(String textResponse) {
    try {
      String cleanResponse = textResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanResponse);
    } catch (e) {
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
                  'Session Topic Suggestions',
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
              return _buildSuggestionCard(suggestion, index);
            }).toList(),

            SizedBox(height: 20),
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                _buildSection(
                  icon: Icons.chat_bubble_outline,
                  title: 'Conversation Starters',
                  items: suggestion['iceBreakers'],
                ),
                SizedBox(height: 20),
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

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirebase();
    _loadEventsFromFirebase2();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveFCMToken);
  }

  Future<void> _saveFCMToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
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
    String formattedDateTime = '${date.day}/${date.month}/${date.year} • ${time != null ? time.format(context) : 'All Day'}';
    final event = {
      'title': title,
      'description': description,
      'signkey': signKey,
      'dateTime': formattedDateTime,
      'timestamp': Timestamp.fromDate(finalDateTime),
      'isoDate': finalDateTime.toIso8601String(), // Add ISO format for consistent parsing
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'calendar_event',
    };

    try {
      await FirebaseFirestore.instance
          .collection('Events')
          .add(event);
      await FirebaseFirestore.instance
          .collection('events')
          .add({
        'title': title,
        'description': description,
        'signkey': signKey,
        'dateTime': Timestamp.fromDate(finalDateTime),
        'isoDate': finalDateTime.toIso8601String(),
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
      final menteesSnapshot = await usersRef
          .where('role', isEqualTo: 'mentee')
          .where('mentor_id', isEqualTo: currentUserId)
          .get();
      final meetingsSnapshot = await meetingsRef
          .where('mentorId', isEqualTo: currentUserId)
          .get();
      List<Map<String, dynamic>> menteesData = [];
      Map<String, String> profileImages = {};

      for (var menteeDoc in menteesSnapshot.docs) {
        final mentee = menteeDoc.data() as Map<String, dynamic>;
        final menteeId = menteeDoc.id;
        profileImages[menteeId] = mentee['profile'] ?? '';
        final attendanceData = await _calculateMenteeAttendance(menteeId, meetingsSnapshot.docs);
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
    await FirebaseAuth.instance.signOut();
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
                  stream: announcementsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading announcements');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final allAnnouncements = snapshot.data!.docs;
                    final announcements = allAnnouncements.where((doc) {
                      final announcement = doc.data() as Map<String, dynamic>;
                      return announcement['signkey'] == _menteeSignKey;
                    }).toList();

                    if (announcements.isEmpty) {
                      return Text('No announcements yet');
                    }
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

  // CopyWith method
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
  // Profile Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _role = "";
  bool _isEditing = false;
  String _profileImageUrl = "";
  bool _isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();

  // Timetable Variables
  DateTime _currentWeekStart = DateTime.now();
  bool _isEditingTimetable = false;

  // Time slots from 6:00 AM to 6:00 PM
  final List<String> _timeSlots = [
    '6:00', '7:00', '8:00', '9:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
  ];

  // Days of the week
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Full day names
  final Map<String, String> _fullDayNames = {
    'Mon': 'Monday',
    'Tue': 'Tuesday',
    'Wed': 'Wednesday',
    'Thu': 'Thursday',
    'Fri': 'Friday',
    'Sat': 'Saturday',
    'Sun': 'Sunday',
  };

  // Firebase Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfilePicture();
    // Adjust to start of current week (Monday)
    _currentWeekStart = _getStartOfWeek(DateTime.now());
  }

  // Helper to get Monday of the week
  DateTime _getStartOfWeek(DateTime date) {
    // Monday is 1 in Dart (Monday = 1, Sunday = 7)
    int dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  // Get dates for the current week
  List<DateTime> _getWeekDates() {
    List<DateTime> weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(_currentWeekStart.add(Duration(days: i)));
    }
    return weekDates;
  }

  // =============== PROFILE METHODS ===============

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
      // Silently fail - use default avatar
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

  Future<String?> getUserKey() async {
    final uid = _auth.currentUser?.uid;
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc['userKey'];
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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadImageToFirebase(File(image.path));
      }
    } catch (e) {
      _showSnackBar('Failed to pick image', isError: true);
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      final userId = _auth.currentUser!.uid;
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      _showSnackBar('Uploading image...', showProgress: true);

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await _saveImageUrlToFirestore(downloadUrl);
      setState(() {
        _profileImageUrl = downloadUrl;
      });

      _hideCurrentSnackBar();
      _showSnackBar('Profile picture updated successfully!');
    } catch (e) {
      _hideCurrentSnackBar();
      _showSnackBar('Failed to upload image', isError: true);
    }
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'profile': imageUrl});
    } catch (e) {
      throw e;
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
        _showSnackBar('Removing...', showProgress: true);

        await _firestore.collection('users').doc(userId).update({
          'profile': FieldValue.delete(),
        });

        setState(() {
          _profileImageUrl = "";
        });

        _hideCurrentSnackBar();
        _showSnackBar('Profile picture removed!');
      }
    } catch (e) {
      _hideCurrentSnackBar();
      _showSnackBar('Failed to remove picture', isError: true);
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
    _showSnackBar('Profile updated successfully!');
  }

  // =============== TIMETABLE METHODS ===============

  Future<void> _addTimetableEvent(TimetableEvent event) async {
    try {
      await _firestore.collection('timetable_events').doc(event.id).set(event.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> _updateTimetableEvent(TimetableEvent event) async {
    try {
      await _firestore.collection('timetable_events').doc(event.id).update(event.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> _deleteTimetableEvent(String eventId) async {
    try {
      await _firestore.collection('timetable_events').doc(eventId).delete();
    } catch (e) {
      throw e;
    }
  }

  // Get all events for the current week
  Stream<List<TimetableEvent>> _getWeeklyTimetableEvents() {
    final userId = _auth.currentUser!.uid;
    final weekStart = DateFormat('yyyy-MM-dd').format(_currentWeekStart);
    final weekEnd = DateFormat('yyyy-MM-dd').format(_currentWeekStart.add(const Duration(days: 6)));

    return _firestore
        .collection('timetable_events')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: weekStart)
        .where('date', isLessThanOrEqualTo: weekEnd)
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TimetableEvent.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  void _showAddEventDialog({TimetableEvent? existingEvent, String? day, TimeOfDay? presetTime}) async {
    final weekDates = _getWeekDates();
    final selectedDate = existingEvent?.date ??
        (day != null ? weekDates[_days.indexOf(day)] : weekDates[0]);

    final result = await showDialog(
      context: context,
      builder: (context) => AddTimetableEventDialog(
        existingEvent: existingEvent,
        selectedDate: selectedDate,
        presetTime: presetTime,
        onSave: _handleSaveEvent,
        onDelete: existingEvent != null ? () => _handleDeleteEvent(existingEvent.id) : null,
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _handleSaveEvent(TimetableEvent event) async {
    try {
      if (event.id.isEmpty) {
        event = event.copyWith(id: _uuid.v4());
        await _addTimetableEvent(event);
        _showSnackBar('Event added successfully!');
      } else {
        await _updateTimetableEvent(event);
        _showSnackBar('Event updated successfully!');
      }
    } catch (e) {
      _showSnackBar('Error saving event: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleDeleteEvent(String eventId) async {
    try {
      bool? shouldDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        await _deleteTimetableEvent(eventId);
        _showSnackBar('Event deleted successfully!');
        setState(() {});
      }
    } catch (e) {
      _showSnackBar('Error deleting event', isError: true);
    }
  }

  // Helper to format time for display
  String _formatTimeForDisplay(String time) {
    final hour = int.parse(time.split(':')[0]);
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$time AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12}:00 PM';
  }

  // =============== HELPER METHODS ===============

  void _showSnackBar(String message, {bool isError = false, bool showProgress = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: showProgress
            ? Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        )
            : Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: showProgress ? const Duration(minutes: 1) : const Duration(seconds: 3),
      ),
    );
  }

  void _hideCurrentSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // =============== WIDGET BUILDERS ===============

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
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionHeader("Personal Information"),
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildWeeklyTimetableSection(),
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        padding: const EdgeInsets.only(bottom: 8),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReadOnlyField(
              label: "Full Name",
              value: _nameController.text,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              label: "Email Address",
              value: _emailController.text,
              icon: Icons.email_outlined,
            ),
          ],
        ),
      ),
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
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTimetableSection() {
    final weekDates = _getWeekDates();
    final formattedWeekRange = '${DateFormat('MMM d').format(weekDates.first)} - ${DateFormat('MMM d').format(weekDates.last)}';

    return Column(
      children: [
        _buildSectionHeader("Weekly Timetable"),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Week navigation and Edit button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            formattedWeekRange,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy').format(weekDates.first),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(_isEditingTimetable ? Icons.check : Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditingTimetable = !_isEditingTimetable;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Weekly Timetable View
                StreamBuilder<List<TimetableEvent>>(
                  stream: _getWeeklyTimetableEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final events = snapshot.data ?? [];

                    return _buildWeeklyTimetableGrid(events, weekDates);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTimetableGrid(List<TimetableEvent> events, List<DateTime> weekDates) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 700),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with days
              Container(
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Empty corner cell
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.grey.shade100,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Day headers
                    ..._days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final date = weekDates[index];

                      return Container(
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                          color: date.weekday == DateTime.saturday || date.weekday == DateTime.sunday
                              ? Colors.grey.shade50
                              : Colors.white,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _fullDayNames[day]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: date.weekday == DateTime.saturday || date.weekday == DateTime.sunday
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              DateFormat('MMM d').format(date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // Time slots and events
              ..._timeSlots.asMap().entries.map((timeEntry) {
                final timeIndex = timeEntry.key;
                final time = timeEntry.value;
                final hour = int.parse(time.split(':')[0]);

                return Container(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Time slot label
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTimeForDisplay(time),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (timeIndex < _timeSlots.length - 1)
                              Text(
                                'to ${_formatTimeForDisplay(_timeSlots[timeIndex + 1])}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Day cells for this time slot
                      ..._days.asMap().entries.map((dayEntry) {
                        final dayIndex = dayEntry.key;
                        final day = dayEntry.value;
                        final date = weekDates[dayIndex];

                        // Find events for this time slot and day
                        final cellEvents = events.where((event) {
                          final eventDay = DateFormat('EEE').format(event.date);
                          final eventStartHour = event.startTime.hour;
                          final eventEndHour = event.endTime.hour;

                          return eventDay == day &&
                              eventStartHour <= hour &&
                              eventEndHour > hour;
                        }).toList();

                        return GestureDetector(
                          onTap: _isEditingTimetable ? () {
                            final presetTime = TimeOfDay(hour: hour, minute: 0);
                            _showAddEventDialog(day: day, presetTime: presetTime);
                          } : null,
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              color: date.weekday == DateTime.saturday || date.weekday == DateTime.sunday
                                  ? Colors.grey.shade50
                                  : Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: cellEvents.isEmpty
                                ? _isEditingTimetable
                                ? Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.blue.shade300,
                                size: 20,
                              ),
                            )
                                : null
                                : _buildEventCell(cellEvents.first),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCell(TimetableEvent event) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor(event.color).withOpacity(0.2),
        border: Border.all(color: HexColor(event.color)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            '${event.startTime.format(context)} - ${event.endTime.format(context)}',
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
                fontSize: 8,
                color: HexColor(event.color),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
class AddTimetableEventDialog extends StatefulWidget {
  final TimetableEvent? existingEvent;
  final DateTime selectedDate;
  final TimeOfDay? presetTime;
  final Function(TimetableEvent) onSave;
  final Function()? onDelete;

  const AddTimetableEventDialog({
    super.key,
    this.existingEvent,
    required this.selectedDate,
    this.presetTime,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AddTimetableEventDialog> createState() => _AddTimetableEventDialogState();
}
class _AddTimetableEventDialogState extends State<AddTimetableEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _selectedColor = '#4CAF50';

  final List<String> _colors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingEvent != null) {
      _titleController.text = widget.existingEvent!.title;
      _descriptionController.text = widget.existingEvent!.description;
      _startTime = widget.existingEvent!.startTime;
      _endTime = widget.existingEvent!.endTime;
      _selectedColor = widget.existingEvent!.color;
    } else if (widget.presetTime != null) {
      _startTime = widget.presetTime!;
      _endTime = TimeOfDay(
        hour: widget.presetTime!.hour + 1,
        minute: widget.presetTime!.minute,
      );
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      initialEntryMode: TimePickerEntryMode.input,
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
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = FirebaseAuth.instance;
        final firestore = FirebaseFirestore.instance;

        // Get user key from Firestore
        final userDoc = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get();

        final userKey = userDoc['signkey'] ?? auth.currentUser!.uid;

        final event = TimetableEvent(
          id: widget.existingEvent?.id ?? '',
          userId: auth.currentUser!.uid,
          signkey: userKey,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          date: widget.selectedDate,
          startTime: _startTime,
          endTime: _endTime,
          color: _selectedColor,
          day: DateFormat('EEE').format(widget.selectedDate),
        );

        await widget.onSave(event);
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingEvent == null ? 'Add Timetable Event' : 'Edit Event',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Start Time *'),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: _selectStartTime,
                                    child: Text(
                                      _startTime.format(context),
                                      style: const TextStyle(fontSize: 16),
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
                                  const Text('End Time *'),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: _selectEndTime,
                                    child: Text(
                                      _endTime.format(context),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Color'),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _colors.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final color = _colors[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                      });
                                    },
                                    child: Container(
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
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${DateFormat('EEE, MMM d, yyyy').format(widget.selectedDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: () {
                        widget.onDelete!();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveEvent,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
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
              'Welcome to your MentorMate dashboard! This comprehensive guide will help you '
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
            _buildDeveloperCredit(),
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

  Widget _buildDeveloperCredit() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.developer_mode,
            size: 40,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 12),
          Text(
            'MentorMate Platform Developed by',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mahlatse Clayton Maredi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),

          SizedBox(height: 4),
          Text(
            'Dedicated to enhancing mentorship through technology',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
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
            _buildSectionHeader('Welcome to MentorMate'),
            _buildInfoCard(
              'MentorMate is your dedicated platform for connecting with mentors, '
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
            _buildDeveloperCredit(),
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

  Widget _buildDeveloperCredit() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.developer_mode,
            size: 40,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 12),
          Text(
            'MentorMate Platform Developed by',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mahlatse Clayton Maredi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),

          SizedBox(height: 4),
          Text(
            'Dedicated to enhancing mentorship through technology',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
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
        return 2; // At least tomorrow
      case MeetingFrequency.weekly:
        return 7; // At least 1 week ahead
      case MeetingFrequency.biWeekly:
        return 14; // At least 2 weeks ahead
      case MeetingFrequency.monthly:
        return 30; // At least 1 month ahead
      case MeetingFrequency.quarterly:
        return 90; // At least 3 months ahead
      case MeetingFrequency.custom:
        return 7; // Default 1 week ahead
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
    // Convert times to 24-hour format
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
  static String? _apiKey;
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  // Private initialization method
  static Future<void> _initializeApiKey() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      // Get API key from environment
      _apiKey = dotenv.get('GEMINI_API_KEY');

      // Validate API key
      if (_apiKey == null || _apiKey!.isEmpty) {
        print('GEMINI_API_KEY not found in .env file');
        throw Exception('GEMINI_API_KEY not found in .env file');
      }

      // Check if API key looks valid
      if (!_apiKey!.startsWith('AIza')) {
        print('Warning: API key may be invalid. Expected to start with "AIza"');
      }

      _isInitialized = true;
      print('GeminiMeetingSuggestionEngine initialized successfully');
    } catch (e) {
      print('Error initializing Gemini API key: $e');
      _apiKey = null;
    } finally {
      _isInitializing = false;
    }
  }

  // Public method to ensure API key is loaded
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeApiKey();
    }
  }

  // Getter for API key that ensures initialization
  static Future<String?> get apiKey async {
    if (!_isInitialized) {
      await ensureInitialized();
    }
    return _apiKey;
  }

  // Main method to find optimal meeting times
  static Future<List<Map<String, dynamic>>> findOptimalTimesWithAI({
    required List<CombinedScheduleEvent> allEvents,
    required MeetingFrequency frequency,
    required String userSignkey,
    required String meetingTitle,
    required TimePreferences timePreferences,
    int numberOfSuggestions = 3,
  }) async {
    // Ensure API key is initialized
    try {
      await ensureInitialized();
    } catch (e) {
      print('Failed to initialize Gemini: $e');
    }

    final currentApiKey = await _getValidApiKey();
    if (currentApiKey == null) {
      print('Cannot proceed without valid API key, using fallback suggestions');
      return _getFallbackSuggestions(
        allEvents,
        frequency,
        timePreferences,
        _generateCandidateDates(frequency),
        numberOfSuggestions,
      );
    }

    try {
      final now = DateTime.now();
      final candidateDates = _generateCandidateDates(frequency);

      // Prepare data for Gemini
      final prompt = _buildPrompt(
        allEvents: allEvents,
        frequency: frequency,
        userSignkey: userSignkey,
        meetingTitle: meetingTitle,
        timePreferences: timePreferences,
        numberOfSuggestions: numberOfSuggestions,
        now: now,
        candidateDates: candidateDates,
      );

      print('Sending request to Gemini API...');
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$currentApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        print('Gemini API response received successfully');
        return _parseGeminiResponse(
          response.body,
          now,
          frequency,
          numberOfSuggestions,
          allEvents,
          timePreferences,
          candidateDates,
        );
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return _getFallbackSuggestions(
          allEvents,
          frequency,
          timePreferences,
          candidateDates,
          numberOfSuggestions,
        );
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return _getFallbackSuggestions(
        allEvents,
        frequency,
        timePreferences,
        _generateCandidateDates(frequency),
        numberOfSuggestions,
      );
    }
  }

  // Helper method to get valid API key
  static Future<String?> _getValidApiKey() async {
    if (!_isInitialized) {
      try {
        await ensureInitialized();
      } catch (e) {
        print('Failed to ensure initialization: $e');
        return null;
      }
    }

    // Check if API key is valid
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('API key is null or empty');
      return null;
    }

    // Additional validation
    if (_apiKey!.length < 20) {
      print('API key appears too short: ${_apiKey!.length} characters');
      return null;
    }

    return _apiKey;
  }

  // Generate candidate dates
  static List<DateTime> _generateCandidateDates(MeetingFrequency frequency) {
    final now = DateTime.now();
    final minStartDate = now.add(Duration(days: frequency.minDaysAhead));
    final List<DateTime> dates = [];

    for (int i = frequency.minDaysAhead; i <= 90; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      if (date.weekday != DateTime.sunday) {
        dates.add(date);
      }
    }

    return dates;
  }

  // Build prompt for Gemini
  static String _buildPrompt({
    required List<CombinedScheduleEvent> allEvents,
    required MeetingFrequency frequency,
    required String userSignkey,
    required String meetingTitle,
    required TimePreferences timePreferences,
    required int numberOfSuggestions,
    required DateTime now,
    required List<DateTime> candidateDates,
  }) {
    final eventsJson = allEvents.map((e) => e.toJson()).toList();
    final durationMinutes = timePreferences.meetingDuration?.inMinutes ?? 60;
    final hasTimeRange = timePreferences.hasTimeRange;
    final startTimeStr = hasTimeRange ? timePreferences.preferredStartTime!.format24Hour() : '';
    final endTimeStr = hasTimeRange ? timePreferences.preferredEndTime!.format24Hour() : '';
    final minStartDate = now.add(Duration(days: frequency.minDaysAhead));

    return '''
You are an AI meeting scheduler. Analyze the provided schedule data and suggest the ${numberOfSuggestions} best meeting times.

CRITICAL RULES:
1. NEVER suggest meetings on Sundays (weekday == 7)
2. ${hasTimeRange ? 'Only suggest times within the preferred time range: $startTimeStr to $endTimeStr' : 'Any time between 8:00 and 20:00 is acceptable'}
3. All suggestions MUST be at least ${frequency.minDaysAhead} days ahead of today
4. Use 24-hour format for all times (e.g., "14:30" not "2:30 PM")

Meeting Frequency: ${frequency.title} (${frequency.description})
Minimum days ahead required: ${frequency.minDaysAhead} days
Earliest acceptable date: ${DateFormat('yyyy-MM-dd').format(minStartDate)}
Plan meetings sufficiently ahead for proper scheduling

Current Date: ${DateFormat('yyyy-MM-dd').format(now)}
Meeting Title: $meetingTitle
User Signkey: $userSignkey
Meeting Duration: $durationMinutes minutes

User Preferences:
- Preferred Time Range: ${hasTimeRange ? '$startTimeStr to $endTimeStr' : 'Any time'}
- Meeting Duration: $durationMinutes minutes

Schedule Data (next 90 days):
${jsonEncode(eventsJson)}

ANALYSIS REQUIREMENTS:
1. CRITICAL: Consider PARTIALLY BOOKED days - find available time slots between existing events
2. STRICT PRIORITY: Find slots that can accommodate the FULL $durationMinutes minutes meeting duration
3. When checking partially booked days:
   - Look for gaps between existing events that are at least $durationMinutes minutes long
   - Consider time before first event of the day (if it starts late enough)
   - Consider time after last event of the day (if it ends early enough)
   - Consider gaps between consecutive events
4. Ensure the time slot has no conflicts for the ENTIRE duration
5. Try to match user preferences exactly first
6. If exact preferences not available, fall back to intelligent scheduling
7. Avoid dates with existing events for the same signkey (especially timetable_events)
8. Avoid dates where mentees (same signkey) have timetable events
9. Calculate a confidence score (0-100) based on:
    - Slot accommodates full $durationMinutes minutes: +50 points
    - Matches exact time preference: +30 points
    - Within preferred time range: +25 points
    - No conflicts: +40 points
    - Found gap in partially booked day: +35 points
    - Weekday (Monday-Friday): +20 points
    - Weekend (Saturday): -30 points
    - Sunday: -100 points (NOT ALLOWED)
    - Each existing event on that date: -15 points (but still consider gaps)
    - Mentee conflicts: -40 points each
    - Proximity to ideal scheduling time (not too soon, not too late): 
        - ${frequency.minDaysAhead} to ${frequency.minDaysAhead * 2} days ahead: +30 points
        - ${frequency.minDaysAhead * 2 + 1} to ${frequency.minDaysAhead * 3} days ahead: +25 points
        - More than ${frequency.minDaysAhead * 3} days ahead: +15 points
        - Less than ${frequency.minDaysAhead} days ahead: -100 points (NOT ALLOWED)
    - ${hasTimeRange ? 'Outside preferred time range: -15 points' : 'No penalty for time range'}
    - Slot too short for $durationMinutes minutes: -100 points

TIME SLOT ANALYSIS RULES:
- For each day, sort events by start time
- Check if there's enough time BEFORE the first event (if first event starts after 8:00 AM)
- Check gaps BETWEEN consecutive events (end time of event 1 to start time of event 2)
- Check if there's enough time AFTER the last event (if last event ends before 8:00 PM)
- Minimum gap needed: $durationMinutes minutes
- Time range constraint: ${hasTimeRange ? 'MUST be between $startTimeStr and $endTimeStr' : 'Should be between 8:00 and 20:00'}

OUTPUT FORMAT (JSON only, no markdown):
{
  "suggestions": [
    {
      "date": "2025-12-22",  // MUST be after ${DateFormat('yyyy-MM-dd').format(minStartDate)} and NOT Sunday
      "time": "10:00",  // MUST be in 24-hour format
      "score": 95,
      "conflicts": 0,
      "reasoning": "Brief explanation including why this date fits the frequency pattern",
      "matchesPreferences": true/false,
      "preferenceMatches": ["time", "duration"],
      "foundInGap": true/false,
      "daysAhead": 14  // How many days from today
    }
  ]
}

Return exactly ${numberOfSuggestions} suggestions sorted by score (highest first).
CRITICAL: All suggestions MUST be at least ${frequency.minDaysAhead} days ahead of today and NOT on Sundays.
''';
  }

  // Parse Gemini response
  static Future<List<Map<String, dynamic>>> _parseGeminiResponse(
      String responseBody,
      DateTime now,
      MeetingFrequency frequency,
      int numberOfSuggestions,
      List<CombinedScheduleEvent> allEvents,
      TimePreferences timePreferences,
      List<DateTime> candidateDates,
      ) async {
    try {
      print('Parsing Gemini response...');
      final data = jsonDecode(responseBody);
      final text = data['candidates'][0]['content']['parts'][0]['text'];

      // Extract JSON from response
      String cleanedText = text.trim();
      cleanedText = cleanedText.replaceAll('```json', '');
      cleanedText = cleanedText.replaceAll('```', '');
      cleanedText = cleanedText.trim();

      final suggestions = jsonDecode(cleanedText);

      // Parse suggestions with null safety
      final List<Map<String, dynamic>> results = [];
      for (var suggestion in suggestions['suggestions']) {
        try {
          final date = DateTime.parse(suggestion['date']);
          final daysAhead = suggestion['daysAhead'] ?? date.difference(now).inDays;

          // Verify date is not too soon and not Sunday
          if (daysAhead < frequency.minDaysAhead || date.weekday == DateTime.sunday) {
            print('Warning: Suggestion $date is invalid (days ahead: $daysAhead, Sunday: ${date.weekday == DateTime.sunday}), skipping');
            continue;
          }

          // Verify time is in 24-hour format
          final timeStr = suggestion['time'] as String;
          if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeStr)) {
            print('Warning: Invalid time format: $timeStr, skipping');
            continue;
          }

          results.add({
            'date': date,
            'time': timeStr,
            'score': suggestion['score'] ?? 0,
            'conflicts': suggestion['conflicts'] ?? 0,
            'reasoning': suggestion['reasoning'] ?? '',
            'matchesPreferences': suggestion['matchesPreferences'] ?? false,
            'preferenceMatches': List<String>.from(suggestion['preferenceMatches'] ?? []),
            'foundInGap': suggestion['foundInGap'] ?? false,
            'daysAhead': daysAhead,
          });
        } catch (e) {
          print('Error parsing suggestion: $e');
        }
      }

      // Ensure we have enough suggestions
      if (results.length < numberOfSuggestions) {
        print('Got ${results.length} suggestions, adding ${numberOfSuggestions - results.length} fallback suggestions');
        final fallbackResults = _getFallbackSuggestions(
          allEvents,
          frequency,
          timePreferences,
          candidateDates,
          numberOfSuggestions - results.length,
        );
        results.addAll(fallbackResults);
      }

      return results.take(numberOfSuggestions).toList();
    } catch (e) {
      print('Error parsing Gemini response: $e');
      print('Response body was: $responseBody');
      return _getFallbackSuggestions(
        allEvents,
        frequency,
        timePreferences,
        candidateDates,
        numberOfSuggestions,
      );
    }
  }

  // Fallback suggestions when API fails
  static List<Map<String, dynamic>> _getFallbackSuggestions(
      List<CombinedScheduleEvent> allEvents,
      MeetingFrequency frequency,
      TimePreferences timePreferences,
      List<DateTime> candidateDates,
      int numberOfSuggestions,
      ) {
    print('Using fallback suggestions engine');
    final results = <Map<String, dynamic>>[];
    final durationMinutes = timePreferences.meetingDuration?.inMinutes ?? 60;
    final now = DateTime.now();

    // Try to find times within preferred range
    for (var date in candidateDates) {
      if (results.length >= numberOfSuggestions) break;

      // Skip Sundays
      if (date.weekday == DateTime.sunday) continue;

      final daysAhead = date.difference(DateTime(now.year, now.month, now.day)).inDays;

      // Skip if too soon for this frequency
      if (daysAhead < frequency.minDaysAhead) {
        continue;
      }

      // Get all events for this date
      final dateEvents = allEvents.where((event) =>
      event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day
      ).toList();

      // Define working hours (8 AM to 8 PM)
      final workingStart = const TimeOfDay(hour: 8, minute: 0);
      final workingEnd = const TimeOfDay(hour: 20, minute: 0);

      // Use preferred time range if available
      final effectiveStartTime = timePreferences.preferredStartTime ?? workingStart;
      final effectiveEndTime = timePreferences.preferredEndTime ?? workingEnd;

      TimeOfDay? suggestedTime;
      bool matchesPreferences = false;
      bool foundInGap = false;
      List<String> matchedPrefs = [];
      String reasoning = '';

      if (dateEvents.isEmpty) {
        // Day is completely free
        // Check if we can fit the meeting in preferred time range
        if (_hasSufficientGap(effectiveStartTime, effectiveEndTime, durationMinutes)) {
          suggestedTime = effectiveStartTime;
          matchesPreferences = timePreferences.hasTimeRange;
          if (matchesPreferences) matchedPrefs.add('time');
          reasoning = 'Completely free day';
        }
      } else {
        // Day has events, check for gaps
        // Sort events by start time
        dateEvents.sort((a, b) {
          final timeA = _parseTimeString(a.startTime);
          final timeB = _parseTimeString(b.startTime);
          if (timeA == null || timeB == null) return 0;
          return (timeA.hour * 60 + timeA.minute).compareTo(timeB.hour * 60 + timeB.minute);
        });

        // Check morning slot (before first event)
        final firstEventStart = _parseTimeString(dateEvents.first.startTime);
        if (firstEventStart != null) {
          // Calculate the earliest we can start (max of preferred start time and working start)
          final earliestStart = _maxTimeOfDay(effectiveStartTime, workingStart);

          // Only suggest if the gap is sufficient and within working hours
          if (_hasSufficientGap(earliestStart, firstEventStart, durationMinutes) &&
              _isTimeInRange(earliestStart, workingStart, workingEnd)) {
            suggestedTime = earliestStart;
            foundInGap = true;
            matchesPreferences = _isTimeInRange(suggestedTime!, effectiveStartTime, effectiveEndTime);
            if (matchesPreferences) matchedPrefs.add('time');
            reasoning = 'Found morning slot before first event';
          }
        }

        // Check gaps between events
        if (suggestedTime == null && dateEvents.length > 1) {
          for (int i = 0; i < dateEvents.length - 1; i++) {
            final currentEventEnd = _parseTimeString(dateEvents[i].endTime);
            final nextEventStart = _parseTimeString(dateEvents[i + 1].startTime);

            if (currentEventEnd != null && nextEventStart != null) {
              // Ensure the gap is within working hours and preferred range
              if (_hasSufficientGap(currentEventEnd, nextEventStart, durationMinutes) &&
                  _isTimeInRange(currentEventEnd, workingStart, workingEnd) &&
                  _isTimeInRange(currentEventEnd, effectiveStartTime, effectiveEndTime)) {
                suggestedTime = currentEventEnd;
                foundInGap = true;
                matchesPreferences = true;
                matchedPrefs.add('time');
                reasoning = 'Found gap between events';
                break;
              }
            }
          }
        }

        // Check evening slot (after last event)
        if (suggestedTime == null) {
          final lastEventEnd = _parseTimeString(dateEvents.last.endTime);
          if (lastEventEnd != null) {
            // Calculate the latest we can end (min of preferred end time and working end)
            final latestEnd = _minTimeOfDay(effectiveEndTime, workingEnd);

            if (_hasSufficientGap(lastEventEnd, latestEnd, durationMinutes) &&
                _isTimeInRange(lastEventEnd, workingStart, workingEnd) &&
                _isTimeInRange(lastEventEnd, effectiveStartTime, effectiveEndTime)) {
              suggestedTime = lastEventEnd;
              foundInGap = true;
              matchesPreferences = true;
              matchedPrefs.add('time');
              reasoning = 'Found evening slot after last event';
            }
          }
        }

        // If no gap found in preferred range, look for any available slot in working hours
        if (suggestedTime == null) {
          // Try to find any slot in working hours
          suggestedTime = _findAnyAvailableSlot(
              dateEvents,
              durationMinutes,
              workingStart,
              workingEnd
          );
          if (suggestedTime != null) {
            matchesPreferences = _isTimeInRange(suggestedTime!, effectiveStartTime, effectiveEndTime);
            if (matchesPreferences) matchedPrefs.add('time');
            reasoning = 'Available slot found${matchesPreferences ? ' in preferred range' : ''}';
          }
        }
      }

      if (suggestedTime != null) {
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
          'conflicts': dateEvents.length,
          'reasoning': '$reasoning ($daysAhead days ahead)',
          'matchesPreferences': matchesPreferences,
          'preferenceMatches': matchedPrefs,
          'foundInGap': foundInGap,
          'daysAhead': daysAhead,
        });
      }
    }

    // If no results with preferences, try without strict range
    if (results.isEmpty) {
      for (var date in candidateDates) {
        if (results.length >= numberOfSuggestions) break;

        // Skip Sundays
        if (date.weekday == DateTime.sunday) continue;

        final daysAhead = date.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (daysAhead < frequency.minDaysAhead) continue;

        final dateEvents = allEvents.where((event) =>
        event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day
        ).toList();

        if (dateEvents.isEmpty && date.weekday <= 5) {
          // Default to 10:00 AM if in range, otherwise 9:00 AM
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
          });
        }
      }
    }

    print('Fallback engine found ${results.length} suggestions');
    return results;
  }

  static TimeOfDay? _findAnyAvailableSlot(
      List<CombinedScheduleEvent> events,
      int durationMinutes,
      TimeOfDay startBoundary,
      TimeOfDay endBoundary
      ) {
    if (events.isEmpty) {
      return startBoundary;
    }

    // Sort events by start time
    events.sort((a, b) {
      final timeA = _parseTimeString(a.startTime);
      final timeB = _parseTimeString(b.startTime);
      if (timeA == null || timeB == null) return 0;
      return (timeA.hour * 60 + timeA.minute).compareTo(timeB.hour * 60 + timeB.minute);
    });

    // Check before first event
    final firstEventStart = _parseTimeString(events.first.startTime);
    if (firstEventStart != null) {
      if (_hasSufficientGap(startBoundary, firstEventStart, durationMinutes)) {
        return startBoundary;
      }
    }

    // Check gaps between events
    for (int i = 0; i < events.length - 1; i++) {
      final currentEventEnd = _parseTimeString(events[i].endTime);
      final nextEventStart = _parseTimeString(events[i + 1].startTime);

      if (currentEventEnd != null && nextEventStart != null) {
        if (_hasSufficientGap(currentEventEnd, nextEventStart, durationMinutes)) {
          return currentEventEnd;
        }
      }
    }

    // Check after last event
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
      // Remove any whitespace and convert to lowercase
      timeString = timeString.trim().toLowerCase();

      // Handle 24-hour format (e.g., "14:30")
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          var hour = int.tryParse(parts[0]);
          var minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));

          if (hour != null && minute != null) {
            // Check for AM/PM in the second part
            if (parts[1].contains('pm') && hour < 12) {
              hour += 12;
            } else if (parts[1].contains('am') && hour == 12) {
              hour = 0;
            }

            // Validate hour range
            if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              return TimeOfDay(hour: hour, minute: minute);
            }
          }
        }
      }

      // Handle AM/PM format (e.g., "2:30 PM")
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

          // Validate hour range
          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      }

      // Try simple hour:minute format
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
      bool isInTimeRange
      ) {
    // Start with a base score of 50 (mid-range)
    int score = 50;

    // Add moderate bonuses for positive factors
    if (matchesPrefs) score += 15; // Reduced from 20
    if (foundInGap) score += 10; // Reduced from 25
    if (isWeekday) score += 10; // Reduced from 15
    if (isInTimeRange) score += 10; // Reduced from 20

    // Score based on how far ahead (moderate adjustments)
    if (daysAhead >= minDaysAhead && daysAhead <= minDaysAhead * 2) {
      score += 15; // Reduced from 30 - Optimal timing
    } else if (daysAhead > minDaysAhead * 2 && daysAhead <= minDaysAhead * 3) {
      score += 10; // Reduced from 20 - Good timing
    } else if (daysAhead > minDaysAhead * 3) {
      score += 5; // Reduced from 10 - Acceptable but far ahead
    } else {
      score = 0; // Set to 0 instead of subtracting 100
    }

    // Penalize for conflicts (moderate penalty)
    score -= (conflicts * 3); // Reduced from 5

    // Penalize for weekends (Sunday already filtered, Saturday gets moderate penalty)
    if (!isWeekday) score -= 15; // Reduced from 30

    // Ensure score stays within 0-100 range
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

  // Time preferences
  TimeOfDay? _preferredStartTime;
  TimeOfDay? _preferredEndTime;
  bool _showTimePreferences = false;

  @override
  void initState() {
    super.initState();
    _initializeSignkey();
    _initializeGeminiEngine();
  }

  Future<void> _initializeGeminiEngine() async {
    try {
      await GeminiMeetingSuggestionEngine.ensureInitialized();
    } catch (e) {
      print('Error initializing Gemini engine: $e');
    }
  }

  Future<void> _initializeSignkey() async {
    if (_isLoadingSignkey) return;

    setState(() {
      _isLoadingSignkey = true;
      _hasLoadError = false;
    });

    try {
      // Ensure user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      // Get user document
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final signkey = userData?['signkey'] as String?;

        if (signkey != null && signkey.isNotEmpty) {
          setState(() {
            _userSignkey = signkey;
            _hasLoadError = false;
          });
          print('Signkey loaded successfully: $signkey');
        } else {
          throw Exception('Signkey not found in user profile. Please update your profile.');
        }
      } else {
        throw Exception('User profile not found. Please complete your profile setup.');
      }
    } catch (e) {
      print('Error loading signkey: $e');
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

      print('Fetching schedule events for user: $userId, signkey: $_userSignkey');

      // 1. Get user's timetable events
      try {
        final timetableSnapshot = await _firestore
            .collection('timetable_events')
            .where('userId', isEqualTo: userId)
            .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(now))
            .limit(100)
            .get();

        print('Found ${timetableSnapshot.docs.length} timetable events');

        for (final doc in timetableSnapshot.docs) {
          final data = doc.data();
          try {
            final dateString = data['date'] as String?;
            if (dateString != null) {
              final date = DateTime.parse(dateString);
              if (date.isBefore(next90Days)) {
                allEvents.add(CombinedScheduleEvent(
                  date: date,
                  startTime: data['startTime']?.toString() ?? '09:00',
                  endTime: data['endTime']?.toString() ?? '10:00',
                  title: data['title']?.toString() ?? 'Timetable Event',
                  source: 'timetable',
                  signkey: data['signkey']?.toString(),
                ));
              }
            }
          } catch (e) {
            print('Error parsing timetable event ${doc.id}: $e');
          }
        }
      } catch (e) {
        print('Error fetching timetable events: $e');
      }

      // 2. Get Events with matching signkey
      try {
        final eventsSnapshot = await _firestore
            .collection('Events')
            .where('signkey', isEqualTo: _userSignkey)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .where('timestamp', isLessThan: Timestamp.fromDate(next90Days))
            .limit(100)
            .get();

        print('Found ${eventsSnapshot.docs.length} Events');

        for (final doc in eventsSnapshot.docs) {
          final data = doc.data();
          try {
            final timestamp = data['timestamp'] as Timestamp?;
            if (timestamp != null) {
              final dateTime = timestamp.toDate();
              final title = data['title']?.toString() ?? 'Event';
              final startTime = data['startTime']?.toString() ?? DateFormat('HH:mm').format(dateTime);
              final endTime = data['endTime']?.toString() ??
                  DateFormat('HH:mm').format(dateTime.add(const Duration(hours: 1)));

              allEvents.add(CombinedScheduleEvent(
                date: DateTime(dateTime.year, dateTime.month, dateTime.day),
                startTime: startTime,
                endTime: endTime,
                title: title,
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

      // 3. Get personal calendar events
      try {
        final calendarSnapshot = await _firestore
            .collection('events')
            .where('uid', isEqualTo: userId)
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .where('dateTime', isLessThan: Timestamp.fromDate(next90Days))
            .limit(100)
            .get();

        print('Found ${calendarSnapshot.docs.length} calendar events');

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
        print('Error fetching calendar events: $e');
      }

      // 4. Get mentee timetable events (same signkey, different userId)
      try {
        final menteeSnapshot = await _firestore
            .collection('timetable_events')
            .where('signkey', isEqualTo: _userSignkey)
            .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(now))
            .limit(100)
            .get();

        print('Found ${menteeSnapshot.docs.length} mentee events');

        for (final doc in menteeSnapshot.docs) {
          final data = doc.data();
          final menteeUserId = data['userId']?.toString();
          if (menteeUserId != null && menteeUserId != userId) {
            try {
              final dateString = data['date'] as String?;
              if (dateString != null) {
                final date = DateTime.parse(dateString);
                if (date.isBefore(next90Days)) {
                  allEvents.add(CombinedScheduleEvent(
                    date: date,
                    startTime: data['startTime']?.toString() ?? '09:00',
                    endTime: data['endTime']?.toString() ?? '10:00',
                    title: '${data['title']?.toString() ?? 'Event'} (Mentee)',
                    source: 'timetable',
                    signkey: data['signkey']?.toString(),
                  ));
                }
              }
            } catch (e) {
              print('Error parsing mentee event ${doc.id}: $e');
            }
          }
        }
      } catch (e) {
        print('Error fetching mentee events: $e');
      }

      print('Total events loaded: ${allEvents.length}');
    } catch (e) {
      print('Error fetching schedule events: $e');
      _showSnackBar('Error loading schedule events: ${e.toString().replaceAll('Exception: ', '')}', isError: true);
    }

    return allEvents;
  }

  Future<void> _findAvailableDates() async {
    // Check if signkey is loaded
    if (_userSignkey == null || _userSignkey!.isEmpty) {
      _showSnackBar('Please wait, still loading your profile...', isError: true);
      await _initializeSignkey();
      if (_userSignkey == null) {
        return;
      }
    }

    // Dismiss keyboard before searching
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate meeting title
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
      // Initialize Gemini engine if not already done
      await GeminiMeetingSuggestionEngine.ensureInitialized();

      _allEvents = await _getAllScheduleEvents();

      // Parse duration from controller
      final durationText = _durationController.text.trim();
      final durationMinutes = int.tryParse(durationText) ?? 60;

      if (durationMinutes <= 0) {
        _showSnackBar('Please enter a valid duration (positive number)', isError: true);
        setState(() { _isFindingDates = false; });
        return;
      }

      // Create time preferences
      final timePreferences = TimePreferences(
        preferredStartTime: _preferredStartTime,
        preferredEndTime: _preferredEndTime,
        meetingDuration: Duration(minutes: durationMinutes),
      );

      print('Finding optimal times with ${_allEvents.length} events...');

      final suggestions = await GeminiMeetingSuggestionEngine.findOptimalTimesWithAI(
        allEvents: _allEvents,
        frequency: _selectedFrequency,
        userSignkey: _userSignkey!,
        meetingTitle: _titleController.text.trim(),
        timePreferences: timePreferences,
        numberOfSuggestions: 3,
      );

      print('Found ${suggestions.length} suggestions');

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

        // Show when meetings are scheduled
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

      // Create event in Events collection
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

      print('Creating event with data: $eventData');

      await _firestore.collection('Events').doc(eventId).set(eventData);

      // Add to timetable
      final timetableId = 'timetable_$eventId';
      final timetableData = {
        'id': timetableId,
        'userId': userId,
        'signkey': _userSignkey,
        'title': _titleController.text.trim(),
        'description': 'Meeting: ${_venueController.text.isNotEmpty ? _venueController.text : "No venue specified"}\nDuration: ${durationMinutes} minutes\nFrequency: ${_selectedFrequency.title}',
        'date': DateFormat('yyyy-MM-dd').format(date),
        'day': DateFormat('EEE').format(date),
        'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        'duration': durationMinutes,
        'frequency': _selectedFrequency.title,
        'color': '#2196F3',
        'isMeeting': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

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
    if (score >= 80) return 'High';
    if (score >= 50) return 'Medium';
    return 'Low';
  }

  Color _getConfidenceColor(int score) {
    if (score >= 80) return Colors.green;
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
          backgroundColor: Colors.blue.shade700,
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
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.psychology,
                              color: Colors.blue.shade700,
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
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.blue.shade700,
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
                                color: Colors.blue.shade700,
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
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedFrequency.icon,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedFrequency.title,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
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
                                backgroundColor: Colors.blue.shade700,
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
                              CircularProgressIndicator(color: Colors.blue.shade700),
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
                                          color: Colors.blue.shade600,
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
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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