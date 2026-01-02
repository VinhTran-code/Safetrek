// lib/models/trip.dart
class Trip {
  final int id;
  final String destinationName;
  final DateTime startTime;
  final DateTime expectedEndTime;
  final String status; // active, completed, duress_ended, alerted, panic
  final String tripType; // timer, panic
  final List<LocationHistory>? locationHistory;

  Trip({
    required this.id,
    required this.destinationName,
    required this.startTime,
    required this.expectedEndTime,
    required this.status,
    required this.tripType,
    this.locationHistory,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int,
      destinationName: json['destination_name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      expectedEndTime: DateTime.parse(json['expected_end_time'] as String),
      status: json['status'] as String,
      tripType: json['trip_type'] as String? ?? 'timer',
      locationHistory: json['location_history'] != null
          ? (json['location_history'] as List)
              .map((loc) => LocationHistory.fromJson(loc))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination_name': destinationName,
      'start_time': startTime.toIso8601String(),
      'expected_end_time': expectedEndTime.toIso8601String(),
      'status': status,
      'trip_type': tripType,
      'location_history': locationHistory?.map((loc) => loc.toJson()).toList(),
    };
  }

  // Tính thời gian còn lại (phút)
  int getTimeRemainingMinutes() {
    final now = DateTime.now();
    final diff = expectedEndTime.difference(now);
    return diff.inMinutes.clamp(0, double.infinity).toInt();
  }

  // Check if trip is active
  bool get isActive => status == 'active';

  // Check if trip is in danger state
  bool get isDanger => status == 'panic' || status == 'duress_ended';
}

class LocationHistory {
  final double latitude;
  final double longitude;
  final int batteryLevel;
  final DateTime timestamp;

  LocationHistory({
    required this.latitude,
    required this.longitude,
    required this.batteryLevel,
    required this.timestamp,
  });

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      batteryLevel: json['battery_level'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'battery_level': batteryLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Request models
class StartTripRequest {
  final String destinationName;
  final int durationMinutes;

  StartTripRequest({
    required this.destinationName,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination_name': destinationName,
      'duration_minutes': durationMinutes,
    };
  }
}

class UpdateLocationRequest {
  final int tripId;
  final double latitude;
  final double longitude;
  final int batteryLevel;

  UpdateLocationRequest({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.batteryLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'battery_level': batteryLevel,
    };
  }
}

class EndTripRequest {
  final int tripId;
  final String pinCode;

  EndTripRequest({
    required this.tripId,
    required this.pinCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'pin_code': pinCode,
    };
  }
}

class EndTripWithLocationRequest {
  final int tripId;
  final String pinCode;
  final double? latitude;
  final double? longitude;
  final int? batteryLevel;

  EndTripWithLocationRequest({
    required this.tripId,
    required this.pinCode,
    this.latitude,
    this.longitude,
    this.batteryLevel,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'trip_id': tripId,
      'pin_code': pinCode,
    };

    // Thêm location và battery nếu có
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (batteryLevel != null) json['battery_level'] = batteryLevel;

    return json;
  }
}

class PanicRequest {
  final double? latitude;     // Optional - null khi panic từ trang chủ
  final double? longitude;    // Optional - null khi panic từ trang chủ
  final int? batteryLevel;    // Optional

  PanicRequest({
    this.latitude,
    this.longitude,
    this.batteryLevel,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    // Chỉ thêm fields nếu có giá trị
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (batteryLevel != null) json['battery_level'] = batteryLevel;

    return json;
  }
}

