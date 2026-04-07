import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    super.clinicAddress,
    super.latitude,
    super.longitude,
    super.hospitalName,
  });

  Map<String, dynamic> toJson() {
    return {
      if (clinicAddress != null) 'clinicAddress': clinicAddress,
      if (latitude != null) 'clinicLatitude': latitude,
      if (longitude != null) 'clinicLongitude': longitude,
      if (hospitalName != null) 'hospitalName': hospitalName,
    };
  }
}
