//
//  APIService.swift
//  my_traffic3
//
//  Created by yhl on 5/19/24.
//

import Foundation
import CoreData

class APIService {
    static let shared = APIService()

    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["API_KEY"] as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'Config.plist'.")
        }
        return value
    }

    func fetchBusStops(keyword: String, completion: @escaping ([BusStop]) -> Void) {
        let urlString = "https://apis.data.go.kr/6410000/busstationservice/getBusStationList?serviceKey=\(apiKey)&keyword=\(keyword)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            let busStops = self.parseBusStops(data: data)
            DispatchQueue.main.async {
                completion(busStops)
            }
        }.resume()
    }

    func fetchBusRoutes(stationId: String, completion: @escaping ([BusRoute]) -> Void) {
        let urlString = "https://apis.data.go.kr/6410000/busstationservice/getBusStationViaRouteList?serviceKey=\(apiKey)&stationId=\(stationId)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            let busRoutes = self.parseBusRoutes(data: data)
            DispatchQueue.main.async {
                completion(busRoutes)
            }
        }.resume()
    }

    private func parseBusStops(data: Data) -> [BusStop] {
        var busStops: [BusStop] = []

        let context = PersistenceController.shared.container.viewContext

        let parser = XMLParser(data: data)
        let delegate = BusStopXMLParserDelegate(context: context)
        parser.delegate = delegate

        if parser.parse() {
            busStops = delegate.busStops
        }

        return busStops
    }

    private func parseBusRoutes(data: Data) -> [BusRoute] {
        var busRoutes: [BusRoute] = []

        let context = PersistenceController.shared.container.viewContext

        let parser = XMLParser(data: data)
        let delegate = BusRouteXMLParserDelegate(context: context)
        parser.delegate = delegate

        if parser.parse() {
            busRoutes = delegate.busRoutes
        }

        return busRoutes
    }
}

class BusStopXMLParserDelegate: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentMobileNo = ""
    private var currentStationId = ""
    private var currentStationName = ""

    var busStops: [BusStop] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "mobileNo":
            currentMobileNo += string.trimmingCharacters(in: .whitespacesAndNewlines)
        case "stationId":
            currentStationId += string.trimmingCharacters(in: .whitespacesAndNewlines)
        case "stationName":
            currentStationName += string.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "busStationList" {
            let busStop = BusStop(context: context)
            busStop.mobileNo = currentMobileNo
            busStop.stationId = currentStationId
            busStop.stationName = currentStationName
            busStops.append(busStop)

            currentMobileNo = ""
            currentStationId = ""
            currentStationName = ""
        }
    }
}

class BusRouteXMLParserDelegate: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentRouteId = ""
    private var currentRouteName = ""
    private var currentRouteTypeCd = ""

    var busRoutes: [BusRoute] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "routeId":
            currentRouteId += string.trimmingCharacters(in: .whitespacesAndNewlines)
        case "routeName":
            currentRouteName += string.trimmingCharacters(in: .whitespacesAndNewlines)
        case "routeTypeCd":
            currentRouteTypeCd += string.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "busRouteList" {
            let busRoute = BusRoute(context: context)
            busRoute.routeId = currentRouteId
            busRoute.routeName = currentRouteName
            busRoute.routeTypeCd = currentRouteTypeCd
            busRoutes.append(busRoute)

            currentRouteId = ""
            currentRouteName = ""
            currentRouteTypeCd = ""
        }
    }
}
