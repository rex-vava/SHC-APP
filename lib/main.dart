// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/patient/patient_home_screen.dart';
import 'screens/doctor/doctor_home.dart';
import 'models/patient_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here
      ],
      child: MaterialApp(
        title: 'Smart Health Rwanda',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        debugShowCheckedModeBanner: false,

        /// ---------- Routing ----------
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());

            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());

            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());

            case '/patient-home':
              final patient = settings.arguments as PatientModel;
              return MaterialPageRoute(
                builder: (_) => PatientHomeScreen(currentPatient: patient),
              );

            case '/doctor-home':
              return MaterialPageRoute(
                builder: (_) => const DoctorHomeScreen(),
              );

            default:
              return null;
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserData(); // ensure token and user are loaded

    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (authProvider.isAuthenticated) {
      // If the user is a patient, make sure to set currentPatient
      if (authProvider.isPatient) {
        // Here you need to create PatientModel from authProvider.user
        final patient = PatientModel(
          id: authProvider.user!.id,
          name: authProvider.userName ?? 'Unknown',
          email: authProvider.user!.email,
          phone: authProvider.user!.phone ?? 'Not provided',
          healthInsurance: '', // optional
          mutuelleNumber: '', // optional
          age: 'Unknown',
          gender: authProvider.user!.gender ?? 'Not specified',
          medicalHistory: '',
          token: authProvider.token ?? '',
        );

        authProvider.setCurrentPatient(patient);

        Navigator.pushReplacementNamed(
          context,
          '/patient-home',
          arguments: authProvider.currentPatient,
        );
      }
      // If user is doctor
      else if (authProvider.isDoctor) {
        Navigator.pushReplacementNamed(context, '/doctor-home');
      }
      // Unknown user type
      else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Smart Health Rwanda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Digital Healthcare Consultation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
