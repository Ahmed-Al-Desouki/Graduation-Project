import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapPickerBottomSheet extends StatefulWidget {
  final Function(String location, double? lat, double? lng) onLocationSelected;
  final TextEditingController? addressController;

  const MapPickerBottomSheet({
    super.key,
    required this.onLocationSelected,
    this.addressController,
  });

  @override
  State<MapPickerBottomSheet> createState() => _MapPickerBottomSheetState();
}

class _MapPickerBottomSheetState extends State<MapPickerBottomSheet> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isGettingAddress = false;

  static const LatLng _initialPosition = LatLng(30.0444, 31.2357);

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];

        String address = '';
        if (place.street != null && place.street!.isNotEmpty) {
          address = place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address +=
              address.isNotEmpty ? ', ${place.locality}' : place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address +=
              address.isNotEmpty
                  ? ', ${place.administrativeArea}'
                  : place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isNotEmpty ? ', ${place.country}' : place.country!;
        }

        setState(() {
          _selectedAddress = address.isNotEmpty ? address : 'Selected Location';
        });
      }
    } catch (e) {
      log('Error getting address: $e');
      if (mounted) {
        setState(() {
          _selectedAddress = 'Selected Location';
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          showSnackBar(context, 'Location permission denied', Colors.red);
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      _mapController.move(currentLatLng, 16);

      setState(() {
        _selectedPosition = currentLatLng;
      });

      await _getAddressFromLatLng(currentLatLng);

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        _handleLocationSelected(
          _selectedAddress.isNotEmpty
              ? _selectedAddress
              : 'Current Location (GPS)',
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLocationSelected(String location, double? lat, double? lng) {
    if (!mounted) return;

    widget.onLocationSelected(location, lat, lng);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _isGettingAddress = true;
      _selectedAddress = 'Loading...';
    });

    _getAddressFromLatLng(position).then((_) {
      if (mounted) {
        setState(() {
          _isGettingAddress = false;
        });
      }
    });
  }

  void _confirmSelectedLocation() {
    if (_selectedPosition == null) return;

    final locationText =
        _selectedAddress.isNotEmpty && _selectedAddress != 'Loading...'
            ? _selectedAddress
            : 'Selected Location';

    _handleLocationSelected(
      locationText,
      _selectedPosition!.latitude,
      _selectedPosition!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            'Select Clinic Location',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pick your clinic location on the map',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: 24.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 260.h,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: 13,
                  onTap: (tapPosition, latLng) => _onMapTapped(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.graduation_project',
                  ),

                  if (_selectedPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          if (_selectedPosition != null) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1B4E8C)),
              ),
              child: Row(
                children: [
                  if (_isGettingAddress)
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF1B4E8C),
                      ),
                    )
                  else
                    Icon(Icons.location_on, color: const Color(0xFF1B4E8C)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _selectedAddress.isNotEmpty
                          ? _selectedAddress
                          : 'Tap on map to select location',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF1B4E8C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          if (_selectedPosition != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGettingAddress ? null : _confirmSelectedLocation,
                icon: const Icon(Icons.check),
                label: const Text('Confirm Selected Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4E8C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          SizedBox(height: 24.h),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon:
                  _isLoading
                      ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF3B82F6),
                        ),
                      )
                      : const Icon(Icons.my_location, color: Color(0xFF3B82F6)),
              label: Text(
                _isLoading ? 'Getting Location...' : 'Use Current Location',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showManualEntryDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Enter Address Manually',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Clinic Address',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B4E8C),
              ),
            ),
            content: TextField(
              controller: widget.addressController,
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Building number, street name, floor',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: Icon(Icons.home, color: Color(0xff9ca3af)),
                filled: true,
                fillColor: Color(0xFFF9FAFB),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B6E9C), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.addressController?.text.isNotEmpty == true) {
                    log(
                      '[MapPicker] Address entered: ${widget.addressController!.text}',
                    );
                    _handleLocationSelected(
                      widget.addressController!.text,
                      null,
                      null,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
