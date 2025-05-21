import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trip_planner/features/trip/widgets/form_input.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key, this.onPlaceSelected});

  final void Function(LatLng latLng, String name)? onPlaceSelected;

  @override
  State<SearchLocation> createState() => _SearchLocation();
}

class _SearchLocation extends State<SearchLocation> {
  final TextEditingController _addressController = TextEditingController();
  var uuid = Uuid();

  String _token = '37465';
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() {
      onModify();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void onModify() {
    if (_token.isEmpty) {
      setState(() {
        _token = uuid.v4();
      });
    }
    _fetchSuggestions(_addressController.text);
  }

  Future<void> _fetchSuggestions(String suggestion) async {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$suggestion'
        '&key=$apiKey'
        '&sessiontoken=$_token'
        '&language=pl';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _suggestions = data['predictions'];
      });
    } else {
      throw Exception('Błąd podczas pobierania');
    }
  }

  Future<void> _handlePlaceSelected(int index) async {
    FocusScope.of(context).unfocus();
    final placeId = _suggestions[index]['place_id'];
    final name = _suggestions[index]['description'];
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    final detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$apiKey'
        '&language=pl';

    final detailsResponse = await http.get(Uri.parse(detailsUrl));
    if (detailsResponse.statusCode == 200) {
      final details = jsonDecode(detailsResponse.body);
      final location = details['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);
      widget.onPlaceSelected?.call(latLng, name);
    } else {
      throw Exception('Błąd podczas pobierania szczegółów miejsca');
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
                FormInput(
                  controller: _addressController,
                  labelText: 'Punkt podróży',
                  icon: Icons.place,
                ),
                Expanded(
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
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}


/*

          IconButton.filled(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
          ),

          */