import Foundation


/// MARK: - NSURL+Ago
extension NSDate {

    /// MARK: - public api

    /**
     * get the Date ~ months ago
     * @param months months
     * @return NSDate
     */
    func hma_monthAgo(months months: Int) -> NSDate? {
        var dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.month = -months
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }

    /**
     * get the Date ~ months later
     * @param months months
     * @return NSDate
     */
    func hma_monthLater(months months: Int) -> NSDate? {
        var dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.month = months
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }

    /**
     * get the Date ~ days ago
     * @param days days
     * @return NSDate
     */
    func hma_daysAgo(days days: Int) -> NSDate? {
        var dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.day = -days
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }

    /**
     * get the Date ~ days later
     * @param days days
     * @return NSDate
     */
    func hma_daysLater(days days: Int) -> NSDate? {
        var dateComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        dateComponents.day = days
        return calendar.dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }

}
