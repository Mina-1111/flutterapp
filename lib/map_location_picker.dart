import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng initialPosition;

  const MapLocationPicker({Key? key, required this.initialPosition})
      : super(key: key);

  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? mapController;
  LatLng? selectedPosition;
  Set<Marker> markers = {};
  bool _isMapCreated = false;
  bool _isLoading = true;
  String? _errorMessage;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Check location service
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw 'Location services are disabled';
        }
      }

      // Check location permission
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission == PermissionStatus.denied) {
          throw 'Location permissions are denied';
        }
      }

      // Get initial location
      LocationData locationData = await _location.getLocation();
      final LatLng currentLocation = LatLng(
        locationData.latitude ?? widget.initialPosition.latitude,
        locationData.longitude ?? widget.initialPosition.longitude,
      );

      setState(() {
        selectedPosition = currentLocation;
        markers.add(
          Marker(
            markerId: MarkerId('initial_location'),
            position: currentLocation,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing map: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check location service
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw 'Location services are disabled';
        }
      }

      // Check location permission
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission == PermissionStatus.denied) {
          throw 'Location permissions are denied';
        }
      }

      // Get current location with timeout
      LocationData locationData = await _location.getLocation().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw 'Location request timed out';
        },
      );

      if (locationData.latitude == null || locationData.longitude == null) {
        throw 'Could not get location coordinates';
      }

      final LatLng currentLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      setState(() {
        selectedPosition = currentLocation;
        markers.clear();
        markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: currentLocation,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
        _isLoading = false;
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 15),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: selectedPosition == null
                ? null
                : () {
                    Navigator.pop(context, selectedPosition);
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeMap,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                  _isMapCreated = true;
                });
              },
              onTap: (LatLng position) {
                setState(() {
                  selectedPosition = position;
                  markers.clear();
                  markers.add(
                    Marker(
                      markerId: MarkerId('selected_location'),
                      position: position,
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                  );
                });
              },
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
              compassEnabled: true,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: _isLoading ? null : _getCurrentLocation,
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
