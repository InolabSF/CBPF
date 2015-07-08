import UIKit


/// MARK: - HMASlideMenuController
class HMASlideMenuController: UIViewController, UITableViewDelegate {

    /// MARK: - property

    private let dataSource = [
        HMAUserInterface.Mode.SetDestinations,
        HMAUserInterface.Mode.SetRoute,
//        HMAUserInterface.Mode.Cycle,
    ]

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


    /// MARK: - private api

}


/// MARK: - UITableViewDelegate
extension HMASlideMenuController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nib = UINib(nibName: HMANSStringFromClass(HMAUserInterfaceModeTableViewCell), bundle:nil)
        let views = nib.instantiateWithOwner(nil, options: nil)
        let cell = views[0] as! HMAUserInterfaceModeTableViewCell
        cell.design(mode: self.dataSource[indexPath.row], selected: (self.selectedIndex == indexPath.row))
        return cell
    }

}

