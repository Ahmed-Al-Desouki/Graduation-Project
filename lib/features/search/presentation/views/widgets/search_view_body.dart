import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constant.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/doctors_list_view.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

class SearchViewBody extends StatefulWidget {
  const SearchViewBody({super.key});

  @override
  State<SearchViewBody> createState() => _SearchViewBodyState();
}

class _SearchViewBodyState extends State<SearchViewBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (currentScroll >= 0.7 * maxScroll) {
      context.read<SearchCubit>().fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {
        if (state is SearchFailure) {
          showSnackBar(context, state.errmessage, Colors.red);
        }
        if (state is SearchSuccess && state.paginationErrorMessage != null) {
          showSnackBar(context, state.paginationErrorMessage!, Colors.red);
        }
      },

      builder: (context, state) {
        final allSpecializations =
            state is SearchSuccess ? state.allSpecializations : [];
        final popularSpecialties =
            state is SearchSuccess
                ? state.popularSpecialties
                : kpopularSpecialties;
        final selectedSpecialty = state.selectedSpecialty;
        final searchQuery = state.searchQuery;

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchHeader(),
              SearchCard(
                searchQuery: searchQuery,
                onSearchChanged: (value) {
                  context.read<SearchCubit>().updateSearchQuery(value);
                },
                selectedSpecialty: selectedSpecialty,
                onSpecialtyChanged: (value) {
                  context.read<SearchCubit>().updateSelectedSpecialty(value);
                },
                allSpecializations: ['All Specialties', ...allSpecializations],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PopularSpecialtiesSection(
                  selectedSpecialty: selectedSpecialty,
                  popularSpecialties: popularSpecialties,
                  onSelected: (value) {
                    context.read<SearchCubit>().updateSelectedSpecialty(value);
                  },
                ),
              ),

              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Available Doctors",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),

              DoctorsListView(state: state),
            ],
          ),
        );
      },
    );
  }
}
