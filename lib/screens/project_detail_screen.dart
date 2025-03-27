import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/project_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final List<File> _images = [];
  List<String> _uploadedImages = [];
  Map<String, String> _imageCaptions = {};
  bool _isLoading = false;
  final Color _primaryColor = const Color(0xFFe29a32);
  final Color _accentColor = const Color(0xFFF5C77C);
  final ImagePicker _picker = ImagePicker();
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _uploadedImages = List<String>.from((widget.project['images'] ?? []).map((image) => image['image'] ?? ''));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required ImageSource source}) async {
    try {
      setState(() => _isLoading = true);

      // Pick the image
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        // Show caption dialog
        String? caption = await _showCaptionDialog(context);

        // Call projectService().addImage
        try {
          final response = await ProjectService().addImage(
            context,
            widget.project['id'].toString(),
            imageFile.path,
            caption ?? '',
          );
          if(mounted){
            setState(() {
              _uploadedImages.add(response);
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showCaptionDialog(BuildContext context) async {
    final TextEditingController captionController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
            'Ajouter une description',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: _primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: captionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Décrivez ce moment...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: _accentColor.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
            TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Ignorer', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ),
            ElevatedButton(
            onPressed: () => Navigator.pop(context, captionController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showFullImage(List<String> allImages, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: allImages.length,
              controller: PageController(initialPage: initialIndex, viewportFraction: 0.95),
              itemBuilder: (context, index) {
                final image = allImages[index];
                final caption = _imageCaptions[image];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: image.startsWith('http')
                              ? CachedNetworkImage(imageUrl: image, fit: BoxFit.contain)
                              : Image.file(File(image), fit: BoxFit.contain),
                        ),
                      ),
                      if (caption != null && caption.isNotEmpty)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              caption,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SmoothPageIndicator(
                controller: PageController(initialPage: initialIndex),
                count: allImages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: _primaryColor,
                  dotColor: Colors.white.withOpacity(0.5),
                  expansionFactor: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildHeader(Size size, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhiteColor.withOpacity(0.2),
              ),
              child: Icon(Icons.arrow_back, color: kWhiteColor, size: width * 0.06),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: Text(
                'Projects',
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kWhiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final allImages = [..._uploadedImages, ..._images.map((file) => file.path)];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(size, width),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClientInfo(width),
                          const SizedBox(height: 24),
                          _buildImageSection(width, allImages),
                          const SizedBox(height: 24),
                          _buildAddPhotoButtons(width),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo(double width) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.project['client'] ?? 'No client name',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: width * 0.06,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            // Text supports Unicode characters including French accents (é, è, ê, ë, à, â, etc.)
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, size: 24, color: _primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.project['address'] ?? 'No address specified',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(double width, List<String> allImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Photos (${allImages.length})',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
            if (allImages.isNotEmpty)
              TextButton(
                onPressed: () => _showFullImage(allImages, 0),
                child: Text(
                  'View All',
                  style: TextStyle(color: _primaryColor, fontSize: 14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        allImages.isEmpty
            ? Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.photo_library, size: 64, color: _accentColor),
                    const SizedBox(height: 16),
                    Text(
                        'Aucune photo pour le moment',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                        'Capturez vos progrès de travail',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 400,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: allImages.length,
                  itemBuilder: (context, index) {
                    final image = allImages[index];
                    final caption = _imageCaptions[image];

                    return GestureDetector(
                      onTap: () => _showFullImage(allImages, index),
                      child: Hero(
                        tag: image,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                image.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: Center(child: CircularProgressIndicator(color: _primaryColor)),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    : Image.file(File(image), fit: BoxFit.cover),
                                if (caption != null && caption.isNotEmpty)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        caption,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildAddPhotoButtons(double width) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 24, color: Colors.white),
            label: const Text(
              'Camera',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _pickImage(source: ImageSource.camera),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              shadowColor: _primaryColor.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.photo_library, size: 24, color: _primaryColor),
            label: Text(
              'Gallery',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _pickImage(source: ImageSource.gallery),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                strokeWidth: 3,
              ),
              const SizedBox(height: 12),
              Text(
                'Traitement en cours...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}