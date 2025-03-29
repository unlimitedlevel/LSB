import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../utils/app_theme.dart';
import 'animated_widgets.dart';

class ImageInput extends StatefulWidget {
  final Function(dynamic) onImageSelected;

  const ImageInput({super.key, required this.onImageSelected});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> with TickerProviderStateMixin {
  XFile? _imageFile;
  Uint8List? _imagePreview;
  final ImagePicker _picker = ImagePicker();
  bool _isHovered = false;
  bool _isLoading = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Konfigurasi animasi scale untuk efek hover
    _scaleController = AnimationController(
      vsync: this,
      duration: AppTheme.fastAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Animasi rotasi untuk ikon refresh
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _takeImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final bytes = await pickedImage.readAsBytes();

      setState(() {
        _imageFile = pickedImage;
        _imagePreview = bytes;
        _isLoading = false;
      });

      // Kirim XFile ke parent widget
      widget.onImageSelected(_imageFile);

      // Tutup bottom sheet secara otomatis
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error saat mengambil gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AnimatedCard(height: 200, child: _buildImagePreview()),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!kIsWeb)
                AnimatedGradientButton(
                  onPressed:
                      _isLoading ? () {} : () => _takeImage(ImageSource.camera),
                  text: 'Ambil Foto',
                  icon: Icons.camera_alt_rounded,
                  width: 150,
                  isLoading: _isLoading,
                ),
              AnimatedGradientButton(
                onPressed:
                    _isLoading ? () {} : () => _takeImage(ImageSource.gallery),
                text: 'Galeri',
                icon: Icons.photo_library_rounded,
                width: 150,
                isLoading: _isLoading,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Memproses...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_imagePreview != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'selected_image',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              child: Image.memory(_imagePreview!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: () {
                _rotateController.reset();
                _rotateController.forward();
                _takeImage(kIsWeb ? ImageSource.gallery : ImageSource.camera);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return FadeSlideTransition(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            PulseAnimation(
              child: Icon(
                Icons.cloud_upload_rounded,
                size: 48,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih gambar LSB untuk diproses',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Format gambar: JPG, PNG',
              style: TextStyle(color: AppTheme.textLight, fontSize: 12),
            ),
          ],
        ),
      );
    }
  }
}
