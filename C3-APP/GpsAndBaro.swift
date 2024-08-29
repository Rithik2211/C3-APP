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
    @State private var altitudeDataAbsolute: String = "No Absolute Altitude Data"
    @State private var barometerDataRelative: String = "No Relative Barometer Data"
    @State private var altitudeDataRelative: String = "No Relative Altitude Data"
    @State private var isAbsoluteAltitudeUpdating = false
    @State private var isRelativeAltitudeUpdating = false

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
                    Text("GPS")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading) {
                        gpsDataView(label: "Lat", value: "\(locationViewModel.location.coordinate.latitude)", readings: "deg")
                        gpsDataView(label: "Lon", value: "\(locationViewModel.location.coordinate.longitude)", readings: "deg")
                        gpsDataView(label: "Altitude", value: "\(locationViewModel.location.altitude)", readings: "m")
                        gpsDataView(label: "Course Accuracy", value: "\(locationViewModel.location.courseAccuracy)", readings: "m")
                        gpsDataView(label: "Speed Accuracy", value: "\(locationViewModel.location.speedAccuracy)", readings: "m/s")
                        gpsDataView(label: "Horizontal Accuracy", value: "\(locationViewModel.location.horizontalAccuracy)", readings: "m")
                        gpsDataView(label: "Vertical Accuracy", value: "\(locationViewModel.location.verticalAccuracy)", readings: "m")
                        gpsDataView(label: "Ellipsoidal Altitude", value: "\(locationViewModel.location.ellipsoidalAltitude)", readings: "m")
                        gpsDataView(label: "Timestamp", value: "\(locationViewModel.location.timestamp)", readings: "")
                    }
                    .foregroundColor(.black)
                    .padding()
                    
                    Text("Barometer")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 1)
                    Text("Absolute Readings")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    VStack{
                        HStack{
                            Text("Altitude : ")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text(altitudeDataAbsolute)
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.black)
                    .padding()
                    
                    Text("Relative Readings")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    VStack{
                        HStack{
                            Text("Pressure : ")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text(barometerDataRelative)
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        }
                        HStack{
                            Text("Altitude : ")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text(altitudeDataRelative)
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.black)
                    .padding()
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
        if isRelativeAltitudeUpdating {
            altimeter.stopRelativeAltitudeUpdates()
            isRelativeAltitudeUpdating = false
            barometerDataRelative = "\(barometerDataRelative)(Stopped)"
            altitudeDataRelative = "\(altitudeDataRelative)(Stopped)"
        }
        if isAbsoluteAltitudeUpdating {
            altimeter.stopAbsoluteAltitudeUpdates()
            isAbsoluteAltitudeUpdating = false
            altitudeDataAbsolute = "\(altitudeDataAbsolute)(Stopped)"
        }
    }

    private func gpsAction() {
        locationViewModel.requestLocation()
    }

    private func barometerAction() {
        if CMAltimeter.isAbsoluteAltitudeAvailable() {
            isAbsoluteAltitudeUpdating = true
            altimeter.startAbsoluteAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.altimeter.stopAbsoluteAltitudeUpdates()
                    isAbsoluteAltitudeUpdating = false
                    return
                }
                if let altitudeData = data {
                    let altitude = altitudeData.altitude
                    self.altitudeDataAbsolute = "\(altitude) m"
                }
            }
        }
        else {
            altitudeDataAbsolute = "Absolute Altitude not supported!"
        }

        if CMAltimeter.isRelativeAltitudeAvailable() {
            isRelativeAltitudeUpdating = true
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                if let error = error {
                    barometerDataRelative = "Error: \(error.localizedDescription)"
                    self.altimeter.stopRelativeAltitudeUpdates()
                    isRelativeAltitudeUpdating = false
                    return
                }
                if let altitudeData = data {
                    let pressure = altitudeData.pressure.doubleValue * 10  // Convert kPa to hPa
                    barometerDataRelative = "\(pressure) hPa"
                    self.altitudeDataRelative = calculateAltitude(from: pressure)
                }
            }
        } else {
            barometerDataRelative = "Relative Altitude not supported"
        }
    }

    private func calculateAltitude(from pressure: Double) -> String {
        let p0 = 1013.25  // Reference pressure at sea level in hPa
        let altitude = 44330 * (1 - pow((pressure / p0), (1 / 5.255)))
        return "\(altitude) m"
    }

    private func closeAction() {
        stopBaro()
        print("Close tapped")
    }
    
    private func gpsDataView(label: String, value: String, readings: String) -> some View {
        HStack {
            Text("\(label) :")
                .font(.system(size: 18))
                .fontWeight(.bold)
            Text("\(value) \(readings)")
                .font(.system(size: 18))
                .foregroundColor(.blue)
        }
    }
}

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationStatus: String = "Tap GPS to start"
    @Published var location: CLLocation = CLLocation()
    
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
        self.location = location // Save the latest location
            locationStatus = """
            Lat: \(location.coordinate.latitude)
            Lon: \(location.coordinate.longitude)
            Altitude: \(location.altitude)
            Timestamp: \(location.timestamp)
            Course Accuracy: \(location.courseAccuracy)
            Speed Accuracy: \(location.speedAccuracy)
            Horizontal Accuracy: \(location.horizontalAccuracy)
            Vertical Accuracy: \(location.verticalAccuracy)
            Ellipsoidal Altitude: \(location.ellipsoidalAltitude)
            """
        print("coordinate: \(location.coordinate), altitude: \(location.altitude), timestamp : \(location.timestamp), course: \(location.course), speed: \(location.speed), horizontalAccuracy : \(location.horizontalAccuracy), verticalAccuracy: \(location.verticalAccuracy), ellipsoidalAltitude : \(location.ellipsoidalAltitude )")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationStatus = "Error: \(error.localizedDescription)"
    }
}