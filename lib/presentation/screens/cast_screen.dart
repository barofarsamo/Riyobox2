import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riyobox/services/cast_service.dart';

class CastScreen extends StatefulWidget {
  const CastScreen({super.key});

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  final String _sampleVideoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = context.read<CastService>();
      await service.initContext();
      service.startScanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    final castService = context.watch<CastService>();

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text('CAST TO DEVICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!castService.isScanning)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.deepPurpleAccent),
              onPressed: () => castService.startScanning(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (castService.isScanning && castService.devices.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)))
          else if (castService.devices.isEmpty)
             Expanded(
               child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cast, size: 80, color: Colors.white10),
                    const SizedBox(height: 16),
                    const Text('No devices found', style: TextStyle(color: Colors.white70)),
                    TextButton(onPressed: () => castService.startScanning(), child: const Text('SEARCH AGAIN')),
                  ],
                ),
            ),
             )
          else
            Expanded(
              child: ListView.builder(
                itemCount: castService.devices.length,
                itemBuilder: (context, index) {
                  final device = castService.devices[index];
                  final isConnected = castService.isConnected && castService.selectedDevice == device;

                  return ListTile(
                    leading: Icon(Icons.cast, color: isConnected ? Colors.deepPurpleAccent : Colors.white70),
                    title: Text(device.friendlyName, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(device.modelName ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: isConnected
                      ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent)
                      : null,
                    onTap: () async {
                      if (isConnected) {
                        await castService.disconnect();
                      } else {
                        await castService.connectToDevice(device);
                      }
                    },
                  );
                },
              ),
            ),
          if (castService.isConnected)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1C1C1C),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cast_connected, color: Colors.deepPurpleAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Connected to ${castService.selectedDevice?.friendlyName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(onPressed: () => castService.disconnect(), icon: const Icon(Icons.close, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => castService.loadMedia(_sampleVideoUrl, title: 'Big Buck Bunny'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                        child: const Text('CAST SAMPLE VIDEO'),
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
}
