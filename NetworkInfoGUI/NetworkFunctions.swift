//
//  Functions.swift
//  NetworkInfo
//
//  Created by Eric.Hemmeter on 7/19/19.
//  Copyright © 2019 Sneakypockets. All rights reserved.
//

import Foundation
import CoreWLAN
import SystemConfiguration

extension CWChannelBand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .band2GHz: return "2.4GHz"
        case .band5GHz: return "5GHz"
        default: return "Unknown"
        }
    }
}

extension CWChannelWidth: CustomStringConvertible {
    public var description: String {
        switch  self {
        case .width160MHz:
            return "160MHz"
        case .width20MHz:
            return "20MHz"
        case .width40MHz:
            return "40MHz"
        case .width80MHz:
            return "80MHz"
        default:
            return "Unknown"
        }
    }
}

struct NetworkFunctions {
        
    static func updateNetworkInfo() throws -> [String]? {
            var output: [String] = []

            if let serviceList = try! NetworkFunctions.getNetworkServices() {
            //    print(serviceList)
                for service in serviceList {
                    if let service_name = try! NetworkFunctions.getServiceName(service as CFString),
                         let ip_address = try! NetworkFunctions.getIP(service as CFString) {
                        //            print("\(service_name):\(ip_address)")
                        output.append(String("\(service_name): \(ip_address)"))
                        if service_name == "Wi-Fi" {
                            if let wifiInfo = try! NetworkFunctions.getWifiInfo() {
                                //                print(wifiInfo)
                                output.append(wifiInfo)
                            }
                        }
                    }                    
                }
            }
            let publicIP = try! NetworkFunctions.getExternalIP()
            //    print(publicIP)
            output.append(publicIP)
            
            return output
        }
    
    static func getNetworkServices() throws -> [String]? {
        let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil)!
        let service_config = SCNetworkSetCopyCurrent(prefs)!
        let service_list_cf = SCNetworkSetGetServiceOrder(service_config)
        let service_order = service_list_cf as! Array<String>
        return service_order
    }
    
    static func getWifiInfo() throws -> String? {
        let client = CWWiFiClient.shared()
        if let ssid_name = client.interface()?.ssid(),
            let channel_number = client.interface()?.wlanChannel()?.channelNumber,
            let channel_width = client.interface()?.wlanChannel()?.channelWidth,
            let channel_band = client.interface()?.wlanChannel()?.channelBand
        {
            return String("\(ssid_name) / \(channel_number)@\(channel_band)-\(channel_width) wide")
        }
        else
        {
            return nil
        }
    }
    
    static func getServiceName(_ service: CFString) throws -> String? {
        if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
            let network_services_copy = SCNetworkServiceCopy(prefs, service),
            let service_name = SCNetworkServiceGetName(network_services_copy) {
            return service_name as String
        } else {
            return nil
        }
    }
    
    static func getIP(_ service: CFString) throws -> String? {
        if let prefs = SCPreferencesCreateWithAuthorization(nil, "prefs" as CFString, nil, nil),
            let net_config = SCDynamicStoreCreate(nil, "net" as CFString, nil, nil),
            let network_services_copy = SCNetworkServiceCopy(prefs, service),
            let network_interface = SCNetworkServiceGetInterface(network_services_copy),
            let bsdName = SCNetworkInterfaceGetBSDName(network_interface),
            let ipInfo = SCDynamicStoreCopyValue(net_config, String("State:/Network/Interface/\(bsdName)/IPv4") as CFString),
            let address = ipInfo[kSCPropNetIPv4Addresses] as? [String]
        {
            return address[0]
        } else {
            return nil
        }
    }
    
    static func getExternalIP() throws -> String {
        do {
        let publicIP = try String(contentsOf: URL(string: "https://icanhazip.com/")!)
        return String("External: \(publicIP)")
        } catch {
            return String("No external connection")
        }
    }
}
