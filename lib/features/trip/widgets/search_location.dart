import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/* THEME */
import 'package:trip_planner/core/theme/input_style.dart';

/* SERVICES */
import 'package:trip_planner/features/trip/services/nominatim_search_service.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key, this.onPlaceSelected});

  final void Function(LatLng latLng, String name)? onPlaceSelected;

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_addressController.text.isNotEmpty) {
        _fetchSuggestions(_addressController.text);
      } else {
        if (mounted) {
          setState(() => _suggestions = []);
        }
      }
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.trim().isEmpty) return;

    try {
      final results = await NominatimSearchService.searchPlaces(input);
      if (mounted) {
        setState(() {
          _suggestions = results;
        });
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
    }
  }

  void _handlePlaceSelected(int index) {
    _focusNode.unfocus();

    final suggestion = _suggestions[index];
    widget.onPlaceSelected?.call(suggestion.location, suggestion.name);

    setState(() {
      _suggestions = [];
      _addressController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: TextFormField(
            controller: _addressController,
            focusNode: _focusNode,
            decoration: AppInputStyle.inputDecoration(
              icon: Icons.place,
              labelText: 'Punkt podróży',
            ),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index].name),
                    subtitle: _suggestions[index].address != null
                        ? Text(_suggestions[index].address!)
                        : null,
                    onTap: () => _handlePlaceSelected(index),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
