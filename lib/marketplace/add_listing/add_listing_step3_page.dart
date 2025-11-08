import 'dart:io' show File;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledev_ecowaste/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'listing_form_provider.dart';
import 'add_listing_confirmation_page.dart';

class AddListingStep3Page extends StatefulWidget {
  const AddListingStep3Page({super.key});

  @override
  State<AddListingStep3Page> createState() => _AddListingStep3PageState();
}

class _AddListingStep3PageState extends State<AddListingStep3Page> {
  bool _submitting = false;

  Future<String?> _uploadWithTimeout(Future<String?> Function() action, {Duration timeout = const Duration(seconds: 25)}) async {
    try {
      return await action().timeout(timeout, onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  void _showProofDialog(BuildContext context, {XFile? image, XFile? video}) {
    VideoPlayerController? controller;
    if (video != null && !kIsWeb) {
      controller = VideoPlayerController.file(File(video.path))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              controller!..play();
            });
          }
        });
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(12),
        content: image != null
            ? (kIsWeb
                ? Image.network(image.path)
                : Image.file(File(image.path)))
            : (!kIsWeb && controller != null && controller.value.isInitialized
                ? AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller))
                : const Text('Video preview not available.')),
        actions: [TextButton(child: const Text('Close'), onPressed: () => Navigator.of(ctx).pop())],
      ),
    ).then((_) => controller?.dispose());
  }

  String _formatAnswer(bool? answer) {
    // Treat unanswered as No per request
    return (answer ?? false) ? 'Yes' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingFormProvider>(
      builder: (context, formProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Review & Summary')),
          body: Column(
            children: [
              LinearProgressIndicator(value: formProvider.progress),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Text('Final Review', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildSummaryCard(
                      title: 'Device Information',
                      details: {
                        'Device Type': formProvider.deviceType ?? 'N/A',
                        'Brand': formProvider.brand ?? 'N/A',
                        'Model': formProvider.model ?? 'N/A',
                        'Storage': formProvider.storageCapacity ?? 'N/A',
                        'Color': formProvider.color ?? 'N/A',
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      title: 'Listing Details',
                      details: {
                        'Action': formProvider.listingType.name.toUpperCase(),
                        if (formProvider.listingType == ListingType.sell) 'Price': '₱${formProvider.price?.toStringAsFixed(0) ?? '0'}',
                        if (formProvider.listingType == ListingType.trade) 'Desired Trade': formProvider.tradeDetails ?? 'N/A',
                        'Accessories': formProvider.includedAccessories.isEmpty ? 'None' : formProvider.includedAccessories.join(', '),
                        'Repair History': formProvider.repairHistory?.isNotEmpty == true ? formProvider.repairHistory! : 'None',
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildConditionSummaryCard(context, formProvider),
                    const SizedBox(height: 16),
                    _buildPhotosCard(formProvider),
                  ],
                ),
              ),
              _buildFooterButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionSummaryCard(BuildContext context, ListingFormProvider formProvider) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condition Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(height: 24),
            _buildConditionRow(
              context,
              question: 'Powers on correctly?',
              answer: _formatAnswer(formProvider.powersOnCorrectly),
              proofFile: formProvider.powersOnProofVideo,
              isVideo: true,
            ),
            _buildConditionRow(
              context,
              question: 'Buttons functional?',
              answer: _formatAnswer(formProvider.buttonsFunctional),
              proofFile: formProvider.buttonsFunctionalProofVideo,
              isVideo: true,
            ),
            _buildConditionRow(
              context,
              question: 'Battery drains fast?',
              answer: _formatAnswer(formProvider.batteryDrainsFast),
              proofFile: formProvider.batteryDrainsFastProofPhoto,
            ),
            _buildConditionRow(
              context,
              question: 'Screen has damage?',
              answer: _formatAnswer(formProvider.screenHasDamage),
              proofFile: formProvider.screenDamageProofPhoto,
            ),
            _buildConditionRow(
              context,
              question: 'Touchscreen responsive?',
              answer: _formatAnswer(formProvider.touchscreenResponsive),
              proofFile: formProvider.touchscreenResponsiveProofVideo,
              isVideo: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionRow(BuildContext context, {required String question, required String answer, XFile? proofFile, bool isVideo = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(question, style: TextStyle(color: Colors.grey.shade600))),
          Text(answer, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          proofFile != null
              ? SizedBox(
                  height: 30,
                  child: OutlinedButton.icon(
                    icon: Icon(isVideo ? Icons.videocam_outlined : Icons.photo_camera_outlined, size: 16),
                    label: const Text('View'),
                    onPressed: () => _showProofDialog(context, image: isVideo ? null : proofFile, video: isVideo ? proofFile : null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                )
              : const SizedBox(width: 80, child: Text('No Proof', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required Map<String, String> details}) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(height: 24),
            ...details.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key}: ', style: TextStyle(color: Colors.grey.shade600)),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosCard(ListingFormProvider formProvider) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('General Photos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(height: 24),
            if (formProvider.devicePhotos.isEmpty)
              const Text('No photos uploaded.')
            else
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: formProvider.devicePhotos.length,
                  itemBuilder: (context, index) {
                    final photo = formProvider.devicePhotos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (kIsWeb
                          ? Image.network(photo.path, width: 80, height: 80, fit: BoxFit.cover)
                          : Image.file(File(photo.path), width: 80, height: 80, fit: BoxFit.cover)),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Provider.of<ListingFormProvider>(context, listen: false).previousStep();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: BorderSide(color: Colors.grey.shade300)),
              child: const Text('Go Back'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      final form = Provider.of<ListingFormProvider>(context, listen: false);
                      setState(() {
                        _submitting = true;
                      });
                      final supa = SupabaseService();
                      try {
                        // Upload photos
                        final imageUrls = <String>[];
                        for (final x in form.devicePhotos) {
                          String? url;
                          if (kIsWeb) {
                            final bytes = await x.readAsBytes();
                            final ext = x.name.contains('.') ? x.name.split('.').last : 'jpg';
                            url = await supa.uploadListingImageBytes(bytes, fileExt: ext);
                          } else {
                            url = await supa.uploadListingImage(File(x.path));
                          }
                          if (url != null) imageUrls.add(url);
                        }

                        // Upload verification proofs (reuse listing upload helpers)
                        String? powersOnVideoUrl;
                        if (form.powersOnProofVideo != null) {
                          if (kIsWeb) {
                            final bytes = await form.powersOnProofVideo!.readAsBytes();
                            final ext = form.powersOnProofVideo!.name.split('.').last;
                            powersOnVideoUrl = await _uploadWithTimeout(() => supa.uploadListingImageBytes(bytes, fileExt: ext));
                          } else {
                            powersOnVideoUrl = await _uploadWithTimeout(() => supa.uploadListingImage(File(form.powersOnProofVideo!.path)));
                          }
                        }

                        String? buttonsVideoUrl;
                        if (form.buttonsFunctionalProofVideo != null) {
                          if (kIsWeb) {
                            final bytes = await form.buttonsFunctionalProofVideo!.readAsBytes();
                            final ext = form.buttonsFunctionalProofVideo!.name.split('.').last;
                            buttonsVideoUrl = await _uploadWithTimeout(() => supa.uploadListingImageBytes(bytes, fileExt: ext));
                          } else {
                            buttonsVideoUrl = await _uploadWithTimeout(() => supa.uploadListingImage(File(form.buttonsFunctionalProofVideo!.path)));
                          }
                        }

                        String? batteryPhotoUrl;
                        if (form.batteryDrainsFastProofPhoto != null) {
                          if (kIsWeb) {
                            final bytes = await form.batteryDrainsFastProofPhoto!.readAsBytes();
                            final ext = form.batteryDrainsFastProofPhoto!.name.split('.').last;
                            batteryPhotoUrl = await _uploadWithTimeout(() => supa.uploadListingImageBytes(bytes, fileExt: ext));
                          } else {
                            batteryPhotoUrl = await _uploadWithTimeout(() => supa.uploadListingImage(File(form.batteryDrainsFastProofPhoto!.path)));
                          }
                        }

                        String? screenDamagePhotoUrl;
                        if (form.screenDamageProofPhoto != null) {
                          if (kIsWeb) {
                            final bytes = await form.screenDamageProofPhoto!.readAsBytes();
                            final ext = form.screenDamageProofPhoto!.name.split('.').last;
                            screenDamagePhotoUrl = await _uploadWithTimeout(() => supa.uploadListingImageBytes(bytes, fileExt: ext));
                          } else {
                            screenDamagePhotoUrl = await _uploadWithTimeout(() => supa.uploadListingImage(File(form.screenDamageProofPhoto!.path)));
                          }
                        }

                        String? touchscreenVideoUrl;
                        if (form.touchscreenResponsiveProofVideo != null) {
                          if (kIsWeb) {
                            final bytes = await form.touchscreenResponsiveProofVideo!.readAsBytes();
                            final ext = form.touchscreenResponsiveProofVideo!.name.split('.').last;
                            touchscreenVideoUrl = await _uploadWithTimeout(() => supa.uploadListingImageBytes(bytes, fileExt: ext));
                          } else {
                            touchscreenVideoUrl = await _uploadWithTimeout(() => supa.uploadListingImage(File(form.touchscreenResponsiveProofVideo!.path)));
                          }
                        }

                        // Compose title/description fallbacks
                        final composedTitle = (form.title != null && form.title!.trim().isNotEmpty)
                            ? form.title!.trim()
                            : [
                                form.brand,
                                form.model,
                                form.storageCapacity,
                                form.color,
                              ]
                                .where((e) => e != null && e!.trim().isNotEmpty)
                                .map((e) => e!.trim())
                                .join(' ');
                        final composedDesc = (form.description != null && form.description!.trim().isNotEmpty)
                            ? form.description!.trim()
                            : (form.repairHistory?.isNotEmpty == true
                                ? 'Repair history: ${form.repairHistory}'
                                : '');

                        final listingTypeStr = form.listingType.name; // 'sell' | 'trade' | 'donate'

                        final verification = <String, dynamic>{
                          'powersOn': form.powersOnCorrectly ?? false,
                          'buttonsFunctional': form.buttonsFunctional ?? false,
                          'batteryDrainsFast': form.batteryDrainsFast ?? false,
                          'screenDamage': form.screenHasDamage ?? false,
                          'touchResponsive': form.touchscreenResponsive ?? false,
                          if (batteryPhotoUrl != null) 'batteryPhotoUrl': batteryPhotoUrl,
                          if (powersOnVideoUrl != null) 'powersOnVideoUrl': powersOnVideoUrl,
                          if (buttonsVideoUrl != null) 'buttonsVideoUrl': buttonsVideoUrl,
                          if (screenDamagePhotoUrl != null) 'screenDamagePhotoUrl': screenDamagePhotoUrl,
                          if (touchscreenVideoUrl != null) 'touchscreenVideoUrl': touchscreenVideoUrl,
                        };

                        final err = await _uploadWithTimeout(() => supa.createListing(
                          listingType: listingTypeStr,
                          title: composedTitle.isNotEmpty ? composedTitle : 'Device Listing',
                          description: composedDesc,
                          imageUrls: imageUrls,
                          price: form.listingType == ListingType.sell ? form.price : null,
                          tradeDetails: form.listingType == ListingType.trade ? form.tradeDetails : null,
                          deviceType: form.deviceType,
                          brand: form.brand,
                          model: form.model,
                          storage: form.storageCapacity,
                          color: form.color,
                          accessories: form.includedAccessories,
                          repairHistory: form.repairHistory,
                          verification: verification,
                        ));

                        if (!mounted) return;
                        setState(() {
                          _submitting = false;
                        });

                        if (err == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddListingConfirmationPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: Colors.red, content: Text('Unable to create listing. ${err.isEmpty ? 'Please try again.' : err}')),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        setState(() {
                          _submitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
                        );
                      }
                    },
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm & List'),
            ),
          ),
        ],
      ),
    );
  }
}