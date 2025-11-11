import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/features/trip/services/nominatim_search_service.dart';
import 'package:trip_planner/core/utils/debouncer.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

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
  final _debouncer = Debouncer(milliseconds: 400);
  final _netLock = ActionLock();
  final _uiLock = ActionLock();

  int _requestId = 0;
  http.Client? _httpClient;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _httpClient?.close();
    _debouncer.dispose();
    _addressController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _addressController.text;
    _debouncer.run(() {
      if (text.isNotEmpty) {
        _fetchSuggestions(text);
      } else if (mounted) {
        setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.trim().isEmpty) return;

    _httpClient?.close();
    _httpClient = http.Client();

    final currentRequestId = ++_requestId;

    await _netLock.run(() async {
      try {
        final results = await NominatimSearchService.searchPlaces(
          input,
          client: _httpClient,
        );

        if (mounted && currentRequestId == _requestId) {
          setState(() => _suggestions = results);
        }
      } catch (e) {
        debugPrint('Error fetching suggestions: $e');

        if (mounted && currentRequestId == _requestId) {
          setState(() => _suggestions = []);
        }
      }
    });
  }

  void _handlePlaceSelected(int index) {
    _uiLock.run(() async {
      _focusNode.unfocus();
      final suggestion = _suggestions[index];
      widget.onPlaceSelected?.call(suggestion.location, suggestion.name);
      if (mounted) {
        setState(() {
          _suggestions = [];
          _addressController.clear();
        });
      }
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
