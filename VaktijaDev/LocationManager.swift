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
    @ObservationIgnored private var pendingResult: Result<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() async {
        guard !isLocating else { return }
        isLocating = true
        defer { isLocating = false }

        error = nil
        permissionDenied = false
        latitude = nil
        longitude = nil
        locationName = nil
        pendingResult = nil

        let status = manager.authorizationStatus

        if status == .denied || status == .restricted {
            permissionDenied = true
            error = loc("location.denied", currentLang())
            return
        }

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            for _ in 0..<100 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                if manager.authorizationStatus != .notDetermined { break }
            }
            let newStatus = manager.authorizationStatus
            if newStatus == .denied || newStatus == .restricted {
                permissionDenied = true
                error = loc("location.denied", currentLang())
                return
            }
            if newStatus == .notDetermined {
                error = loc("location.unknown", currentLang())
                return
            }
        }

        manager.requestLocation()

        // Poll for delegate result (up to 8s)
        for _ in 0..<80 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            if pendingResult != nil { break }
        }

        switch pendingResult {
        case .success(let location):
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            await reverseGeocode(location)
        case .failure(let err):
            if let clError = err as? CLError, clError.code == .denied {
                permissionDenied = true
                error = loc("location.denied", currentLang())
            } else {
                error = loc("location.unknown", currentLang())
            }
        case .none:
            error = loc("location.unknown", currentLang())
        }
        pendingResult = nil
    }

    func openLocationSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_LocationServices",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices",
        ]
        for urlString in candidates {
            if let url = URL(string: urlString), NSWorkspace.shared.open(url) {
                return
            }
        }
        if let url = URL(string: "x-apple.systempreferences:") {
            NSWorkspace.shared.open(url)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        pendingResult = .success(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pendingResult = .failure(error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        permissionDenied = (status == .denied || status == .restricted)
    }

    private func reverseGeocode(_ location: CLLocation) async {
        let geocoder = CLGeocoder()
        let fallback = loc("location.mine", currentLang())
        if let placemark = try? await geocoder.reverseGeocodeLocation(location).first {
            locationName = placemark.locality ?? placemark.administrativeArea ?? fallback
        } else {
            locationName = fallback
        }
    }
}
