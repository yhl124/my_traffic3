//
//  SearchView.swift
//  my_traffic3
//
//  Created by yhl on 5/19/24.
//

import SwiftUI


struct SearchView: View {
    @State private var searchText = ""
    @State private var busStops: [BusStop] = []
    @State private var selectedBusStop: BusStop?
    @State private var showingDetail = false

    var body: some View {
        VStack {
            List(busStops, id: \.stationId) { busStop in
                Button(action: {
                    selectedBusStop = busStop
                    showingDetail = true
                }) {
                    VStack(alignment: .leading) {
                        Text(busStop.stationName ?? "")
                        Text(busStop.mobileNo ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "정류장 검색")
        .onSubmit(of: .search, fetchBusStops)
        .navigationTitle("버스 정류장 검색")
        .sheet(item: $selectedBusStop, onDismiss: {
            showingDetail = false
        }) { busStop in
            //BusStopDetailView(busStop: busStop, showingDetail: $showingDetail)
            BusStopDetailView(busStop: busStop)
        }
    }

    func fetchBusStops() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            busStops = []
            return
        }

        APIService.shared.fetchBusStops(keyword: keyword) { busStops in
            self.busStops = busStops
        }
    }
}
