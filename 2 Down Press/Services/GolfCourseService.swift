import Foundation
import CoreLocation

class GolfCourseService: GolfCourseServiceProtocol {
    func getGolfCourse() -> GolfCourse {
        return GolfCourse.bayouDeSiard
    }
} 