import 'package:flutter/material.dart';
import 'dart:async';
import 'package:safetrek_app/screens/trip_monitoring_screen.dart';

// Giả sử bạn sẽ dùng Google Maps
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  // final Completer<GoogleMapController> _controller = Completer();

  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(10.762622, 106.660172), // Vị trí mặc định, ví dụ: TP.HCM
  //   zoom: 14.4746,
  // );

  String? _selectedTime;
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  void _startMonitoring() {
    int durationInMinutes = 15; // Mặc định 15 phút
    if (_timeController.text.isNotEmpty) {
      durationInMinutes = int.tryParse(_timeController.text) ?? 15;
    } else if (_selectedTime != null) {
      durationInMinutes = int.tryParse(_selectedTime!.replaceAll(' phút', '')) ?? 15;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripMonitoringScreen(
          tripDurationInSeconds: durationInMinutes * 60,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng Stack để xếp chồng các UI lên trên bản đồ
      body: Stack(
        children: [
          // PHẦN 1: BẢN ĐỒ (MAP)
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'Google Map sẽ hiển thị ở đây',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // GoogleMap(
          //   mapType: MapType.normal,
          //   initialCameraPosition: _kGooglePlex,
          //   onMapCreated: (GoogleMapController controller) {
          //     _controller.complete(controller);
          //   },
          // ),

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


          // PHẦN 2: KHUNG NHẬP LIỆU (UI OVERLAY)
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.4,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
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
                      const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                          hintText: 'Nhập điểm đến của bạn...',
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                             borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Thời gian dự kiến', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: ['5 phút', '10 phút', '15 phút', '30 phút']
                            .map((time) {
                              final isSelected = _selectedTime == time;
                              return ChoiceChip(
                                label: Text(time),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTime = selected ? time : null;
                                    _timeController.clear(); // Xóa text nếu chọn chip
                                  });
                                },
                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                  )
                                ),
                              );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),
                      const Text('Hoặc nhập thời gian tùy chỉnh', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _timeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '15',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedTime = null; // Bỏ chọn chip nếu nhập text
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.0)
                            ),
                            child: const Text('phút')
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                       SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _startMonitoring, // *** CẬP NHẬT Ở ĐÂY ***
                          child: const Text('BẮT ĐẦU GIÁM SÁT'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
