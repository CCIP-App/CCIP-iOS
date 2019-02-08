//
//  iBeacon.swift
//  OPass
//
//  Created by 腹黒い茶 on 2019/2/8.
//  Copyright © 2019 OPass. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

let beaconUUID = Constants.beaconUUID()
let beaconID = Constants.beaconID()

@objc class iBeacon: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    let locationManager = CLLocationManager()

    let pService = CBUUID(string: "0x180A")
    let sID = CBUUID(string: "0x2A23")
    var centralManager: CBCentralManager?
    var peripheralMonitor: CBPeripheral?
    var beaconMacAddresses: Dictionary = [String:String]()

    public override init() {
        super.init()
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: nil)
    }

    @objc func checkAvailableAndRequestAuthorization() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            }
        }
    }

    @objc func registerBeaconRegionWithUUID(uuidString: String, identifier: String, isMonitor: Bool) {
        locationManager.delegate = self;
        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuidString)!, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true

        if isMonitor {
            locationManager.startMonitoring(for: region)
        } else {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: (region as! CLBeaconRegion))
                print("In region")
            } else {
                print("Unsupport for Ranging")
            }
        } else {
            manager.stopRangingBeacons(in: (region as! CLBeaconRegion))
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if CLLocationManager.isRangingAvailable() {
            manager.startRangingBeacons(in: (region as! CLBeaconRegion))
        } else {
            print("Unsupport for Ranging")
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: (region as! CLBeaconRegion))
        print("Out of region")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if (beacons.count > 0) {
            if let nearstBeacon = beacons.first {
                var proximity = ""

                switch nearstBeacon.proximity {
                    case CLProximity.immediate:
                        proximity = "Very close"
                    case CLProximity.near:
                        proximity = "Near"
                    case CLProximity.far:
                        proximity = "Far"
                    default:
                        proximity = "unknow"
                }

                NSLog("Detacted beacon !!\n      UUID: \(nearstBeacon.proximityUUID.uuidString)\nMajorMinor: \(nearstBeacon.major) -> \(nearstBeacon.minor)\n Proximity: \(proximity)\n  Accuracy: \(nearstBeacon.accuracy) meter \n      RSSI: \(nearstBeacon.rssi)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error.localizedDescription)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("Bluetooth status is UNKNOWN")
            case .resetting:
                print("Bluetooth status is RESETTING")
            case .unsupported:
                print("Bluetooth status is UNSUPPORTED")
            case .unauthorized:
                print("Bluetooth status is UNAUTHORIZED")
            case .poweredOff:
                print("Bluetooth status is POWERED OFF")
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
                central.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let peripheralName = peripheral.name ?? "<nil>"
        if (peripheralName == "USBeacon" && !self.beaconMacAddresses.contains(where: { (mac) -> Bool in
            let (key, _) = mac
            return key == peripheral.identifier.uuidString
        })) {
            peripheralMonitor = peripheral
            peripheralMonitor?.delegate = self
            central.stopScan()
            central.connect(peripheralMonitor!, options: nil)
        } else if peripheralName == "USBeacon" {
            NSLog("Mac Addresses: \(JSONSerialization.stringify(self.beaconMacAddresses)!)")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: [])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == pService {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == sID {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == sID {
            var macAddrData = characteristic.value!
            macAddrData.remove(at: 3)
            macAddrData.remove(at: 3)
            macAddrData.reverse()
            let macAddr = macAddrData.map { (ad: UInt8) -> String in
                return String(format: "%02x", ad)
            }.joined(separator: ":")
            self.beaconMacAddresses[peripheral.identifier.uuidString] = macAddr
            DispatchQueue.main.async { () -> Void in
                print("  id: \(peripheral.identifier)\ndata: \(macAddr)")
                self.centralManager?.cancelPeripheralConnection(peripheral)
            }
        }
    }
}
