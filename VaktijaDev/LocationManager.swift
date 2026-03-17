import CoreLocation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var isLocating = false
    var error: String?

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() async {
        isLocating = true
        error = nil

        manager.requestWhenInUseAuthorization()

        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }

        isLocating = false
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        Task { @MainActor in
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            await self.reverseGeocode(location)
            self.continuation?.resume()
            self.continuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = "Lokacija nije dostupna"
            self.continuation?.resume()
            self.continuation = nil
        }
    }

    private func reverseGeocode(_ location: CLLocation) async {
        let geocoder = CLGeocoder()
        if let placemark = try? await geocoder.reverseGeocodeLocation(location).first {
            locationName = placemark.locality ?? placemark.administrativeArea ?? "Moja lokacija"
        } else {
            locationName = "Moja lokacija"
        }
    }
}
