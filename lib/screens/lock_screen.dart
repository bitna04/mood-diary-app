import 'package:flutter/material.dart';
import 'dart:math';
import '../services/security_service.dart';

enum LockScreenMode { unlock, setup, change }

enum _LockStep {
  unlock,
  setupEnter,
  setupConfirm,
  changeVerify,
  changeEnter,
  changeConfirm,
}

class LockScreen extends StatefulWidget {
  final LockScreenMode mode;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  const LockScreen({
    super.key,
    required this.mode,
    required this.onSuccess,
    this.onCancel,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late _LockStep _step;
  String _entered = '';
  String _firstPin = '';
  bool _biometricAvailable = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize step based on mode
    switch (widget.mode) {
      case LockScreenMode.unlock:
        _step = _LockStep.unlock;
        break;
      case LockScreenMode.setup:
        _step = _LockStep.setupEnter;
        break;
      case LockScreenMode.change:
        _step = _LockStep.changeVerify;
        break;
    }

    // Setup shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Check biometric availability if in unlock mode
    if (widget.mode == LockScreenMode.unlock) {
      _checkBiometricAvailability();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await SecurityService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _biometricAvailable =
            available && SecurityService.isBiometricEnabled();
      });
      if (_biometricAvailable) {
        Future.delayed(const Duration(milliseconds: 300), _triggerBiometrics);
      }
    }
  }

  void _onDigitPressed(String digit) {
    if (_entered.length >= 4) return;
    setState(() => _entered += digit);
    if (_entered.length == 4) {
      Future.microtask(_handleComplete);
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  void _handleComplete() {
    switch (_step) {
      case _LockStep.unlock:
        if (SecurityService.verifyPin(_entered)) {
          widget.onSuccess();
        } else {
          _shake();
          setState(() => _entered = '');
        }
        break;

      case _LockStep.setupEnter:
        setState(() {
          _firstPin = _entered;
          _entered = '';
          _step = _LockStep.setupConfirm;
        });
        break;

      case _LockStep.setupConfirm:
        if (_entered == _firstPin) {
          SecurityService.savePin(_entered).then((_) {
            if (mounted) widget.onSuccess();
          });
        } else {
          _shake();
          setState(() {
            _entered = '';
            _step = _LockStep.setupEnter;
            _firstPin = '';
          });
        }
        break;

      case _LockStep.changeVerify:
        if (SecurityService.verifyPin(_entered)) {
          setState(() {
            _entered = '';
            _step = _LockStep.changeEnter;
          });
        } else {
          _shake();
          setState(() => _entered = '');
        }
        break;

      case _LockStep.changeEnter:
        setState(() {
          _firstPin = _entered;
          _entered = '';
          _step = _LockStep.changeConfirm;
        });
        break;

      case _LockStep.changeConfirm:
        if (_entered == _firstPin) {
          SecurityService.savePin(_entered).then((_) {
            if (mounted) widget.onSuccess();
          });
        } else {
          _shake();
          setState(() {
            _entered = '';
            _step = _LockStep.changeEnter;
            _firstPin = '';
          });
        }
        break;
    }
  }

  void _shake() {
    _shakeController.forward(from: 0);
  }

  Future<void> _triggerBiometrics() async {
    final success = await SecurityService.authenticateWithBiometrics();
    if (success && mounted) {
      widget.onSuccess();
    }
  }

  String get _subtitle {
    switch (_step) {
      case _LockStep.unlock:
        return 'Enter your PIN';
      case _LockStep.setupEnter:
        return 'Create a 4-digit PIN';
      case _LockStep.setupConfirm:
        return 'Confirm your PIN';
      case _LockStep.changeVerify:
        return 'Enter current PIN';
      case _LockStep.changeEnter:
        return 'Enter new PIN';
      case _LockStep.changeConfirm:
        return 'Confirm new PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentPink =
        isDarkMode ? Colors.pink.shade400 : Colors.pink.shade300;

    return WillPopScope(
      onWillPop: () async {
        if (widget.mode != LockScreenMode.unlock) {
          widget.onCancel?.call();
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        appBar: widget.mode != LockScreenMode.unlock
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
                elevation: 0,
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: accentPink,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // PIN dots
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          sin(_shakeAnimation.value * 4 * pi) * 8,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => _buildDot(index, isDarkMode, accentPink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Keypad
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        if (index < 9) {
                          final digit = (index + 1).toString();
                          return _buildKeypadButton(
                            digit,
                            isDarkMode,
                            accentPink,
                            () => _onDigitPressed(digit),
                          );
                        } else if (index == 9) {
                          return SizedBox.shrink();
                        } else if (index == 10) {
                          return _buildKeypadButton(
                            '0',
                            isDarkMode,
                            accentPink,
                            () => _onDigitPressed('0'),
                          );
                        } else {
                          return _buildBackspaceButton(isDarkMode, accentPink);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Biometric button
                  if (_biometricAvailable && _step == _LockStep.unlock)
                    IconButton(
                      icon: Icon(
                        Icons.fingerprint,
                        size: 48,
                        color: accentPink,
                      ),
                      onPressed: _triggerBiometrics,
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, bool isDarkMode, Color accentPink) {
    final filled = index < _entered.length;
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? accentPink : Colors.transparent,
        border: Border.all(
          color: filled ? accentPink : Colors.pink.shade300,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildKeypadButton(
    String label,
    bool isDarkMode,
    Color accentPink,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.pink.shade50,
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.pink.shade200,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(bool isDarkMode, Color accentPink) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackspace,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.pink.shade50,
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.pink.shade200,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: accentPink,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
