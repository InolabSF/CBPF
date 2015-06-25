import Foundation
import CoreData


/// MARK: - HMAWheelData
class HMAWheelData: NSManagedObject {

    /// MARK: - property
    @NSManaged var data_type : NSNumber
    @NSManaged var value : NSNumber
    @NSManaged var lat : NSNumber
    @NSManaged var long : NSNumber
    @NSManaged var timestamp : NSDate


    /// MARK: - public class method

    /**
     * request to get wheel data to server
     * @param dataType HMAWheel.DataType(Int)
     * @param max maxValue
     * @param min minValue
     **/
    class func requestToGetWheelData(#dataType: Int, max: Float?, min: Float?) {
        if HMAWheelData.hasData(dataType: dataType) { return }
        let location = HMAMapView.sharedInstance.myLocation
        if location == nil { return }

        HMAWheelClient.sharedInstance.cancelGetWheelData(dataType: dataType)

        // get wheel data from CBPF server
        HMAWheelClient.sharedInstance.getWheelData(
            radius: HMAAPI.Radius,
            dataType: dataType,
            max: max,
            min: min,
            coordinate: location.coordinate,
            completionHandler: { (json) in
                HMAWheelData.save(dataType: dataType, json: json)
            }
        )
    }

    /**
     * fetch datas from coredata
     * @param dataType HMAWheel.DataType(Int)
     * @param minimumCoordinate CLLocationCoordinate2D
     * @param maximumCoordinate CLLocationCoordinate2D
     * @return Array<HMACrimeData>
     */
    class func fetch(#dataType: Int, minimumCoordinate: CLLocationCoordinate2D, maximumCoordinate: CLLocationCoordinate2D) -> Array<HMAWheelData> {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMAWheelData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        let predicaets = [
            NSPredicate(format: "data_type= %d", dataType),
            NSPredicate(format: "(lat <= %@) AND (lat >= %@)", NSNumber(double: maximumCoordinate.latitude), NSNumber(double: minimumCoordinate.latitude)),
            NSPredicate(format: "(long <= %@) AND (long >= %@)", NSNumber(double: maximumCoordinate.longitude), NSNumber(double: minimumCoordinate.longitude)),
        ]
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]

        var error: NSError? = nil
        let wheelDatas = context.executeFetchRequest(fetchRequest, error: &error) as! Array<HMAWheelData>
        return wheelDatas
    }

    /**
     * save json datas to coredata
     * @param dataType HMAWheel.DataType(Int)
     * @param json JSON
     *  {
     *    "wheel_datas": [
     *      {
     *        "created_at": "2015-05-07T01:25:39.744Z",
     *        "id": 1,
     *        "data_type": 18,
     *        "value": 1.0353324,
     *        "lat": 37.792097317369965,
     *        "long": -122.43528085596421,
     *        "timestamp": "2015-05-07T01:25:39.738Z",
     *        "updated_at": "2015-05-07T01:25:39.744Z",
     *      },
     *      ...
     *    ]
     *  }
     */
    class func save(#dataType: Int, json: JSON) {
        if HMAWheelData.hasData(dataType: dataType) { return }

        HMAWheelData.delete()

        let wheelDatas: Array<JSON> = json["wheel_datas"].arrayValue

        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")

        for wheelData in wheelDatas {
            var s = NSEntityDescription.insertNewObjectForEntityForName("HMAWheelData", inManagedObjectContext: context) as! HMAWheelData
            s.data_type = wheelData["data_type"].numberValue
            s.value = wheelData["value"].numberValue
            s.lat = wheelData["lat"].numberValue
            s.long = wheelData["long"].numberValue
            let date = dateFormatter.dateFromString(wheelData["timestamp"].stringValue)
            if date != nil { s.timestamp = date! }
        }

        var error: NSError? = nil
        !context.save(&error)

        var key = HMAWheelData.getUserDefaultsKey(dataType: dataType)
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
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMAWheelData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        // get all wheel datas
        var error: NSError? = nil
        let wheelDatas = context.executeFetchRequest(fetchRequest, error: &error) as? [HMAWheelData]
        if error != nil || wheelDatas == nil {
            return
        }

        // delete
        for wheelData in wheelDatas! {
            context.deleteObject(wheelData)
        }
    }


    /// MARK: - private class method

    /**
     * get NSUserDefaults key
     * @param dataType HMAWheel.DataType(Int)
     * @return key(String?)
     **/
    private class func getUserDefaultsKey(#dataType: Int) -> String? {
        var keys = [
            HMAWheel.DataType.Speed : HMAUserDefaults.WheelSpeedYearMonthDay,
            HMAWheel.DataType.Slope : HMAUserDefaults.WheelSlopeYearMonthDay,
            HMAWheel.DataType.EnergyEfficiency : HMAUserDefaults.WheelEnergyEfficiencyYearMonthDay,
            HMAWheel.DataType.TotalOdometer : HMAUserDefaults.WheelTotalOdometerYearMonthDay,
            HMAWheel.DataType.TripOdometer : HMAUserDefaults.WheelTripOdometerYearMonthDay,
            HMAWheel.DataType.TripAverageSpeed : HMAUserDefaults.WheelTripAverageSpeedYearMonthDay,
            HMAWheel.DataType.TripEnergyEfficiency : HMAUserDefaults.WheelTripEnergyEfficiencyYearMonthDay,
            HMAWheel.DataType.MotorTemperature : HMAUserDefaults.WheelMotorTemperatureYearMonthDay,
            HMAWheel.DataType.MotorDriveTemperature : HMAUserDefaults.WheelMotorDriveTemperatureYearMonthDay,
            HMAWheel.DataType.RiderTorque : HMAUserDefaults.WheelRiderTorqueYearMonthDay,
            HMAWheel.DataType.RiderPower : HMAUserDefaults.WheelRiderPowerYearMonthDay,
            HMAWheel.DataType.BatteryCharge : HMAUserDefaults.WheelBatteryChargeYearMonthDay,
            HMAWheel.DataType.BatteryHealth : HMAUserDefaults.WheelBatteryHealthYearMonthDay,
            HMAWheel.DataType.BatteryPower : HMAUserDefaults.WheelBatteryPowerYearMonthDay,
            HMAWheel.DataType.BatteryVoltage : HMAUserDefaults.WheelBatteryVoltageYearMonthDay,
            HMAWheel.DataType.BatteryCurrent : HMAUserDefaults.WheelBatteryCurrentYearMonthDay,
            HMAWheel.DataType.BatteryTemperature : HMAUserDefaults.WheelBatteryTemperatureYearMonthDay,
            HMAWheel.DataType.BatteryTimeToFull : HMAUserDefaults.WheelBatteryTimeToFullYearMonthDay,
            HMAWheel.DataType.BatteryTimeToEmpty : HMAUserDefaults.WheelBatteryTimeToEmptyYearMonthDay,
            HMAWheel.DataType.BatteryRange : HMAUserDefaults.WheelBatteryRangeYearMonthDay,
            HMAWheel.DataType.RawDebugData : HMAUserDefaults.WheelRawDebugDataYearMonthDay,
            HMAWheel.DataType.BatteryPowerNormalized : HMAUserDefaults.WheelBatteryPowerNormalizedYearMonthDay,
            HMAWheel.DataType.Acceleration : HMAUserDefaults.WheelAccelerationYearMonthDay,
        ]
        return keys[dataType]

    }

    /**
     * check if client needs to get new wheel data
     * @param dataType HMAWheel.DataType(Int)
     * @return Bool
     **/
    private class func hasData(#dataType: Int) -> Bool {
        var key = HMAWheelData.getUserDefaultsKey(dataType: dataType)
        if key == nil { return true } // invalid data_type

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
