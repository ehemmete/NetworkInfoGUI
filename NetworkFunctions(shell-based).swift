//
//  Functions.swift
//  NetworkInfo
//
//  Created by Eric.Hemmeter on 7/19/19.
//  Copyright © 2019 Sneakypockets. All rights reserved.
//

import Foundation
import CoreWLAN

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
    static func getNetworkServices() throws -> [String]? {
        let services_data = try ProcessRunner.shellCommand("/usr/sbin/networksetup", ["-listallnetworkservices"])
        let services_array = String(data: services_data, encoding: .utf8)?.components(separatedBy: CharacterSet.newlines)
        let services_filtered = services_array?.filter() { !$0.contains("An asterisk (*) denotes") }
        return services_filtered
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
    
    static func getIP(_ service: String) throws -> String? {
        let ip_address_data = try ProcessRunner.shellCommand("/usr/sbin/networksetup", ["-getinfo",service])
            let ip_address_array = String(data: ip_address_data, encoding: .utf8)?.components(separatedBy: CharacterSet.newlines)
            if let ip_address_filtered = ip_address_array?.filter({ $0.contains("IP address") && !$0.contains("IPv6") }) {
                if !ip_address_filtered.joined().isEmpty {
                    let ip_address_long = ip_address_filtered.joined()
                    let ip_address = ip_address_long.components(separatedBy: ":")[1]
                 return ip_address
                }
                else
                {
                    return nil
                }
        }
        return nil
    }
    
    static func getExternalIP() throws -> String? {
        if let publicIP = try? String(contentsOf: URL(string: "https://icanhazip.com/")!) {
            return String("External: \(publicIP)")
        } else {
            return String("No external connection")
        }
    }
}
