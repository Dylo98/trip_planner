import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/* THEME */
import 'package:trip_planner/core/theme/input_style.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key, this.onPlaceSelected});

  final void Function(LatLng latLng, String name)? onPlaceSelected;

  @override
  State<SearchLocation> createState() => _SearchLocation();
}

class _SearchLocation extends State<SearchLocation> {
  final TextEditingController _addressController = TextEditingController();
  final _uuid = const Uuid();

  String _sessionToken = '';
  List<dynamic> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
    _addressController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_addressController.text.isNotEmpty) {
        _fetchSuggestions(_addressController.text);
      } else {
        setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.trim().isEmpty) return;

    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('Google Places API key not found');
      return;
    }

    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeComponent(input)}'
            '&key=$apiKey'
            '&sessiontoken=$_sessionToken'
            '&language=pl');

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          setState(() {
            _suggestions = data['predictions'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
  }

  Future<void> _handlePlaceSelected(int index) async {
    FocusScope.of(context).unfocus();

    final placeId = _suggestions[index]['place_id'];
    final name = _suggestions[index]['description'];
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];

    if (apiKey == null) return;

    final detailsUrl =
        Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId'
            '&key=$apiKey'
            '&sessiontoken=$_sessionToken'
            '&language=pl');

    try {
      final response = await http.get(detailsUrl).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final details = jsonDecode(response.body);
        final location = details['result']['geometry']['location'];
        final latLng = LatLng(
          (location['lat'] as num).toDouble(),
          (location['lng'] as num).toDouble(),
        );

        widget.onPlaceSelected?.call(latLng, name);

        _sessionToken = _uuid.v4();

        setState(() {
          _suggestions = [];
          _addressController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: AppInputStyle.inputDecoration(
                    icon: Icons.place,
                    labelText: 'Punkt podróży',
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Expanded(
                    child: Material(
                      elevation: 4,
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index]['description']),
                            onTap: () {
                              _handlePlaceSelected(index);
                              setState(() {
                                _suggestions = [];
                                _addressController.text = '';
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
