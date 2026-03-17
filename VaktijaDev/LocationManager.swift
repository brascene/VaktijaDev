import CoreLocation
import AppKit

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var isLocating = false
    var error: String?
    var permissionDenied = false

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    func requestLocation() async {
        isLocating = true
        error = nil
        permissionDenied = false

        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            permissionDenied = true
            error = "Lokacija nije dozvoljena"
            isLocating = false
            return
        }

        manager.requestWhenInUseAuthorization()

        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }

        isLocating = false
    }

    func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
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
            if let clError = error as? CLError, clError.code == .denied {
                self.permissionDenied = true
                self.error = "Lokacija nije dozvoljena"
            } else {
                self.error = "Lokacija nije dostupna"
            }
            self.continuation?.resume()
            self.continuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .denied || status == .restricted {
                self.permissionDenied = true
            } else {
                self.permissionDenied = false
            }
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
