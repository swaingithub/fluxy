import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_connectivity/fluxy_connectivity.dart';

void main() async {
  await Fluxy.init();
  runApp(FluxyExampleApp());
}

class FluxyExampleApp extends StatelessWidget {
  const FluxyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluxyApp(
      title: 'Fluxy Framework Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Reactive state with persistence
  final counter = flux(0, key: 'counter', persist: true);
  final userName = flux('', key: 'user_name', persist: true);
  final isConnected = flux(true, key: 'connection_status');
  final isAuthenticated = flux(false, key: 'auth_status');

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    // Real connectivity monitoring with fluxy_connectivity
    final connectivity = FluxyPluginEngine.find<FluxyConnectivityPlugin>();
    if (connectivity != null) {
      // Set initial value
      isConnected.value = connectivity.isOnline.value;
      
      // Create reactive subscription to connectivity changes
      FluxEffect(() {
        isConnected.value = connectivity.isOnline.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Fx.text('Fluxy Framework Demo')
            .style(FxStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade600,
        actions: [
          Fx(() => Fx.icon(
                isConnected.value ? Icons.wifi : Icons.wifi_off,
                color: isConnected.value ? Colors.green : Colors.red,
              ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Fx.col(
          gap: 24,
          children: [
            // User Authentication Section
            _buildAuthSection(),
            
            // Counter Demo Section
            _buildCounterSection(),
            
            // Storage Demo Section
            _buildStorageSection(),
            
            // Platform Features Section
            _buildPlatformSection(),
            
            // Biometric Section
            _buildBiometricSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Authentication Demo')
              .style(FxStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          Fx(() => Fx.text(
                isAuthenticated.value ? 'Authenticated' : 'Not Authenticated',
              ).style(FxStyle(color: isAuthenticated.value ? Colors.green : Colors.red))),
          Fx.row(
            gap: 12,
            children: [
              Fx.primaryButton('Login', onTap: _handleLogin),
              Fx.dangerButton('Logout', onTap: _handleLogout),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Reactive State Demo')
              .style(FxStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          Fx(() => Fx.text('Counter: ${counter.value}')
              .style(FxStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade600))),
          Fx.row(
            gap: 12,
            children: [
              Fx.primaryButton('Increment', onTap: () => counter.value++),
              Fx.secondaryButton('Decrement', onTap: () => counter.value--),
              Fx.textButton('Reset', onTap: () => counter.value = 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Storage Demo')
              .style(FxStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          Fx.field(
            label: 'Enter your name',
            signal: userName,
            placeholder: 'Type your name here...',
          ),
          Fx(() => Fx.text('Stored Name: ${userName.value.isEmpty ? 'None' : userName.value}')
              .style(FxStyle(color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildPlatformSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Platform Features')
              .style(FxStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          Fx.row(
            gap: 12,
            children: [
              Fx.secondaryButton('Check Permissions', onTap: _checkPermissions),
              Fx.secondaryButton('Get Platform Info', onTap: _getPlatformInfo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Biometric Authentication')
              .style(FxStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          Fx.successButton('Authenticate with Biometrics', onTap: _authenticateWithBiometrics),
        ],
      ),
    );
  }

  void _handleLogin() {
    // Simulate login
    userName.value = 'John Doe';
    isAuthenticated.value = true;
    
    Fx.toast.success('Logged in successfully!');
  }

  void _handleLogout() {
    // Simulate logout
    userName.value = '';
    isAuthenticated.value = false;
    
    Fx.toast.error('Logged out successfully!');
  }

  void _checkPermissions() async {
    // Simulate permission checking
    Fx.toast.info('Camera: Granted, Storage: Granted');
  }

  void _getPlatformInfo() async {
    // Simulate platform info
    Fx.toast('Platform: Android, Version: 13');
  }

  void _authenticateWithBiometrics() async {
    // Simulate biometric authentication
    Fx.toast.success('Biometric authentication successful!');
  }
}
