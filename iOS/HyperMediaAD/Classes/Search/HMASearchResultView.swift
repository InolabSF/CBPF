import UIKit


/// MARK: - HMASearchResultViewDelegate
protocol HMASearchResultViewDelegate {

    /**
     * called when cell is selected
     * @param searchResultView HMASearchResultView
     * @param selectedDestination selected destination
     */
    func didSelectRow(#searchResultView: HMASearchResultView, selectedDestination: HMADestination)

}


/// MARK: - HMASearchResultView
class HMASearchResultView: UIView {

    /// MARK: - property
    @IBOutlet weak var resultTableView: UITableView!
    var delegate: HMASearchResultViewDelegate?
    var destinations: [HMADestination] = []


    /// MARK: - life cycle

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }


    /// MARK: - public api

    /**
     * design
     **/
    func design() {
        self.resultTableView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.resultTableView.layer.shadowColor = UIColor.blackColor().CGColor
        self.resultTableView.layer.shadowOpacity = 0.2
        var rect = self.resultTableView.bounds
        self.resultTableView.layer.shadowPath = UIBezierPath(rect: rect).CGPath
    }

    /**
     * update destinations
     * @param destinations destinations
     **/
    func updateDestinations(destinations: [HMADestination]) {
        self.destinations = destinations
        self.resultTableView.reloadData()
    }

}


/// MARK: - UITableViewDelegate, UITableViewDataSource
extension HMASearchResultView: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.destinations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let destination = self.destinations[indexPath.row]

        var cell = UITableViewCell(
            style: UITableViewCellStyle.Default,
            reuseIdentifier: HMANSStringFromClass(HMASearchResultView)
        )
        cell.textLabel!.text = destination.desc

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let destination = self.destinations[indexPath.row]
        if self.delegate != nil {
            self.delegate?.didSelectRow(searchResultView: self, selectedDestination: destination)
        }
    }

}