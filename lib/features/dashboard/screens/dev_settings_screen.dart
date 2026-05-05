import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  State<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  final _urlController = TextEditingController();
  String _currentUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final url = await ApiService.getBaseUrl();
    setState(() {
      _currentUrl = url;
      _urlController.text = url;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Server URL',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: $_currentUrl',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'http://192.168.x.x:3000/api',
                      prefixIcon: Icon(Icons.dns_outlined, color: AppColors.primaryTeal),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final newUrl = _urlController.text.trim();
                            if (newUrl.isEmpty) return;
                            await ApiService.setBaseUrl(newUrl);
                            setState(() => _currentUrl = newUrl);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Server URL updated to: $newUrl')),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save URL'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ApiService.resetBaseUrl();
                          final url = await ApiService.getBaseUrl();
                          setState(() {
                            _currentUrl = url;
                            _urlController.text = url;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset to default URL')),
                            );
                          }
                        },
                        icon: const Icon(Icons.restore),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Quick connect buttons for common setups
                  Text(
                    'Quick Connect',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickConnectTile(
                    title: 'Android Emulator',
                    url: 'http://10.0.2.2:3000/api',
                    onTap: (url) async {
                      _urlController.text = url;
                      await ApiService.setBaseUrl(url);
                      setState(() => _currentUrl = url);
                    },
                  ),
                  _QuickConnectTile(
                    title: 'iOS Simulator',
                    url: 'http://localhost:3000/api',
                    onTap: (url) async {
                      _urlController.text = url;
                      await ApiService.setBaseUrl(url);
                      setState(() => _currentUrl = url);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}


class _QuickConnectTile extends StatelessWidget {
  final String title;
  final String url;
  final Function(String) onTap;

  const _QuickConnectTile({
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.link, color: AppColors.primaryTeal),
      title: Text(title),
      subtitle: Text(url, style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => onTap(url),
      ),
      onTap: () => onTap(url),
    );
  }
}
