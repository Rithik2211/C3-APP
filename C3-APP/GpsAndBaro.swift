//
//  GpsAndBaro.swift
//  C3-APP
//
//  Created by Rithik Pranao on 23/08/24.
//
import SwiftUI
import CoreLocation
import CoreMotion

public struct GPSAndBaroView: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @State private var barometerData: String = "No Barometer Data"
    @State private var altitudeData: String = "No Altitude Data"

    private var altimeter = CMAltimeter()

    public var onClose: (() -> Void)?

    public init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack {
                HStack(spacing: 20) {
                    Button(action: gpsAction) {
                        Text("GPS")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 150)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }

                    Button(action: barometerAction) {
                        Text("Barometer")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 150)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)

                Spacer()

                VStack {
                    Text(locationViewModel.locationStatus)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                    HStack{
                        Text("Pressure :")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                        Text(barometerData)
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                    }
                    HStack{
                        Text("Altitude :")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding()
                        Text(altitudeData)
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding()
                    }
                }

                Spacer()

                HStack(spacing: 20) {
                    Button(action: {
                        closeAction()
                        onClose?()
                    }) {
                        Text("Back")
                            .foregroundColor(.black)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 150)
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 50)
                    Button(action: stopBaro) {
                        Text("Stop Baro")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 150)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            locationViewModel.checkIfLocationServicesIsEnabled()
        }
    }

    private func stopBaro() {
        altimeter.stopRelativeAltitudeUpdates()
    }

    private func gpsAction() {
        locationViewModel.requestLocation()
    }

    private func barometerAction() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            barometerData = "Barometer not available"
            return
        }

        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
            if let error = error {
                barometerData = "Error: \(error.localizedDescription)"
                self.altimeter.stopRelativeAltitudeUpdates()
                return
            }
            if let altitudeData = data {
                let pressure = altitudeData.pressure.doubleValue * 10  // Convert kPa to hPa
                barometerData = "\(pressure) hPa"
                self.altitudeData = calculateAltitude(from: pressure)
            }
        }
    }

    private func calculateAltitude(from pressure: Double) -> String {
        let p0 = 1013.25  // Reference pressure at sea level in hPa
        let altitude = 44330 * (1 - pow((pressure / p0), (1 / 5.255)))
        return "\(altitude) m"
    }

    private func closeAction() {
        altimeter.stopRelativeAltitudeUpdates()
        print("Close tapped")
    }
}

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationStatus: String = "Tap GPS to start"
    private var locationManager: CLLocationManager?

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        } else {
            locationStatus = "Location services are disabled"
        }
    }

    func requestLocation() {
        locationManager?.requestLocation()
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationStatus = "Location access is restricted"
        case .denied:
            locationStatus = "Location access was denied"
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = "Getting location..."
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
//        locationStatus = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
        locationStatus = """
        Lat: \(location.coordinate.latitude)
        Lon: \(location.coordinate.longitude)
        Altitude: \(location.altitude)
        Timestamp: \(location.timestamp)
        Course: \(location.course)
        Speed: \(location.speed)
        Horizontal Accuracy: \(location.horizontalAccuracy)
        Vertical Accuracy: \(location.verticalAccuracy)
        Ellipsoidal Altitude: \(location.ellipsoidalAltitude)
        """
        print("coordinate: \(location.coordinate), altitude: \(location.altitude), timestamp : \(location.timestamp), course: \(location.course), speed: \(location.speed), horizontalAccuracy : \(location.horizontalAccuracy), verticalAccuracy: \(location.verticalAccuracy), ellipsoidalAltitude : \(location.ellipsoidalAltitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationStatus = "Error: \(error.localizedDescription)"
    }
}



