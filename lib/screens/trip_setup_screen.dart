import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safetrek_app/screens/trip_monitoring_screen.dart';
import 'package:safetrek_app/screens/trip_view_model.dart';
import 'package:safetrek_app/injection_container.dart';
import '../services/google_places_service.dart';

class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final GooglePlacesService _placesService = GooglePlacesService();
  late final TripViewModel _tripViewModel;

  // Map state
  LatLng _currentPosition = const LatLng(10.762622, 106.660172); // Default: TP.HCM
  LatLng? _destinationPosition;
  String? _destinationName;
  final Set<Marker> _markers = {};

  // Search state
  List<PlacePrediction> _predictions = [];
  bool _isSearching = false;
  bool _showPredictions = false;

  @override
  void initState() {
    super.initState();
    _tripViewModel = sl<TripViewModel>();
    _getCurrentLocation();

    // Listen to search text changes
    _destinationController.addListener(_onSearchChanged);

    // Listen to focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _showPredictions = _searchFocusNode.hasFocus && _predictions.isNotEmpty;
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Ensure location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng bật dịch vụ định vị (GPS)')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quyền vị trí bị từ chối')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền vị trí bị chặn vĩnh viễn. Vui lòng cho phép trong cài đặt.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _addMarker(
          _currentPosition,
          "Vị trí hiện tại",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });

      // If map controller already exists, animate to current
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }

      debugPrint('Current position: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy vị trí: $e')),
      );
    }
  }

  void _addMarker(LatLng position, String title, BitmapDescriptor icon) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == title);
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: icon,
        ),
      );
    });
  }

  void _onSearchChanged() async {
    final query = _destinationController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    if (query.length < 2) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final predictions = await _placesService.searchPlaces(query);
      setState(() {
        _predictions = predictions;
        _showPredictions = _searchFocusNode.hasFocus && predictions.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      debugPrint("Error searching: $e");
    }
  }

  void _onPlaceSelected(PlacePrediction prediction) async {
    // Update text field
    setState(() {
      _destinationController.text = prediction.description;
      _destinationName = prediction.description;
      _showPredictions = false;
      _predictions = [];
    });

    // Unfocus to hide keyboard
    _searchFocusNode.unfocus();

    // Get place details (coordinates)
    try {
      final details = await _placesService.getPlaceDetails(prediction.placeId);

      if (details != null) {
        setState(() {
          _destinationPosition = LatLng(details.latitude, details.longitude);
          _addMarker(
            _destinationPosition!,
            "Điểm đến",
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        });

        // Animate camera to show both markers
        if (_mapController != null && _destinationPosition != null) {
          final southwest = LatLng(
            (_currentPosition.latitude <= _destinationPosition!.latitude)
                ? _currentPosition.latitude
                : _destinationPosition!.latitude,
            (_currentPosition.longitude <= _destinationPosition!.longitude)
                ? _currentPosition.longitude
                : _destinationPosition!.longitude,
          );
          final northeast = LatLng(
            (_currentPosition.latitude >= _destinationPosition!.latitude)
                ? _currentPosition.latitude
                : _destinationPosition!.latitude,
            (_currentPosition.longitude >= _destinationPosition!.longitude)
                ? _currentPosition.longitude
                : _destinationPosition!.longitude,
          );

          LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);

          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        }
      }
    } catch (e) {
      debugPrint("Error getting place details: $e");
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _durationController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _startMonitoring() async {
    if (_destinationName == null || _destinationName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn điểm đến")),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text) ?? 0;
    if (duration <= 0 || duration > 1440) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập thời gian hợp lệ (1-1440 phút)")),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Gọi API để bắt đầu chuyến đi
      await _tripViewModel.startTrip(
        destinationName: _destinationName!,
        durationMinutes: duration,
      );

      // Đóng loading
      if (mounted) Navigator.of(context).pop();

      // Kiểm tra kết quả
      if (_tripViewModel.state is TripActive) {
        final tripState = _tripViewModel.state as TripActive;

        // Chuyển đến màn hình monitoring với trip data
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TripMonitoringScreen(
                tripDurationInSeconds: duration * 60,
                tripId: tripState.trip.id,
              ),
            ),
          );
        }
      } else if (_tripViewModel.state is TripError) {
        // Hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((_tripViewModel.state as TripError).message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Đóng loading
      if (mounted) Navigator.of(context).pop();

      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi bắt đầu chuyến đi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PHẦN 1: Google Map (toàn màn hình)
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Tắt để custom button
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              // Khi map sẵn sàng, animate về vị trí hiện tại nếu đã lấy được
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(_currentPosition, 15),
              );
            },
          ),

          // Nút quay lại
          Positioned(
            top: 50,
            left: 15,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
            ),
          ),

          // Nút current location
          Positioned(
            top: 50,
            right: 15,
            child: FloatingActionButton(
              mini: true,
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
            ),
          ),

          // PHẦN 2: Form nhập liệu (DraggableScrollableSheet)
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.35,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tiêu đề
                      const Text(
                        "Thông tin chuyến đi",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ô tìm kiếm địa điểm
                      TextField(
                        controller: _destinationController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          labelText: "Điểm đến",
                          hintText: "Tìm kiếm địa điểm...",
                          prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : _destinationController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _destinationController.clear();
                                          _destinationName = null;
                                          _destinationPosition = null;
                                          _predictions = [];
                                          _showPredictions = false;
                                          _markers.removeWhere(
                                            (m) => m.markerId.value == "Điểm đến",
                                          );
                                        });
                                      },
                                    )
                                  : null,
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Thời gian dự kiến
                      Text(
                        'Thời gian dự kiến',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập thời gian
                      TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Thời gian (phút)",
                          hintText: "VD: 30",
                          prefixIcon: const Icon(Icons.timer, color: Colors.teal),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Nút bắt đầu giám sát
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startMonitoring,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Bắt đầu giám sát",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),

          // Predictions overlay
          if (_showPredictions)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPredictions = false;
                    _searchFocusNode.unfocus();
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    children: [
                      const SizedBox(height: 120), // Space for AppBar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _predictions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final prediction = _predictions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on, color: Colors.teal),
                              title: Text(
                                prediction.mainText,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                prediction.secondaryText,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              onTap: () => _onPlaceSelected(prediction),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
