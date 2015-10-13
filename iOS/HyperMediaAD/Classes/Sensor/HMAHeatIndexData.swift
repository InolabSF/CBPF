import Foundation
import CoreData


/// MARK: - HMAHeatIndexData
class HMAHeatIndexData: NSManagedObject {

    /// MARK: - property
    @NSManaged var humidity: NSNumber
    @NSManaged var temperature: NSNumber
    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var timestamp: NSDate


    /// MARK: - public class method

    /**
     * fetch datas from coredata
     * @param minimumCoordinate CLLocationCoordinate2D
     * @param maximumCoordinate CLLocationCoordinate2D
     * @return [HMAHeatIndexData]
     */
    class func fetch(minimumCoordinate minimumCoordinate: CLLocationCoordinate2D, maximumCoordinate: CLLocationCoordinate2D) -> [HMAHeatIndexData] {
        let context = HMACoreDataManager.sharedInstance.managedObjectContext

        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMAHeatIndexData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        let predicaets = [
            NSPredicate(format: "(lat <= %@) AND (lat >= %@)", NSNumber(double: maximumCoordinate.latitude), NSNumber(double: minimumCoordinate.latitude)),
            NSPredicate(format: "(long <= %@) AND (long >= %@)", NSNumber(double: maximumCoordinate.longitude), NSNumber(double: minimumCoordinate.longitude)),
        ]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        //var error: NSError? = nil
        var datas: [HMAHeatIndexData]? = nil
        do {
            datas = try context.executeFetchRequest(fetchRequest) as? [HMAHeatIndexData]
        }
        catch _ {
            datas = []
        }
        return datas!
    }

    /**
     * save json datas to coredata
     */
    class func save() {
/*
        if HMAHeatIndexData.hasData() { return }
        if !(HMASensorData.hasData(sensorType: HMASensor.SensorType.Humidity)) { return }
        if !(HMASensorData.hasData(sensorType: HMASensor.SensorType.Temperature)) { return }

        HMAHeatIndexData.delete()

        var humidityDatas = HMASensorData.fetch(sensorType: HMASensor.SensorType.Humidity)
        var temperatureDatas = HMASensorData.fetch(sensorType: HMASensor.SensorType.Temperature)

        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        var humidityIndex = 0
        for var i = 0; i < temperatureDatas.count; i++ {
            var temperatureData = temperatureDatas[i]
            for var j = humidityIndex; j < humidityDatas.count; j++ {
                var humidityData = humidityDatas[i]
                if temperatureData.lat != humidityData.lat ||
                   temperatureData.long != humidityData.long ||
                   temperatureData.timestamp != humidityData.timestamp {
                       continue
                }
                humidityIndex = j

                var data = NSEntityDescription.insertNewObjectForEntityForName("HMAHeatIndexData", inManagedObjectContext: context) as! HMAHeatIndexData
                data.humidity = humidityData.value
                data.temperature = temperatureData.value
                data.lat = humidityData.lat
                data.long = humidityData.long
                data.timestamp = humidityData.timestamp

                break
            }
        }

        var error: NSError? = nil
        !context.save(&error)

        if error == nil {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentYearMonthDay = dateFormatter.stringFromDate(NSDate())
            var key = HMAUserDefaults.HeatIndexYearMonthDay
            NSUserDefaults().setObject(currentYearMonthDay, forKey: key)
            NSUserDefaults().synchronize()
        }
*/
        if !(HMASensorData.hasData(sensorType: HMASensor.SensorType.Humidity)) { return }
        if !(HMASensorData.hasData(sensorType: HMASensor.SensorType.Temperature)) { return }
        if HMAHeatIndexData.hasData() { return }

        //var start = NSDate()
        HMAHeatIndexData.delete()
        //var interval = NSDate().timeIntervalSinceDate(start)
        //HMALOG("interval1: \(interval)")

        //start = NSDate()
        var humidityDatas = HMASensorData.fetch(sensorType: HMASensor.SensorType.Humidity)
        var temperatureDatas = HMASensorData.fetch(sensorType: HMASensor.SensorType.Temperature)
        //interval = NSDate().timeIntervalSinceDate(start)
        //HMALOG("interval2: \(interval)")

        let backgroundQueue = dispatch_queue_create("HMAHeatIndexData", nil)
        dispatch_async(backgroundQueue, {

            //start = NSDate()

            let context = HMACoreDataManager.sharedInstance.managedObjectContext

            var humidityIndex = 0
            for var i = 0; i < temperatureDatas.count; i++ {
                let temperatureData = temperatureDatas[i]
                for var j = humidityIndex; j < humidityDatas.count; j++ {
                    let humidityData = humidityDatas[i]
                    if temperatureData.lat != humidityData.lat ||
                       temperatureData.long != humidityData.long ||
                       temperatureData.timestamp != humidityData.timestamp {
                           continue
                    }
                    humidityIndex = j

                    let data = NSEntityDescription.insertNewObjectForEntityForName("HMAHeatIndexData", inManagedObjectContext: context) as! HMAHeatIndexData
                    data.humidity = humidityData.value
                    data.temperature = temperatureData.value
                    data.lat = humidityData.lat
                    data.long = humidityData.long
                    data.timestamp = humidityData.timestamp

                    break
                }
            }

            //interval = NSDate().timeIntervalSinceDate(start)
            //HMALOG("interval3: \(interval)")

            dispatch_async(dispatch_get_main_queue(), {
                if HMAHeatIndexData.hasData() { return }

                //start = NSDate()

                //var error: NSError? = nil
                do {
                    try context.save()
                }
                catch _ {
                    return
                }

                //if error == nil {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let currentYearMonthDay = dateFormatter.stringFromDate(NSDate())
                    let key = HMAUserDefaults.HeatIndexYearMonthDay
                    NSUserDefaults().setObject(currentYearMonthDay, forKey: key)
                    NSUserDefaults().synchronize()
                //}

                //interval = NSDate().timeIntervalSinceDate(start)
                //HMALOG("interval4: \(interval)")
            })
        })
    }


    /**
     * delete data
     **/
    class func delete() {
        let context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMAHeatIndexData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        // get all datas
        //let error: NSError? = nil
        var datas: [HMAHeatIndexData]? = nil
        do {
            datas = try context.executeFetchRequest(fetchRequest) as? [HMAHeatIndexData]
        }
        catch _ {
        }
        
        if /*error != nil || */datas == nil {
            return
        }

        // delete
        for data in datas! {
            context.deleteObject(data)
        }

        let key = HMAUserDefaults.HeatIndexYearMonthDay
        NSUserDefaults().setObject("", forKey: key)
        NSUserDefaults().synchronize()
    }


    /// MARK: - private class method

    /**
     * check if client needs to get new data
     * @return Bool
     **/
    private class func hasData() -> Bool {
        let key = HMAUserDefaults.HeatIndexYearMonthDay

        // saved
        let savedYearMonthDay = NSUserDefaults().stringForKey(key)
        // current
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentYearMonthDay = dateFormatter.stringFromDate(NSDate())
        return (savedYearMonthDay == currentYearMonthDay)
    }

}
