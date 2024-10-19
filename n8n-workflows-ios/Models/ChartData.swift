//
//  ChartData.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/10/24.
//

import Foundation

enum ChartCategoryType {
    case hour, day, value
}

enum ChartType {
    case line, point
}

struct ChartData: Identifiable {
    let id = UUID()
    let title: String
    let data: [SeriesData]
    let type: ChartType
    let categoryType: ChartCategoryType
}

extension ChartData {
    static var dummyData: ChartData {
        ChartData(
            title: "Chart 1",
            data: SeriesData.dummyData,
            type: .line,
            categoryType: .day
        )
    }
}

struct SeriesData: Identifiable, Equatable {
    var id = UUID()
    var category: String
    var value: Double
    var series: String
}

extension SeriesData {
    static var dummyData: [SeriesData] {
        return [
            SeriesData(category: "2022-05-29T02:00:00.000Z", value: 0.217, series: "duration"),
            SeriesData(category: "2022-05-29T03:00:00.000Z", value: 0.358, series: "duration"),
            SeriesData(category: "2022-05-29T04:00:00.000Z", value: 0.292, series: "duration"),
            SeriesData(category: "2022-05-29T05:00:00.000Z", value: 0.195, series: "duration"),
            SeriesData(category: "2022-05-29T06:00:00.000Z", value: 0.312, series: "duration"),
            SeriesData(category: "2022-05-29T07:00:00.000Z", value: 0.453, series: "duration"),
            SeriesData(category: "2022-05-29T08:00:00.000Z", value: 0.186, series: "duration"),
            SeriesData(category: "2022-05-29T09:00:00.000Z", value: 0.371, series: "duration"),
            SeriesData(category: "2022-05-29T10:00:00.000Z", value: 0.225, series: "duration"),
            SeriesData(category: "2022-05-29T11:00:00.000Z", value: 0.489, series: "duration"),
            SeriesData(category: "2022-05-29T12:00:00.000Z", value: 0.174, series: "duration"),
            SeriesData(category: "2022-05-29T13:00:00.000Z", value: 0.423, series: "duration"),
            SeriesData(category: "2022-05-29T14:00:00.000Z", value: 0.392, series: "duration"),
            SeriesData(category: "2022-05-29T15:00:00.000Z", value: 0.362, series: "duration"),
            SeriesData(category: "2022-05-29T16:00:00.000Z", value: 0.144, series: "duration"),
            SeriesData(category: "2022-05-29T17:00:00.000Z", value: 0.411, series: "duration"),
            SeriesData(category: "2022-05-29T18:00:00.000Z", value: 0.197, series: "duration"),
            SeriesData(category: "2022-05-29T19:00:00.000Z", value: 0.226, series: "duration"),
            SeriesData(category: "2022-05-29T20:00:00.000Z", value: 0.487, series: "duration"),
            SeriesData(category: "2022-05-29T21:00:00.000Z", value: 0.241, series: "duration"),
            SeriesData(category: "2022-05-29T22:00:00.000Z", value: 0.374, series: "duration"),
            SeriesData(category: "2022-05-29T23:00:00.000Z", value: 0.165, series: "duration"),
            SeriesData(category: "2022-05-30T00:00:00.000Z", value: 0.428, series: "duration"),
            SeriesData(category: "2022-05-30T01:00:00.000Z", value: 0.498, series: "duration"),
            SeriesData(category: "2022-05-30T02:00:00.000Z", value: 0.212, series: "duration"),
            SeriesData(category: "2022-05-30T03:00:00.000Z", value: 0.157, series: "duration"),
            SeriesData(category: "2022-05-30T04:00:00.000Z", value: 0.335, series: "duration"),
            SeriesData(category: "2022-05-30T05:00:00.000Z", value: 0.421, series: "duration"),
            SeriesData(category: "2022-05-30T06:00:00.000Z", value: 0.312, series: "duration"),
            SeriesData(category: "2022-05-30T07:00:00.000Z", value: 0.198, series: "duration"),
            SeriesData(category: "2022-05-30T08:00:00.000Z", value: 0.413, series: "duration"),
            SeriesData(category: "2022-05-30T09:00:00.000Z", value: 0.325, series: "duration"),
            SeriesData(category: "2022-05-30T10:00:00.000Z", value: 0.231, series: "duration"),
            SeriesData(category: "2022-05-30T11:00:00.000Z", value: 0.452, series: "duration"),
            SeriesData(category: "2022-05-30T12:00:00.000Z", value: 0.344, series: "duration"),
            SeriesData(category: "2022-05-30T13:00:00.000Z", value: 0.482, series: "duration"),
            SeriesData(category: "2022-05-30T14:00:00.000Z", value: 0.269, series: "duration"),
            SeriesData(category: "2022-05-30T15:00:00.000Z", value: 0.216, series: "duration"),
            SeriesData(category: "2022-05-30T16:00:00.000Z", value: 0.394, series: "duration"),
            SeriesData(category: "2022-05-30T17:00:00.000Z", value: 0.488, series: "duration"),
            SeriesData(category: "2022-05-30T18:00:00.000Z", value: 0.221, series: "duration"),
            SeriesData(category: "2022-05-30T19:00:00.000Z", value: 0.346, series: "duration"),
            SeriesData(category: "2022-05-30T20:00:00.000Z", value: 0.183, series: "duration"),
            SeriesData(category: "2022-05-30T21:00:00.000Z", value: 0.275, series: "duration"),
            SeriesData(category: "2022-05-30T22:00:00.000Z", value: 0.392, series: "duration"),
            SeriesData(category: "2022-05-30T23:00:00.000Z", value: 0.117, series: "duration"),
            SeriesData(category: "2022-05-31T00:00:00.000Z", value: 0.453, series: "duration"),
            SeriesData(category: "2022-05-31T01:00:00.000Z", value: 0.236, series: "duration"),
            SeriesData(category: "2022-05-31T02:00:00.000Z", value: 0.261, series: "duration"),
            SeriesData(category: "2022-05-31T03:00:00.000Z", value: 0.177, series: "duration"),
            SeriesData(category: "2022-05-31T04:00:00.000Z", value: 0.491, series: "duration"),
            SeriesData(category: "2022-05-31T05:00:00.000Z", value: 0.356, series: "duration"),
            SeriesData(category: "2022-05-31T06:00:00.000Z", value: 0.218, series: "duration"),
            SeriesData(category: "2022-05-31T07:00:00.000Z", value: 0.364, series: "duration"),
            SeriesData(category: "2022-05-31T08:00:00.000Z", value: 0.448, series: "duration"),
            SeriesData(category: "2022-05-31T09:00:00.000Z", value: 0.128, series: "duration"),
            SeriesData(category: "2022-05-31T10:00:00.000Z", value: 0.254, series: "duration"),
            SeriesData(category: "2022-05-31T11:00:00.000Z", value: 0.382, series: "duration"),
            SeriesData(category: "2022-05-31T12:00:00.000Z", value: 0.176, series: "duration"),
            SeriesData(category: "2022-05-31T13:00:00.000Z", value: 0.241, series: "duration"),
            SeriesData(category: "2022-05-31T14:00:00.000Z", value: 0.198, series: "duration"),
            SeriesData(category: "2022-05-31T15:00:00.000Z", value: 0.457, series: "duration"),
            SeriesData(category: "2022-05-31T16:00:00.000Z", value: 0.263, series: "duration"),
            SeriesData(category: "2022-05-31T17:00:00.000Z", value: 0.423, series: "duration"),
            SeriesData(category: "2022-05-31T18:00:00.000Z", value: 0.399, series: "duration"),
            SeriesData(category: "2022-05-31T19:00:00.000Z", value: 0.194, series: "duration"),
            SeriesData(category: "2022-05-31T20:00:00.000Z", value: 0.473, series: "duration"),
            SeriesData(category: "2022-05-31T21:00:00.000Z", value: 0.386, series: "duration"),
            SeriesData(category: "2022-05-31T22:00:00.000Z", value: 0.415, series: "duration"),
            SeriesData(category: "2022-05-31T23:00:00.000Z", value: 0.263, series: "duration"),
            SeriesData(category: "2022-06-01T00:00:00.000Z", value: 0.314, series: "duration"),
            SeriesData(category: "2022-06-01T01:00:00.000Z", value: 0.225, series: "duration"),
            SeriesData(category: "2022-06-01T02:00:00.000Z", value: 0.337, series: "duration"),
            SeriesData(category: "2022-06-01T03:00:00.000Z", value: 0.145, series: "duration"),
            SeriesData(category: "2022-06-01T04:00:00.000Z", value: 0.492, series: "duration"),
            SeriesData(category: "2022-06-01T05:00:00.000Z", value: 0.281, series: "duration"),
            SeriesData(category: "2022-06-01T06:00:00.000Z", value: 0.367, series: "duration"),
            SeriesData(category: "2022-06-01T07:00:00.000Z", value: 0.399, series: "duration"),
            SeriesData(category: "2022-06-01T08:00:00.000Z", value: 0.222, series: "duration"),
            SeriesData(category: "2022-06-01T09:00:00.000Z", value: 0.298, series: "duration"),
            SeriesData(category: "2022-06-01T10:00:00.000Z", value: 0.481, series: "duration"),
            SeriesData(category: "2022-06-01T11:00:00.000Z", value: 0.413, series: "duration"),
            SeriesData(category: "2022-06-01T12:00:00.000Z", value: 0.247, series: "duration"),
            SeriesData(category: "2022-06-01T13:00:00.000Z", value: 0.197, series: "duration"),
            SeriesData(category: "2022-06-01T14:00:00.000Z", value: 0.341, series: "duration"),
            SeriesData(category: "2022-06-01T15:00:00.000Z", value: 0.389, series: "duration"),
            SeriesData(category: "2022-06-01T16:00:00.000Z", value: 0.219, series: "duration"),
            SeriesData(category: "2022-06-01T17:00:00.000Z", value: 0.455, series: "duration"),
            SeriesData(category: "2022-06-01T18:00:00.000Z", value: 0.183, series: "duration"),
            SeriesData(category: "2022-06-01T19:00:00.000Z", value: 0.431, series: "duration"),
            SeriesData(category: "2022-06-01T20:00:00.000Z", value: 0.275, series: "duration"),
            SeriesData(category: "2022-06-01T21:00:00.000Z", value: 0.354, series: "duration"),
            SeriesData(category: "2022-06-01T22:00:00.000Z", value: 0.326, series: "duration"),
            SeriesData(category: "2022-06-01T23:00:00.000Z", value: 0.482, series: "duration"),
            SeriesData(category: "2022-06-02T00:00:00.000Z", value: 0.277, series: "duration"),
            SeriesData(category: "2022-06-02T01:00:00.000Z", value: 0.223, series: "duration"),
            SeriesData(category: "2022-06-02T02:00:00.000Z", value: 0.144, series: "duration"),
            SeriesData(category: "2022-06-02T03:00:00.000Z", value: 0.317, series: "duration"),
            SeriesData(category: "2022-06-02T04:00:00.000Z", value: 0.491, series: "duration"),
            SeriesData(category: "2022-06-02T05:00:00.000Z", value: 0.385, series: "duration"),
            SeriesData(category: "2022-06-02T06:00:00.000Z", value: 0.465, series: "duration"),
            SeriesData(category: "2022-06-02T07:00:00.000Z", value: 0.356, series: "duration"),
            SeriesData(category: "2022-06-02T08:00:00.000Z", value: 0.298, series: "duration"),
            SeriesData(category: "2022-06-02T09:00:00.000Z", value: 0.417, series: "duration"),
            SeriesData(category: "2022-06-02T10:00:00.000Z", value: 0.439, series: "duration"),
            SeriesData(category: "2022-06-02T11:00:00.000Z", value: 0.389, series: "duration"),
            SeriesData(category: "2022-06-02T12:00:00.000Z", value: 0.374, series: "duration"),
            SeriesData(category: "2022-06-02T13:00:00.000Z", value: 0.219, series: "duration"),
            SeriesData(category: "2022-06-02T14:00:00.000Z", value: 0.313, series: "duration"),
            SeriesData(category: "2022-06-02T15:00:00.000Z", value: 0.197, series: "duration"),
            SeriesData(category: "2022-06-02T16:00:00.000Z", value: 0.364, series: "duration"),
            SeriesData(category: "2022-06-02T17:00:00.000Z", value: 0.418, series: "duration"),
            SeriesData(category: "2022-06-02T18:00:00.000Z", value: 0.175, series: "duration"),
            SeriesData(category: "2022-06-02T19:00:00.000Z", value: 0.249, series: "duration"),
            SeriesData(category: "2022-06-02T20:00:00.000Z", value: 0.474, series: "duration"),
            SeriesData(category: "2022-06-02T21:00:00.000Z", value: 0.284, series: "duration"),
            SeriesData(category: "2022-06-02T21:00:00.000Z", value: 0.374, series: "duration 2"),
            SeriesData(category: "2022-06-02T22:00:00.000Z", value: 0.472, series: "duration"),
            SeriesData(category: "2022-06-02T22:00:00.000Z", value: 0.197, series: "duration 2"),
            SeriesData(category: "2022-06-02T23:00:00.000Z", value: 0.392, series: "duration"),
            SeriesData(category: "2022-06-02T23:00:00.000Z", value: 0.284, series: "duration 2")
        ]
    }
}
