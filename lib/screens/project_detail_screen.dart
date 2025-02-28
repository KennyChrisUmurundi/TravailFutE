import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travail_fute/constants.dart';
import 'package:travail_fute/services/project_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final ProjectService _projectService = ProjectService();
  final List<File> _images = [];
  List<String> _uploadedImages = [];
  Map<String, String> _imageCaptions = {};
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, dynamic>>.from(widget.project['comments'] ?? []);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _isCompleted = widget.project['is_completed'] ?? false;
    _uploadedImages = List<String>.from((widget.project['images'] ?? []).map((image) => image['image'] ?? ''));
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? caption = await _showCaptionDialog(context);
      setState(() {
        _images.add(File(pickedFile.path));
        if (caption != null && caption.isNotEmpty) {
          _imageCaptions[pickedFile.path] = caption;
        }
      });
      try {
        final url = await _projectService.addImage(context, widget.project["id"].toString(), pickedFile.path);
        if (url != null) {
          setState(() {
            _uploadedImages.add(url);
            if (caption != null && caption.isNotEmpty) {
              _imageCaptions[url] = caption;
              _imageCaptions.remove(pickedFile.path);
            }
            _images.removeWhere((file) => file.path == pickedFile.path);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement de l\'image: $e')),
        );
      }
    }
  }

  Future<String?> _showCaptionDialog(BuildContext context) async {
    final TextEditingController captionController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une légende', style: TextStyle(fontFamily: 'Poppins')),
        content: TextField(
          controller: captionController,
          decoration: InputDecoration(
            hintText: 'Entrez une légende (optionnel)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Passer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, captionController.text),
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(String image) async {
    try {
      setState(() {
        if (image.startsWith('http')) {
          _uploadedImages.remove(image);
        } else {
          _images.removeWhere((file) => file.path == image);
        }
        _imageCaptions.remove(image);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'image: $e')),
      );
    }
  }

  void _showFullImage(String image, String? caption) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: image.startsWith('http')
                      ? CachedNetworkImage(imageUrl: image, fit: BoxFit.contain)
                      : Image.file(File(image), fit: BoxFit.contain),
                ),
              ),
            ),
            if (caption != null && caption.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    caption,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleComplete() async {
    setState(() => _isLoading = true);
    try {
      await _projectService.updateProject(context, widget.project['id'], {'is_completed': !_isCompleted});
      setState(() => _isCompleted = !_isCompleted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isCompleted ? 'Chantier marqué comme terminé' : 'Chantier réouvert')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final commentText = _commentController.text.trim();
    setState(() {
      _comments.add({
        'content': commentText,
        'timestamp': DateTime.now(),
      });
      _commentController.clear();
    });
    try {
      await _projectService.addComment(context, widget.project["id"].toString(), commentText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du commentaire: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(width),
                    SizedBox(height: width * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProjectInfo(width),
                          SizedBox(height: width * 0.06),
                          _buildImageSection(width),
                          SizedBox(height: width * 0.06),
                          _buildCommentsSection(width),
                          SizedBox(height: width * 0.1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(width),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(width),
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: kTravailFuteMainColor, size: width * 0.06),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    child: Image.asset('assets/images/splash.png'),
                  ),
                  SizedBox(width: width * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(double width) {
    final startDate = widget.project['start_date'] != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(DateTime.parse(widget.project['start_date']))
        : 'Non défini';
    final endDate = widget.project['end_date'] != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(DateTime.parse(widget.project['end_date']))
        : 'Non défini';

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: kWhiteColor,
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.project['name'] ?? 'Chantier sans nom',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w700,
                      color: kTravailFuteSecondaryColor,
                    ),
                  ),
                ),
                Icon(
                  _isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: _isCompleted ? Colors.green : kTravailFuteMainColor,
                  size: width * 0.06,
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            Text(
              widget.project['description'] ?? 'Aucune description',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: width * 0.04,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: width * 0.04),
            Row(
              children: [
                Icon(Icons.calendar_today, color: kTravailFuteMainColor, size: width * 0.05),
                SizedBox(width: width * 0.03),
                Text(
                  'Début: $startDate',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width * 0.04,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: kTravailFuteMainColor, size: width * 0.05),
                SizedBox(width: width * 0.03),
                Text(
                  'Fin: $endDate',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width * 0.04,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(double width) {
    final allImages = [..._uploadedImages, ..._images.map((file) => file.path)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Images',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              color: kTravailFuteMainColor,
            ),
          ),
        ),
        SizedBox(height: width * 0.03),
        SizedBox(
          height: width * 0.45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allImages.length + 1,
            itemBuilder: (context, index) {
              if (index == allImages.length) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: width * 0.4,
                    margin: EdgeInsets.only(right: width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: kTravailFuteMainColor, size: width * 0.08),
                        SizedBox(height: width * 0.02),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: width * 0.035,
                            color: kTravailFuteMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final image = allImages[index];
              final caption = _imageCaptions[image];

              return GestureDetector(
                onTap: () => _showFullImage(image, caption),
                child: Container(
                  width: width * 0.4,
                  margin: EdgeInsets.only(right: width * 0.03),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: image.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: image,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: kTravailFuteMainColor,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: width * 0.08,
                                      ),
                                    )
                                  : Image.file(File(image), fit: BoxFit.cover),
                            ),
                          ),
                          // if (caption != null && caption.isNotEmpty)
                          //   Container(
                          //     width: double.infinity,
                          //     padding: EdgeInsets.all(width * 0.015),
                          //     decoration: BoxDecoration(
                          //       color: Colors.black.withOpacity(0.7),
                          //     ),
                          //     child: Text(
                          //       caption,
                          //       style: TextStyle(
                          //         fontFamily: 'Poppins',
                          //         fontSize: width * 0.02,
                          //         color: Colors.white,
                          //       ),
                          //       maxLines: 2,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                        ],
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _deleteImage(image),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: width * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Commentaires',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              color: kTravailFuteMainColor,
            ),
          ),
        ),
        SizedBox(height: width * 0.03),
        ..._comments.map((comment) {
          return Padding(
            padding: EdgeInsets.only(bottom: width * 0.02),
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment['content'] ?? 'Aucun contenu',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.04,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: width * 0.015),
                  Text(
                    DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(
                      comment['created_at'] != null ? DateTime.parse(comment['created_at']) : DateTime.now()
                    ),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        SizedBox(height: width * 0.04),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Ajouter un commentaire',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                      fontSize: width * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: width * 0.04,
                      horizontal: width * 0.04,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.03),
            GestureDetector(
              onTap: _addComment,
              child: Container(
                padding: EdgeInsets.all(width * 0.03),
                decoration: BoxDecoration(
                  color: kTravailFuteMainColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kTravailFuteMainColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.send, color: kWhiteColor, size: width * 0.06),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(double width) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kTravailFuteMainColor),
            strokeWidth: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(double width) {
    return FloatingActionButton(
      onPressed: _toggleComplete,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kTravailFuteMainColor, kTravailFuteSecondaryColor],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kTravailFuteMainColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(width * 0.04),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            _isCompleted ? Icons.undo : Icons.check,
            size: width * 0.07,
            color: kWhiteColor,
          ),
        ),
      ),
    );
  }
}