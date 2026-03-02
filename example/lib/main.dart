import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_connectivity/fluxy_connectivity.dart';
import 'package:fluxy_haptics/fluxy_haptics.dart';
import 'package:fluxy_device/fluxy_device.dart';
import 'package:fluxy_logger/fluxy_logger.dart';
import 'package:fluxy_websocket/fluxy_websocket.dart';
import 'package:fluxy_sync/fluxy_sync.dart';
import 'package:fluxy_presence/fluxy_presence.dart';
import 'package:fluxy_geo/fluxy_geo.dart';
import 'core/registry/fluxy_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup the registry (The "Right Way")
  Fluxy.registerRegistry(() => registerFluxyPlugins());

  // 2. Scan and register all modules
  Fluxy.autoRegister();

  // 3. Manual registration for any custom/local plugins
  Fluxy.register(FluxyHapticsPlugin());
  Fluxy.register(FluxyDevicePlugin());
  Fluxy.register(FluxyLoggerPlugin());

  // 4. POWER ON the engine (Initializes all plugins in strict order)
  await Fluxy.init();

  FluxyVault.init(salt: 'fluxy_example_secure_salt_2026'); // Secondary Layer

  runApp(Fluxy.debug(child: const FluxyExampleApp()));
}

class FluxyExampleApp extends StatelessWidget {
  const FluxyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluxyApp(
      title: 'Fluxy Framework Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const FluxyErrorBoundary(child: HomePage()),
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
  final counter = flux(
    0,
    key: 'counter',
    persist: true,
    label: 'counter_value',
  );
  final userName = flux(
    '',
    key: 'user_name',
    persist: true,
    label: 'user_name',
  );
  final isConnected = flux(
    true,
    key: 'connection_status',
    label: 'is_connected',
  );
  final connectionType = flux(
    FluxyConnectionType.none,
    key: 'connection_type',
    label: 'connection_type',
    fromJson: (j) => FluxyConnectionType.values.byName(j as String),
  );
  final isAuthenticated = flux(
    false,
    key: 'auth_status',
    label: 'is_authenticated',
  );
  final searchSignal = flux('', label: 'sidebar_search');

  Map<String, dynamic>? _savedSnapshot;

  // NEW: Resource Management Demo
  final activeUsers = flux(0);
  final resourceStatus = flux('Sleeping');
  late final mockGps = FluxyResource<String>(
    name: 'Industrial GPS Engine',
    onStart: () async {
      resourceStatus.value = 'WAKING UP...';
      await Future.delayed(const Duration(seconds: 1));
      resourceStatus.value = 'ACTIVE (10Hz Polling)';
      return 'GPS_INSTANCE_ID_001';
    },
    onStop: (instance) async {
      resourceStatus.value = 'ENTERING DEEP SLEEP...';
      await Future.delayed(const Duration(milliseconds: 500));
      resourceStatus.value = 'Sleeping';
    },
    idleTimeout: const Duration(seconds: 3), // Faster for demo
  );

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    // The "Right Way": Use the Unified Platform API (Fx.platform)
    final connectivity = Fx.platform.connectivity;

    if (connectivity != null) {
      // Set initial values
      isConnected.value = connectivity.isOnline.value;
      connectionType.value = connectivity.connectionType.value;

      // Create reactive subscription to connectivity changes
      FluxEffect(() {
        isConnected.value = connectivity.isOnline.value;
        connectionType.value = connectivity.connectionType.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Fx.safe(
      Fx.dashboard(
        navbar: Fx.navbar(
          leading: Builder(
            builder: (context) {
              return Fx.icon(
                Icons.menu_rounded,
                color: Colors.white,
                onTap: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          logo: Fx.text('Fluxy Dashboard').style(
            const FxStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: FxStyle(backgroundColor: Colors.blue.shade600),
          actions: [
            Fx(
              () => Fx.icon(
                isConnected.value ? Icons.wifi : Icons.wifi_off,
                color: isConnected.value ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        sidebar: _buildSidebar(),
        body: Fx.safe(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Fx.col(
              gap: 24,
              children: [
                // User Authentication Section
                _buildAuthSection(),

                // Buttons Showcase Section
                _buildButtonsSection(),

                // Counter Demo Section
                _buildCounterSection(),

                // Connectivity Demo Section
                _buildConnectivitySection(),

                // Storage Demo Section
                _buildStorageSection(),

                // Platform Features Section
                _buildPlatformSection(),

                // Biometric Section
                _buildBiometricSection(),

                // Industrial Control Center (Kill Switches)
                _buildControlCenterSection(),

                // NEW: Haptics Demo Section
                _buildHapticsSection(),

                // NEW: Device Info Section
                _buildDeviceSection(),

                // NEW: Logger Audit Section
                _buildLoggerSection(),

                // NEW: Web-Style Flex Demo
                _buildFlexDemoSection(),

                // NEW: Real-Time & Advanced Sections
                _buildWebSocketSection(),
                _buildSyncSection(),
                _buildPresenceSection(),
                Fx.feature('geo', child: _buildGeoSection()),
                _buildBridgeSection(),
                _buildResourceSection(),
                _buildObservabilitySection(),
                // NEW: Programmatic Snapshots Demo
                _buildSnapshotSection(),

                Fx.feature('security', child: _buildSecuritySection()),
                _buildStabilitySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Programmatic Snapshots').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          Fx.text(
            'Capture the state of all labeled signals and restore it instantly.',
          ).muted(),
          Fx.row(
            gap: 12,
            children: [
              Expanded(
                child: Fx.primaryButton(
                  'Capture',
                  onTap: () {
                    _savedSnapshot = FluxRegistry.captureSnapshot();
                    Fx.toast.success('Snapshot Saved Locally');
                  },
                ),
              ),
              Expanded(
                child: Fx.outlineButton(
                  'Restore',
                  onTap: () {
                    if (_savedSnapshot != null) {
                      FluxRegistry.restoreSnapshot(_savedSnapshot!);
                      Fx.toast.info('State Restored');
                    } else {
                      Fx.toast.error('No Snapshot Found');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebSocketSection() {
    final ws = Fluxy.use<FluxyWebSocketPlugin>();
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('WebSocket (Real-Time)').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx(
                () => Fx.text('Status: ${ws.status.value.name.toUpperCase()}')
                    .style(
                      FxStyle(
                        color: ws.status.value == FluxySocketStatus.connected
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              Fx.secondaryButton(
                'Connect',
                onTap: () => ws.connect('wss://echo.websocket.org'),
              ),
            ],
          ),
          Fx.row(
            gap: 12,
            children: [
              Expanded(
                child: Fx.secondaryButton(
                  'Send Hello',
                  onTap: () => ws.send({'type': 'hello', 'data': 'Fluxy Echo'}),
                ),
              ),
              Fx.dangerButton('Disconnect', onTap: ws.disconnect),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection() {
    final sync = Fluxy.use<FluxySyncPlugin>();
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Sync Engine (Offline-First)').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx(() => Fx.text('Pending Tasks: ${sync.pendingCount.value}')),
              Fx(
                () => Fx.text(
                  sync.isSyncing.value ? '🔄 Syncing...' : '✅ Idle',
                ).style(FxStyle(color: Colors.orange.shade700)),
              ),
            ],
          ),
          Fx.primaryButton(
            'Add Mock Task',
            onTap: () {
              sync.queue(
                'POST',
                '/api/profile',
                body: {
                  'name': 'Fluxy User',
                  'ts': DateTime.now().toIso8601String(),
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceSection() {
    final presence = Fluxy.use<FluxyPresencePlugin>();
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Presence & Collaboration').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          Fx(() {
            final userList = presence.users.value;
            return Fx.text('Online Users: ${userList.length}');
          }),
          Fx.row(
            gap: 12,
            children: [
              Fx.secondaryButton(
                'Set Online',
                onTap: () => presence.setOnline(true),
              ),
              Fx.secondaryButton(
                'Set Typing',
                onTap: () => presence.setTyping(true),
              ),
            ],
          ),
          Fx(() {
            final typing = presence.typingUsers.value;
            if (typing.isEmpty) return const SizedBox.shrink();
            return Fx.text('Someone is typing...').style(
              const FxStyle(
                fontSize: 12,
                color: Colors.purple,
                fontStyle: FontStyle.italic,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGeoSection() {
    final geo = Fluxy.use<FluxyGeoPlugin>();
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Geo & Geofencing').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx(
                () => Fx.text(
                  geo.isTracking.value ? '🛰️ Tracking On' : '🛰️ Offline',
                ),
              ),
              Fx.secondaryButton(
                geo.isTracking.value ? 'Stop' : 'Start',
                onTap: () async {
                  if (geo.isTracking.value) {
                    geo.stopTracking();
                  } else {
                    try {
                      await geo.startTracking();
                      geo.addGeofence('hq', 0.0, 0.0, 100.0); // Mock Geofence
                    } catch (e) {
                      Fx.toast.error(
                        e.toString().replaceAll('Exception: ', ''),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          Fx(
            () => Fx.col(
              alignItems: CrossAxisAlignment.start,
              children: [
                Fx.text('Lat: ${geo.latitude.value.toStringAsFixed(4)}'),
                Fx.text('Lng: ${geo.longitude.value.toStringAsFixed(4)}'),
                Fx.text(
                  'Active Geofences: ${geo.activeGeofences.value.join(", ")}',
                ).style(
                  FxStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBridgeSection() {
    final timerSignal = flux(0);

    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Stream Bridge (Async Integration)').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx.text(
            'Fluxy bridges native Dart Streams into reactive Signals flawlessly.',
          ),
          Fx.row(
            gap: 12,
            children: [
              Fx.icon(Icons.timer_outlined, color: Colors.blue),
              Fx(
                () =>
                    Fx.text('Live Timer Stream: ${timerSignal.value}s').bold(),
              ),
            ],
          ),
          Fx.primaryButton(
            'START BRIDGE',
            onTap: () {
              // Bridge a standard Dart Stream to a Fluxy Signal
              Stream.periodic(const Duration(seconds: 1), (i) => i + 1)
                  .take(10) // Only for 10 seconds to avoid memory leaks in demo
                  .listen((val) => timerSignal.value = val);

              Fx.toast.info('Stream Bridged for 10s');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Managed Resource (Battery Save)').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          Fx.text('Automatic "Graceful Sleep" when features are unused.'),
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx(
                () => Fx.text('Hardware Status: ${resourceStatus.value}').style(
                  FxStyle(
                    fontWeight: FontWeight.bold,
                    color: resourceStatus.value.contains('ACTIVE')
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
              Fx(
                () => Fx.box(
                  style: FxStyle(
                    backgroundColor: Colors.indigo,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                  ),
                  child: Fx.text(
                    activeUsers.value.toString(),
                  ).color(Colors.white).bold(),
                ),
              ),
            ],
          ),
          Fx.row(
            gap: 10,
            children: [
              Fx.secondaryButton(
                'SIMULATE USER IN',
                onTap: () async {
                  activeUsers.value++;
                  await mockGps.acquire();
                },
              ).expanded(),
              Fx.outlineButton(
                'SIMULATE USER OUT',
                onTap: () {
                  if (activeUsers.value > 0) {
                    activeUsers.value--;
                    mockGps.release();
                  }
                },
              ).expanded(),
            ],
          ),
          Fx.text(
            'Try removing all users and wait 3 seconds to see "Deep Sleep".',
          ).font.xs().muted(),
        ],
      ),
    );
  }

  Widget _buildObservabilitySection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.black,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx.text('Fluxy X-Ray (Observability)').style(
                const FxStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              Fx.badge(
                child: Fx.text('LIVE').font.xs().bold(),
                color: Colors.red,
              ),
            ],
          ),
          Fx.text('Real-time Signal Churn & Rebuild Audit').color(Colors.grey),

          Fx.box(
            style: FxStyle(
              backgroundColor: Colors.white10,
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
            ),
            child: Fx(() {
              final signals = FluxyObservability.signalStats;
              final rebuilds = FluxyObservability.rebuildStats;

              if (signals.isEmpty && rebuilds.isEmpty) {
                return Fx.text(
                  'Interact with the app to see metrics...',
                ).color(Colors.grey);
              }

              return Fx.col(
                gap: 8,
                alignItems: CrossAxisAlignment.start,
                children: [
                  Fx.text(
                    'Signal Activity',
                  ).bold().color(Colors.greenAccent).font.xs(),
                  ...signals.entries
                      .take(3)
                      .map(
                        (e) => Fx.row(
                          justify: MainAxisAlignment.spaceBetween,
                          children: [
                            Fx.text(e.key).color(Colors.white70).font.xs(),
                            Fx.text(
                              '${e.value} updates',
                            ).color(Colors.white).bold().font.xs(),
                          ],
                        ),
                      ),
                  const Divider(color: Colors.white24),
                  Fx.text(
                    'Widget Rebuilds',
                  ).bold().color(Colors.orangeAccent).font.xs(),
                  ...rebuilds.entries
                      .take(3)
                      .map(
                        (e) => Fx.row(
                          justify: MainAxisAlignment.spaceBetween,
                          children: [
                            Fx.text(e.key).color(Colors.white70).font.xs(),
                            Fx.text(
                              '${e.value} frames',
                            ).color(Colors.white).bold().font.xs(),
                          ],
                        ),
                      ),
                ],
              );
            }),
          ),

          Fx.row(
            gap: 10,
            children: [
              Fx.outlineButton(
                'CLEAR STATS',
                onTap: FluxyObservability.clear,
              ).expanded(),
              Fx.primaryButton(
                'SIMULATE CHURN',
                onTap: () {
                  // Create a burst of state changes to test the engine
                  for (int i = 0; i < 50; i++) {
                    counter.value++;
                  }
                },
              ).expanded(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    final vaultInput = flux('');
    final decryptedData = flux('No data decrypted');

    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Industrial Security Vault').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          Fx.text('Hardware-backed storage with secondary scrambling.'),
          Fx.input(signal: vaultInput, placeholder: 'Enter secret data...'),
          Fx.row(
            gap: 10,
            children: [
              Fx.primaryButton(
                'SECURE RECORD',
                onTap: () async {
                  if (vaultInput.value.isNotEmpty) {
                    await FluxyVault.write('secret_token', vaultInput.value);
                    Fx.toast.success('Layered Encryption Applied');
                    vaultInput.value = '';
                  }
                },
              ).expanded(),
              Fx.outlineButton(
                'RETRIEVE',
                onTap: () async {
                  final data = await FluxyVault.read('secret_token');
                  decryptedData.value = data ?? 'Not Found';
                },
              ).expanded(),
            ],
          ),
          Fx(
            () => Fx.text(
              'Decrypted: ${decryptedData.value}',
            ).italic().color(Colors.blueGrey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildStabilitySection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Stability Engine (Crash-Free)').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          Fx.text('The framework intercepts crashes to maintain uptime.'),
          Fx.dangerButton(
            'TRIGGER LAYOUT CRASH',
            onTap: () {
              // This would normally cause a red screen
              FluxyError.report(
                'SIMULATED_INDUSTRIAL_FAILURE',
                StackTrace.current,
              );
            },
          ).w(double.infinity),
        ],
      ),
    );
  }

  Widget _buildHapticsSection() {
    final haptics = Fluxy.use<FluxyHapticsPlugin>();
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
          Fx.text('Haptic Feedback (Sensory)').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx.row(
            gap: 12,
            children: [
              Fx.secondaryButton('Light', onTap: haptics.light),
              Fx.secondaryButton('Medium', onTap: haptics.medium),
              Fx.secondaryButton('Heavy', onTap: haptics.heavy),
            ],
          ),
          Fx.row(
            gap: 12,
            children: [
              Fx.successButton('Success', onTap: haptics.success),
              Fx.dangerButton('Error', onTap: haptics.error),
              Fx.primaryButton('Selection', onTap: haptics.selection),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    final device = Fluxy.use<FluxyDevicePlugin>();
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
          Fx.text('Device & Environment').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx(() => Fx.text('App Version: ${device.appVersion.value}')),
          Fx(() {
            final info = device.meta.value;
            if (info.isEmpty) return Fx.text('Loading device info...');
            return Fx.col(
              alignItems: CrossAxisAlignment.start,
              children: info.entries
                  .map((e) => Fx.text('${e.key}: ${e.value}'))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoggerSection() {
    final logger = Fluxy.use<FluxyLoggerPlugin>();
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
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx.text('Logger Audit pipeline').style(
                FxStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Fx.textButton('Clear', onTap: logger.clear),
            ],
          ),
          Fx.secondaryButton(
            'Generate Log',
            onTap: () {
              logger.sys('User triggered manual log entry', tag: 'EXAMPLE');
            },
          ),
          Fx.box(
            style: FxStyle(
              backgroundColor: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              height: 150,
            ),
            child: Fx(() {
              final logs = logger.logs.value;
              if (logs.isEmpty) return Fx.text('No logs yet.');
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log =
                      logs[logs.length - 1 - index]; // Show latest first
                  return Fx.text(
                    log,
                  ).style(FxStyle(fontSize: 10, color: Colors.grey.shade800));
                },
              );
            }),
          ),
        ],
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
          Fx.text('Authentication Demo').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx(
            () =>
                Fx.text(
                  isAuthenticated.value ? 'Authenticated' : 'Not Authenticated',
                ).style(
                  FxStyle(
                    color: isAuthenticated.value ? Colors.green : Colors.red,
                  ),
                ),
          ),
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
          Fx.text('Reactive State Demo').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx(
            () => Fx.text('Counter: ${counter.value}').style(
              FxStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          Fx.row(
            gap: 12,
            children: [
              Fx.primaryButton(
                'Increment',
                onTap: () {
                  counter.value++;
                  Fluxy.use<FluxyHapticsPlugin>().light();
                  Fluxy.use<FluxyLoggerPlugin>().sys(
                    'Counter incremented to ${counter.value}',
                    tag: 'COUNTER',
                  );
                },
              ),
              Fx.secondaryButton(
                'Decrement',
                onTap: () {
                  counter.value--;
                  Fluxy.use<FluxyHapticsPlugin>().selection();
                },
              ),
              Fx.textButton('Reset', onTap: () => counter.value = 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivitySection() {
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
          Fx.text('Connectivity Demo').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx.row(
            gap: 28,
            children: [
              Fx(
                () => Fx.icon(
                  isConnected.value ? Icons.wifi : Icons.wifi_off,
                  color: isConnected.value ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
              Fx.col(
                alignItems: CrossAxisAlignment.start,
                children: [
                  Fx(
                    () => Fx.text(
                      isConnected.value ? 'Online' : 'Offline',
                    ).style(
                          const FxStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  Fx(
                    () => Fx.text(
                      'Type: ${connectionType.value.name.toUpperCase()}',
                    ).style(FxStyle(color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ],
          ),
          Fx.primaryButton(
            'Re-check Connection',
            onTap: () async {
              final connectivity = Fx.platform.connectivity;
              if (connectivity != null) {
                final result = await connectivity.check();
                Fx.toast.info(
                  'Connection refreshed: ${result ? "Online" : "Offline"}',
                );
              }
            },
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
          Fx.text('Storage Demo').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx.field(
            label: 'Enter your name',
            signal: userName,
            placeholder: 'Type your name here...',
          ),
          Fx(
            () => Fx.text(
              'Stored Name: ${userName.value.isEmpty ? 'None' : userName.value}',
            ).style(FxStyle(color: Colors.grey.shade700)),
          ),
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
          Fx.text('Platform Features').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
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
          Fx.text('Biometric Authentication').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Fx.successButton(
            'Authenticate with Biometrics',
            onTap: _authenticateWithBiometrics,
          ),
        ],
      ),
    );
  }

  Widget _buildControlCenterSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Fx.col(
        gap: 12,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Industrial Control Center').style(
            FxStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          Fx.text('Emergency Kill-Switch (Production Safety)').font.xs().bold(),
          Fx.row(
            responsive: true,
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx.text('Geo Module'),
              Fx(
                () => Fx.icon(
                  FluxyFeatureToggle.isEnabled('geo')
                      ? Icons.check_circle
                      : Icons.dangerous,
                  color: FluxyFeatureToggle.isEnabled('geo')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              Fx(
                () => Fx.secondaryButton(
                  FluxyFeatureToggle.isEnabled('geo')
                      ? 'KILL GEO'
                      : 'RESTORE GEO',
                  onTap: () {
                    if (FluxyFeatureToggle.isEnabled('geo')) {
                      FluxyFeatureToggle.kill('geo');
                    } else {
                      FluxyFeatureToggle.restore('geo');
                    }
                  },
                ),
              ),
            ],
          ),
          Fx.row(
            responsive: true,
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx.text('Security Module'),
              Fx(
                () => Fx.icon(
                  FluxyFeatureToggle.isEnabled('security')
                      ? Icons.check_circle
                      : Icons.dangerous,
                  color: FluxyFeatureToggle.isEnabled('security')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              Fx(
                () => Fx.secondaryButton(
                  FluxyFeatureToggle.isEnabled('security')
                      ? 'KILL SECURITY'
                      : 'RESTORE SECURITY',
                  onTap: () {
                    if (FluxyFeatureToggle.isEnabled('security')) {
                      FluxyFeatureToggle.kill('security');
                    } else {
                      FluxyFeatureToggle.restore('security');
                    }
                  },
                ),
              ),
            ],
          ),
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

  Widget _buildSidebar() {
    return Fx.sidebar(
      style: FxStyle(
        backgroundColor: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      header: Fx.col(
        gap: 16,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.box(
            style: const FxStyle(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Fx.col(
              gap: 4,
              alignItems: CrossAxisAlignment.start,
              children: [
                Fx.text(
                  'FLUX KERNEL',
                ).font.xl2().bold().color(Colors.blue.shade800),
                Fx.text(
                  'V 2.5.0-STABLE',
                ).font.xs().muted().bold().letterSpacing(1.2),
              ],
            ),
          ),
          // Sidebar Search Integration
          Fx.box(
            style: const FxStyle(padding: EdgeInsets.symmetric(horizontal: 12)),
            child: Fx.input(
              signal: searchSignal,
              placeholder: 'Quick search...',
              icon: Icons.search_rounded,
              style: FxStyle(
                backgroundColor: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      items: [
        _sidebarCategory('OPERATIONS'),
        _sidebarItem(
          Icons.dashboard_outlined,
          'Status Overview',
          isSelected: true,
        ),
        _sidebarItem(Icons.sensors_rounded, 'Real-time Telemetry'),
        _sidebarItem(Icons.history_rounded, 'Audit Logs'),

        Fx.gap(16),
        _sidebarCategory('INFRASTRUCTURE'),
        _sidebarItem(Icons.security_outlined, 'Security Vault'),
        _sidebarItem(Icons.sync_outlined, 'Sync Engine'),
        _sidebarItem(Icons.hub_outlined, 'Node Network'),

        Fx.gap(16),
        _sidebarCategory('MAINTENANCE'),
        _sidebarItem(Icons.settings_outlined, 'Kernel Configuration'),
        _sidebarItem(Icons.update_rounded, 'OTA Management'),

        const Divider(height: 32),
        _sidebarItem(Icons.help_outline, 'Documentation'),
      ],
      footer: Fx.box(
        style: FxStyle(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.grey.shade50,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Fx.row(
          gap: 12,
          children: [
            Fx.avatar(
              fallback: 'SJ',
              size: FxAvatarSize.sm,
              style: FxStyle(backgroundColor: Colors.blue.shade100),
            ),
            Fx.col(
              alignItems: CrossAxisAlignment.start,
              children: [
                Fx.text('Sarah Jenkins').font.sm().bold(),
                Fx.text('Principal Architect').font.xs().muted(),
              ],
            ),
            const Spacer(),
            Fx.icon(
              Icons.logout_rounded,
              size: 18,
              color: Colors.grey.shade600,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarCategory(String label) {
    return Fx.box(
      style: const FxStyle(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
      child: Fx.text(label).font.xs().bold().muted().letterSpacing(1.2),
    );
  }

  Widget _sidebarItem(IconData icon, String label, {bool isSelected = false}) {
    return Fx.row(
      gap: 12,
      style: FxStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isSelected ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        Fx.icon(icon, color: isSelected ? Colors.blue : Colors.grey.shade600),
        Fx.text(label).style(
          FxStyle(
            color: isSelected ? Colors.blue : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ).onTap(() {
      Fx.toast.info('Navigating to $label...');
    });
  }
  Widget _buildButtonsSection() {
    return Fx.box(
      style: FxStyle(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        shadows: FxTokens.shadow.sm,
      ),
      child: Fx.col(
        gap: 20,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.text('Fluxy Button System').font.xl().bold().color(Colors.blue.shade800),
          Fx.text('Industrial components with reactive states and atomic styling.').font.sm().muted(),
          
          const Divider(),
          
          Fx.text('Variants').font.sm().bold().muted(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Fx.button('Primary', onTap: () {}),
              Fx.secondaryButton('Secondary', onTap: () {}),
              Fx.outlineButton('Outline', onTap: () {}),
              Fx.ghostButton('Ghost', onTap: () {}),
              Fx.dangerButton('Danger', onTap: () {}),
              Fx.successButton('Success', onTap: () {}),
              Fx.textButton('Text Button', onTap: () {}),
            ],
          ),

          Fx.text('Sizes').font.sm().bold().muted(),
          Fx.row(
            gap: 12,
            alignItems: CrossAxisAlignment.center,
            children: [
              Fx.button('XS').sizeXs(),
              Fx.button('SM').sizeSm(),
              Fx.button('MD').sizeMd(),
              Fx.button('LG').sizeLg(),
              Fx.button('XL').sizeXl(),
            ],
          ),

          Fx.text('States & Features').font.sm().bold().muted(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Fx.button('Loading').loading(),
              Fx.button('With Icon', onTap: () {}).withIcon(const Icon(Icons.add_rounded, size: 18, color: Colors.white)),
              Fx.button('Trailing', onTap: () {}).withTrailing(const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white)),
              Fx.button('Rounded', onTap: () {}).rounded,
              Fx.button('Shadowed', onTap: () {}).shadowLg(),
              Fx.button('Disabled'), 
            ],
          ),

          Fx.text('Custom Styling').font.sm().bold().muted(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Fx.button('Indigo Custom', onTap: () {}).bg(Colors.indigo).rounded,
              Fx.button('Glassmorphic', onTap: () {}).applyStyle(FxStyle(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                color: Colors.blue,
              )),
              Fx.button('Neumorphic', onTap: () {}).applyStyle(FxStyle(
                backgroundColor: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                shadows: [
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
                color: Colors.grey.shade800,
              )),
            ],
          ),
          
          Fx.button('Full Width Action', onTap: () {}).primary.fullWidth().sizeLg(),
        ],
      ),
    );
  }

  Widget _buildFlexDemoSection() {
    return Fx.box(
      style: FxStyle(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        shadows: Fx.shadow.md,
      ),
      child: Fx.col(
        gap: 16,
        alignItems: CrossAxisAlignment.start,
        children: [
          Fx.row(
            justify: MainAxisAlignment.spaceBetween,
            children: [
              Fx.text('Web-Style Flex Layout').font.xl().bold().color(Colors.blue.shade900),
              Fx.box(
                style: FxStyle(
                  backgroundColor: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
                child: Fx.text('NEW').font.xs().bold().color(Colors.white),
              ),
            ],
          ),
          Fx.text('Testing the new "flex" style property on Box widgets without using Expanded.')
              .muted(),
          
          Fx.box(
            style: FxStyle(
              height: 140,
              backgroundColor: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              padding: const EdgeInsets.all(8),
              direction: Axis.horizontal, // Row orientation
              gap: 8,
            ),
            children: [
              // Fixed width box
              Fx.box(
                style: FxStyle(
                  width: 90,
                  backgroundColor: Colors.indigo.shade400,
                  borderRadius: BorderRadius.circular(8),
                  justifyContent: MainAxisAlignment.center,
                  alignItems: CrossAxisAlignment.center,
                ),
                child: Fx.text('FIXED\n90px').color(Colors.white).textCenter(),
              ),
              
              // Flexible box with flex: 1
              Fx.box(
                style: FxStyle(
                  flex: 1,
                  backgroundColor: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(8),
                  justifyContent: MainAxisAlignment.center,
                  alignItems: CrossAxisAlignment.center,
                ),
                child: Fx.text('FLEX 1\n(Auto)').color(Colors.white).textCenter(),
              ),
              
              // Flexible box with flex: 2
              Fx.box(
                style: FxStyle(
                  flex: 2,
                  backgroundColor: Colors.teal.shade400,
                  borderRadius: BorderRadius.circular(8),
                  justifyContent: MainAxisAlignment.center,
                  alignItems: CrossAxisAlignment.center,
                ),
                child: Fx.text('FLEX 2\n(Double)').color(Colors.white).textCenter(),
              ),
            ],
          ),
          
          Fx.row(
            gap: 8,
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.blue),
              Fx.text('The blue boxes are auto-scaling based on the remaining space.').font.xs().italic(),
            ],
          ),
        ],
      ),
    );
  }
}
