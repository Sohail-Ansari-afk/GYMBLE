import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/services/api_service.dart';
import '../../core/services/location_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/api_provider.dart';

enum CheckInMethod { qr, manual }

class DualCheckinScreen extends ConsumerStatefulWidget {
  const DualCheckinScreen({super.key});

  @override
  ConsumerState<DualCheckinScreen> createState() => _DualCheckinScreenState();
}

class _DualCheckinScreenState extends ConsumerState<DualCheckinScreen> {
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  
  bool _isLoading = false;
  bool _isTorchOn = false;
  bool _isScanning = true;
  String? _errorMessage;
  CheckInMethod _activeMethod = CheckInMethod.qr;
  Timer? _scanTimeoutTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Default to manual code entry on web platforms
    if (kIsWeb) {
      _activeMethod = CheckInMethod.manual;
      _isScanning = false;
    } else {
      _startScanTimeout();
    }
  }
  
  @override
  void dispose() {
    _codeController.dispose();
    _scannerController.dispose();
    _scanTimeoutTimer?.cancel();
    super.dispose();
  }
  
  void _startScanTimeout() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _isScanning) {
        setState(() {
          _isScanning = false;
          _activeMethod = CheckInMethod.manual;
        });
      }
    });
  }
  
  void _resetScanTimeout() {
    if (_activeMethod == CheckInMethod.qr) {
      _startScanTimeout();
    }
  }
  
  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
      _scannerController.toggleTorch();
    });
  }
  
  void _switchMethod(CheckInMethod method) {
    setState(() {
      _activeMethod = method;
      _errorMessage = null;
      
      if (method == CheckInMethod.qr) {
        _isScanning = true;
        _startScanTimeout();
      } else {
        _scanTimeoutTimer?.cancel();
      }
    });
  }
  
  Future<void> _processCheckIn(String code, CheckInMethod method) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get current location
      final locationService = ref.read(locationServiceProvider);
      final hasLocationPermission = await locationService.requestLocationPermission();
      
      if (!hasLocationPermission) {
        setState(() {
          _errorMessage = 'Location permission is required for check-in';
          _isLoading = false;
        });
        return;
      }
      
      final position = await locationService.getCurrentPosition();
      
      if (position == null) {
        setState(() {
          _errorMessage = 'Unable to get current location';
          _isLoading = false;
        });
        return;
      }
      
      // Get user token from auth provider
      final authState = ref.read(authStateProvider);
      final token = authState.user?.token;
      
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication error. Please log in again.';
          _isLoading = false;
        });
        return;
      }
      
      // Get API service from provider
      final apiService = ref.read(apiServiceProvider);
      
      // Send check-in request
      final result = await apiService.checkIn(
        method: method == CheckInMethod.qr ? 'qr' : 'manual',
        code: code,
        latitude: position.latitude,
        longitude: position.longitude,
        token: token,
      );
      
      // Show success message
      if (mounted) {
        _showSuccessAlert();
        setState(() {
          _isLoading = false;
          if (method == CheckInMethod.manual) {
            _codeController.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  void _onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
      final code = barcodes[0].rawValue!;
      _scannerController.stop();
      _scanTimeoutTimer?.cancel();
      _processCheckIn(code, CheckInMethod.qr);
    }
  }
  
  void _submitManualCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a check-in code';
      });
      return;
    }
    
    _processCheckIn(code, CheckInMethod.manual);
  }
  
  void _showSuccessAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Check-in Successful'),
        content: const Text('You have successfully checked in.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Check-in'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Method selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: kIsWeb
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Manual Code Entry',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : CupertinoSlidingSegmentedControl<CheckInMethod>(
                    groupValue: _activeMethod,
                    onValueChanged: (value) {
                      if (value != null) {
                        _switchMethod(value);
                      }
                    },
                    children: const {
                      CheckInMethod.qr: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('QR Scanner'),
                      ),
                      CheckInMethod.manual: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Manual Code'),
                      ),
                    },
                  ),
            ),
            
            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            
            // QR Scanner
            if (_activeMethod == CheckInMethod.qr)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: kIsWeb
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.camera_fill,
                              size: 64,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Camera access is not available on web',
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              onPressed: () => _switchMethod(CheckInMethod.manual),
                              child: const Text('Switch to Manual Code'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // QR Scanner
                                  MobileScanner(
                                    controller: _scannerController,
                                    onDetect: _onQRCodeDetected,
                                  ),
                                  
                                  // Scanner overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: CupertinoColors.activeBlue,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    width: 250,
                                    height: 250,
                                  ),
                                  
                                  // Loading indicator
                                  if (_isLoading)
                                    Container(
                                      color: CupertinoColors.black.withOpacity(0.5),
                                      child: const CupertinoActivityIndicator(
                                        radius: 20,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      
                      const SizedBox(height: 16),
                      
                      // Torch toggle button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _toggleTorch,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isTorchOn
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.lightbulb,
                                color: _isTorchOn
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isTorchOn ? 'Turn Off Torch' : 'Turn On Torch',
                                style: TextStyle(
                                  color: _isTorchOn
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Scan will timeout in 30 seconds',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Manual Code Entry
            if (_activeMethod == CheckInMethod.manual)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter Check-in Code',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CupertinoTextField(
                        controller: _codeController,
                        placeholder: 'Enter code',
                        padding: const EdgeInsets.all(16),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      CupertinoButton.filled(
                        onPressed: _isLoading ? null : _submitManualCode,
                        child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}