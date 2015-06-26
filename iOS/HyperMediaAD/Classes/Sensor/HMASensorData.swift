import Foundation
import CoreData


/// MARK: - HMASensorData
class HMASensorData: NSManagedObject {

    /// MARK: - property
    @NSManaged var sensor_id: NSNumber
    @NSManaged var value: NSNumber
    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var timestamp: NSDate


    /// MARK: - public class method

    /**
     * request to get sensor data to server
     * @param sensorType HMASensor.SensorType(Int)
     **/
    class func requestToGetSensorData(#sensorType: Int) {
        var coordinate = HMAMapView.sharedInstance.centerCoordinate()
        HMACoreDataManager.deleteAllDataIfNeeds(currentLocation: coordinate)

        if HMASensorData.hasData(sensorType: sensorType) { return }

        HMASensorClient.sharedInstance.cancelGetSensorData(sensorType: sensorType)

        // get sensor data from CBPF server
        HMASensorClient.sharedInstance.getSensorData(
            radius: HMAAPI.Radius,
            sensorType: sensorType,
            coordinate: coordinate,
            completionHandler: { (json) in
                HMASensorData.save(sensorType: sensorType, json: json)
            }
        )
    }

    /**
     * fetch datas from coredata
     * @param sensorType HMASensor.SensorType(Int)
     * @param minimumCoordinate CLLocationCoordinate2D
     * @param maximumCoordinate CLLocationCoordinate2D
     * @return Array<HMASensorData>
     */
    class func fetch(#sensorType: Int, minimumCoordinate: CLLocationCoordinate2D, maximumCoordinate: CLLocationCoordinate2D) -> Array<HMASensorData> {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMASensorData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        let predicaets = [
            NSPredicate(format: "sensor_id = %d", sensorType),
            NSPredicate(format: "(lat <= %@) AND (lat >= %@)", NSNumber(double: maximumCoordinate.latitude), NSNumber(double: minimumCoordinate.latitude)),
            NSPredicate(format: "(long <= %@) AND (long >= %@)", NSNumber(double: maximumCoordinate.longitude), NSNumber(double: minimumCoordinate.longitude)),
        ]
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]

        var error: NSError? = nil
        let sensorDatas = context.executeFetchRequest(fetchRequest, error: &error) as! Array<HMASensorData>
        return sensorDatas
    }

    /**
     * save json datas to coredata
     * @param sensorType  HMASensor.SensorType(Int)
     * @param json JSON
     *  {
     *    "sensor_datas": [
     *      {
     *        "created_at": "2015-05-07T01:25:39.744Z",
     *        "id": 1,
     *        "lat": 37.792097317369965,
     *        "long": -122.43528085596421,
     *        "sensor_id": 0,
     *        "timestamp": "2015-05-07T01:25:39.738Z",
     *        "updated_at": "2015-05-07T01:25:39.744Z",
     *        "user_id": null,
     *        "value": 57.23776223776224
     *      },
     *      ...
     *    ]
     *  }
     */
    class func save(#sensorType: Int, json: JSON) {
        if HMASensorData.hasData(sensorType: sensorType) { return }

        HMASensorData.delete(sensorType: sensorType)

        let sensorDatas: Array<JSON> = json["sensor_datas"].arrayValue

        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")

        for sensorData in sensorDatas {
            var s = NSEntityDescription.insertNewObjectForEntityForName("HMASensorData", inManagedObjectContext: context) as! HMASensorData
            s.sensor_id = sensorData["sensor_id"].numberValue
            s.value = sensorData["value"].numberValue
            s.lat = sensorData["lat"].numberValue
            s.long = sensorData["long"].numberValue
            s.user_id = sensorData["user_id"].numberValue
            let date = dateFormatter.dateFromString(sensorData["timestamp"].stringValue)
            if date != nil { s.timestamp = date! }
        }

        var error: NSError? = nil
        !context.save(&error)

        var key = HMASensorData.getUserDefaultsKey(sensorType: sensorType)
        if error == nil && key != nil {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentYearMonthDay = dateFormatter.stringFromDate(NSDate())
            NSUserDefaults().setObject(currentYearMonthDay, forKey: key!)
            NSUserDefaults().synchronize()
        }
    }

    /**
     * delete all datas
     **/
    class func delete() {
        let keys = HMASensorData.getUserDefaultsAllKeys()
        for (sensorType, key) in keys {
            HMASensorData.delete(sensorType: sensorType)
        }
    }

    /**
     * delete data
     * @param sensorType HMASensor.SensorType(Int)
     **/
    class func delete(#sensorType: Int) {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMASensorData", inManagedObjectContext:context)
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([NSPredicate(format: "sensor_id = %d", sensorType),])
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        // get all sensor datas
        var error: NSError? = nil
        let sensorDatas = context.executeFetchRequest(fetchRequest, error: &error) as? [HMASensorData]
        if error != nil || sensorDatas == nil {
            return
        }

        // delete
        for sensorData in sensorDatas! {
            context.deleteObject(sensorData)
        }

        let key = HMASensorData.getUserDefaultsKey(sensorType: sensorType)
        if key != nil {
            NSUserDefaults().setObject("", forKey: key!)
            NSUserDefaults().synchronize()
        }
    }


    /// MARK: - private class method

    /**
     * get NSUserDefaults all keys
     * @return [Int: String]
     **/
    private class func getUserDefaultsAllKeys() -> [Int: String] {
        return [
            HMASensor.SensorType.Humidity : HMAUserDefaults.SensorHumidityYearMonthDay,
            HMASensor.SensorType.Co : HMAUserDefaults.SensorCoYearMonthDay,
            HMASensor.SensorType.Co2 : HMAUserDefaults.SensorCo2YearMonthDay,
            HMASensor.SensorType.No2 : HMAUserDefaults.SensorNo2YearMonthDay,
            HMASensor.SensorType.Pm25 : HMAUserDefaults.SensorPm25YearMonthDay,
            HMASensor.SensorType.Noise : HMAUserDefaults.SensorNoiseYearMonthDay,
            HMASensor.SensorType.Temperature : HMAUserDefaults.SensorTemperatureYearMonthDay,
            HMASensor.SensorType.Light : HMAUserDefaults.SensorLightYearMonthDay,
        ]
    }

    /**
     * get NSUserDefaults key
     * @param sensorType HMASensor.SensorType(Int)
     * @return key(String?)
     **/
    private class func getUserDefaultsKey(#sensorType: Int) -> String? {
        var keys = HMASensorData.getUserDefaultsAllKeys()
        return keys[sensorType]
    }

    /**
     * check if client needs to get new sensor data
     * @param sensorType HMASensor.SensorType(Int)
     * @return Bool
     **/
    private class func hasData(#sensorType: Int) -> Bool {
        var key = HMASensorData.getUserDefaultsKey(sensorType: sensorType)
        if key == nil { return true } // invalid sensor type

        // saved
        let savedYearMonthDay = NSUserDefaults().stringForKey(key!)
        // current
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentYearMonthDay = dateFormatter.stringFromDate(NSDate())
        return (savedYearMonthDay == currentYearMonthDay)
    }

}
