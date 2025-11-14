import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _useMaterial = true;

  @override
  Widget build(BuildContext context) {
    return _useMaterial
        ? MaterialApp(
            title: 'Check weather AI',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: WeatherScreen(
              useMaterial: _useMaterial,
              onDesignSystemChanged: (bool useMaterial) {
                setState(() {
                  _useMaterial = useMaterial;
                });
              },
            ),
            debugShowCheckedModeBanner: false,
          )
        : CupertinoApp(
            title: 'Check weather AI',
            home: WeatherScreen(
              useMaterial: _useMaterial,
              onDesignSystemChanged: (bool useMaterial) {
                setState(() {
                  _useMaterial = useMaterial;
                });
              },
            ),
            debugShowCheckedModeBanner: false,
          );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.useMaterial,
    required this.onDesignSystemChanged,
  });

  final bool useMaterial;
  final Function(bool) onDesignSystemChanged;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _locationController = TextEditingController();
  double _progress = 0.0;
  String _statusText = '';
  bool _isChecking = false;

  final List<String> _statusSequence = [
    'Find location...',
    'Humidity...',
    'Temperature...',
    'Wind speed...',
    'Cloudy...',
    'Done',
  ];

  Future<void> _checkWeather() async {
    if (_locationController.text.trim().isEmpty) {
      _showValidationError('Please enter location name');
      return;
    }

    setState(() {
      _isChecking = true;
      _progress = 0.0;
      _statusText = '';
    });

    for (int i = 0; i <= 5; i++) {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _progress = (i + 1) * 0.2;
          if (i < 5) {
            _statusText = '${_statusSequence[i]}(${((i + 1) * 20).toInt()}%)';
          } else {
            _statusText = 'Done(100%)';
          }
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      _showTrollMessage();
    }
  }

  Widget _buildMaterialContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: 'Enter location name',
            border: OutlineInputBorder(),
          ),
          enabled: !_isChecking,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isChecking ? null : _checkWeather,
          child: Text(_isChecking ? 'Checking...' : 'Check'),
        ),
        const SizedBox(height: 24),
        if (_isChecking) ...[
          LinearProgressIndicator(value: _progress, minHeight: 8),
          const SizedBox(height: 8),
          Text(_statusText, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }

  Widget _buildCupertinoContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoTextField(
          controller: _locationController,
          placeholder: 'Enter location name',
          enabled: !_isChecking,
        ),
        const SizedBox(height: 16),
        CupertinoButton.filled(
          onPressed: _isChecking ? null : _checkWeather,
          child: Text(_isChecking ? 'Checking...' : 'Check'),
        ),
        const SizedBox(height: 24),
        if (_isChecking) ...[
          LinearProgressIndicator(value: _progress, minHeight: 8),
          const SizedBox(height: 8),
          Text(_statusText, style: const TextStyle(fontSize: 16)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.useMaterial
        ? _buildMaterialAppContent()
        : _buildCupertinoAppContent();
  }

  Widget _buildMaterialAppContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check weather AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildMaterialContent(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Design System: '),
              ToggleButtons(
                isSelected: [widget.useMaterial, !widget.useMaterial],
                onPressed: (int index) {
                  widget.onDesignSystemChanged(index == 0);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Material'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Cupertino'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoAppContent() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Check weather AI'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildCupertinoContent(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Design System: '),
                  CupertinoSlidingSegmentedControl<bool>(
                    groupValue: widget.useMaterial,
                    onValueChanged: (bool? value) {
                      if (value != null) {
                        widget.onDesignSystemChanged(value);
                      }
                    },
                    children: const {
                      true: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Material'),
                      ),
                      false: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Cupertino'),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationError(String message) {
    if (widget.useMaterial) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Alert'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showTrollMessage() {
    if (widget.useMaterial) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Look out the window'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Look out the window'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
