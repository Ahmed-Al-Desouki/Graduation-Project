import 'package:graduation_project/features/search/domain/entities/doctor_entity.dart';

class SearchResponseEntity {
  final List<DoctorEntity> doctors;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasNextPage;

  SearchResponseEntity({
    required this.doctors,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
  });
}
