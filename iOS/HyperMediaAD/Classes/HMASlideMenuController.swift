import UIKit


/// MARK: - HMASlideMenuController
class HMASlideMenuController: UIViewController, UITableViewDelegate {

    /// MARK: - property

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wheelBatteryLevelBackgroundImageView: UIImageView!
    @IBOutlet weak var wheelBatteryLevelImageView: UIImageView!
    @IBOutlet weak var wheelBatteryLabel: UILabel!
    private var UIModes: [Int] = [ HMAUserInterface.Mode.SetDestinations, ]
    private var selectedIndex = 0


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.updateWheelBatteryLevel()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * update user interface mode
     **/
    func updateUserInterfaceMode(UIMode: Int) {
        if UIMode == HMAUserInterface.Mode.SetDestinations {
            self.UIModes = [ HMAUserInterface.Mode.SetDestinations, ]
            self.selectedIndex = 0
        }
        else if UIMode == HMAUserInterface.Mode.SetRoute {
            self.UIModes = [ HMAUserInterface.Mode.SetDestinations, HMAUserInterface.Mode.SetRoute, ]
            self.selectedIndex = 1
        }
        else if UIMode == HMAUserInterface.Mode.Cycle {
            self.UIModes = [ HMAUserInterface.Mode.SetDestinations, HMAUserInterface.Mode.SetRoute, ]
            self.selectedIndex = -1
        }
        self.tableView.reloadData()
    }

    /**
     * update wheel battery level icon
     **/
    func updateWheelBatteryLevel() {
        // background battery icon
        self.wheelBatteryLevelBackgroundImageView.image = IonIcons.imageWithIcon(
            ion_battery_full,
            size: 50.0,
            color: UIColor.whiteColor()
        )

        let batteryLevel = HMAWheel.BatteryLevel.Low

        // battery icon
            // color
        var color = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1)
        if batteryLevel >= HMAWheel.BatteryLevel.Full { color = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1) }
        else if batteryLevel >= HMAWheel.BatteryLevel.Half { color = UIColor(red: 0.0, green: 0.75, blue: 0, alpha: 1) }
        else if batteryLevel >= HMAWheel.BatteryLevel.Low { color = UIColor(red: 0.75, green: 0.75, blue: 0, alpha: 1) }
        else { color = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1) }
            // icon
        var iconName = ""
        if batteryLevel >= HMAWheel.BatteryLevel.Full { iconName = ion_battery_full }
        else if batteryLevel >= HMAWheel.BatteryLevel.Half { iconName = ion_battery_half }
        else if batteryLevel >= HMAWheel.BatteryLevel.Low { iconName = ion_battery_low }
        else { iconName = ion_battery_empty }
        self.wheelBatteryLevelImageView.image = IonIcons.imageWithIcon(
            iconName,
            size: 50.0,
            color: color
        )

        // battery label
        self.wheelBatteryLabel.text = "\(batteryLevel)%"
    }


    /// MARK: - private api

    /**
     * return tableview cell count
     * @return cellCount Int
     **/
    private func cellCount() -> Int {
        return self.UIModes.count + 3
    }

    /**
     * return tableview cell height
     * @param indexPath NSIndexPath
     * @return height CGFloat
     **/
    private func height(#indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < self.UIModes.count {
            return HMAUserInterfaceModeTableViewCell.hma_height()
        }
        else if indexPath.row < self.UIModes.count + 1 {
            return HMASeparatorTableViewCell.hma_height()
        }
        else if indexPath.row < self.UIModes.count + 3 {
            return HMATestTableViewCell.hma_height()
        }
        return 0.0
    }

    /**
     * return tableview cell
     * @param indexPath NSIndexPath
     * @return cell UITableViewCell
     **/
    private func cell(#indexPath: NSIndexPath) -> UITableViewCell {
        // nibName
        var nibName = ""
        if indexPath.row < self.UIModes.count {
            nibName = HMANSStringFromClass(HMAUserInterfaceModeTableViewCell)
        }
        else if indexPath.row < self.UIModes.count + 1 {
            nibName = HMANSStringFromClass(HMASeparatorTableViewCell)
        }
        else if indexPath.row < self.UIModes.count + 3 {
            nibName = HMANSStringFromClass(HMATestTableViewCell)
        }

        let nib = UINib(nibName: nibName, bundle:nil)
        let views = nib.instantiateWithOwner(nil, options: nil)
        let cell = views[0] as! UITableViewCell

        // design
        if indexPath.row < self.UIModes.count {
            (cell as! HMAUserInterfaceModeTableViewCell).design(mode: self.UIModes[indexPath.row], selected: (self.selectedIndex == indexPath.row))
        }
        else if indexPath.row < self.UIModes.count + 1 {
        }
        else if indexPath.row < self.UIModes.count + 3 {
            let index = indexPath.row - (self.UIModes.count + 1)
            let titles = [ "Go to Boston", "Go to San Francisco", ]
            (cell as! HMATestTableViewCell).design(title: titles[index])
        }

        return cell
    }

    /**
     * call when tableView cell didSelectRowAtIndexPath
     * @param indexPath NSIndexPath
     * @return cell UITableViewCell
     **/
    private func didSelectRow(#indexPath: NSIndexPath) {
        self.selectedIndex = indexPath.row
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // select UIMode
        if self.selectedIndex < self.UIModes.count {
            let mode = self.UIModes[self.selectedIndex]
            NSNotificationCenter.defaultCenter().postNotificationName(
                HMANotificationCenter.ChangeUserInterfaceMode,
                object: nil,
                userInfo: [ HMANotificationCenter.ChangeUserInterfaceMode : mode ]
            )
            self.tableView.reloadData()
            HMADrawerController.sharedInstance.setDrawerState(.Closed, animated: true)
        }
        else if indexPath.row < self.UIModes.count + 1 {
        }
        // select Go to Boston
        else if indexPath.row < self.UIModes.count + 3 {
            let index = indexPath.row - (self.UIModes.count + 1)
            let destinations = [
                CLLocation(latitude: 42.235078, longitude: -71.523542),
                CLLocation(latitude: 37.7833, longitude: -122.4167)
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(
                HMANotificationCenter.GoToTheLocation,
                object: nil,
                userInfo: [ HMANotificationCenter.GoToTheLocation : destinations[index] ]
            )
            HMADrawerController.sharedInstance.setDrawerState(.Closed, animated: true)
        }
    }
}


/// MARK: - UITableViewDelegate
extension HMASlideMenuController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectRow(indexPath: indexPath)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellCount()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cell(indexPath: indexPath)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.height(indexPath: indexPath)
    }
}

