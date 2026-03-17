import CoreLocation
import AppKit

@MainActor
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var isLocating = false
    var error: String?
    var permissionDenied = false

    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var continuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() async {
        isLocating = true
        error = nil
        permissionDenied = false
        latitude = nil
        longitude = nil
        locationName = nil

        let status = manager.authorizationStatus

        if status == .denied || status == .restricted {
            permissionDenied = true
            error = "Lokacija nije dozvoljena"
            isLocating = false
            return
        }

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            // Wait for authorization response
            await Task.sleep(seconds: 0.5)
            let newStatus = manager.authorizationStatus
            if newStatus == .denied || newStatus == .restricted {
                permissionDenied = true
                error = "Lokacija nije dozvoljena"
                isLocating = false
                return
            }
        }

        // Request location with timeout
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                await withCheckedContinuation { @MainActor continuation in
                    self.continuation = continuation
                    self.manager.requestLocation()
                }
            }

            group.addTask {
                await Task.sleep(seconds: 15)
                if self.continuation != nil {
                    self.error = "Nije moguće odrediti lokaciju"
                    self.continuation?.resume()
                    self.continuation = nil
                }
            }

            await group.next()
            group.cancelAll()
        }

        isLocating = false
    }

    func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        Task {
            await reverseGeocode(location)
        }
        continuation?.resume()
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .denied {
            permissionDenied = true
            self.error = "Lokacija nije dozvoljena"
        } else {
            self.error = "Nije moguće odrediti lokaciju"
        }
        continuation?.resume()
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        permissionDenied = (status == .denied || status == .restricted)
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

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
