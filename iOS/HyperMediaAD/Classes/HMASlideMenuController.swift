import UIKit


/// MARK: - HMASlideMenuController
class HMASlideMenuController: UIViewController, UITableViewDelegate {

    /// MARK: - property

    @IBOutlet weak var tableView: UITableView!

    private var UIModes: [Int] = [ HMAUserInterface.Mode.SetDestinations, ]
    private var selectedIndex = 0


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener


    /// MARK: - public api

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

}


/// MARK: - UITableViewDelegate
extension HMASlideMenuController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = indexPath.row
        let mode = self.UIModes[self.selectedIndex]
        NSNotificationCenter.defaultCenter().postNotificationName(
            HMANotificationCenter.ChangeUserInterfaceMode,
            object: nil,
            userInfo: [ HMANotificationCenter.ChangeUserInterfaceMode : mode ]
        )

        tableView.reloadData()
        HMADrawerController.sharedInstance.setDrawerState(.Closed, animated: true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.UIModes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nib = UINib(nibName: HMANSStringFromClass(HMAUserInterfaceModeTableViewCell), bundle:nil)
        let views = nib.instantiateWithOwner(nil, options: nil)
        let cell = views[0] as! HMAUserInterfaceModeTableViewCell
        cell.design(mode: self.UIModes[indexPath.row], selected: (self.selectedIndex == indexPath.row))
        return cell
    }

}

