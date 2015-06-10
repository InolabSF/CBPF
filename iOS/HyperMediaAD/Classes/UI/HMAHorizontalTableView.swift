import UIKit


/// MARK: - HMAHorizontalTableViewDelegate
protocol HMAHorizontalTableViewDelegate {

    /**
     * called when check box was on
     * @param tableView HMAHorizontalTableView
     * @param indexPath NSIndexPath
     * @param wasOn On or Off (Bool)
     */
    func tableView(tableView: HMAHorizontalTableView, indexPath: NSIndexPath, wasOn: Bool)

}


/// MARK: - HMAHorizontalTableView
class HMAHorizontalTableView: UIView {

    /// MARK: - property

    var dataSource: [HMAHorizontalTableViewData]! = []
    var delegate: HMAHorizontalTableViewDelegate?
    @IBOutlet weak var scrollView: UIScrollView!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - public api

    /**
     * do settings
     **/
    func doSettings() {
        // cells
        var offset: CGFloat = 0.0
        let datas = [
            "crime",
        ]

        for var i = 0; i < datas.count; i++ {
            var data = HMAHorizontalTableViewData()
            data.isOn = false
            self.dataSource.append(data)
            let nib = UINib(nibName: HMANSStringFromClass(HMAHorizontalTableViewCell), bundle:nil)
            let cells = nib.instantiateWithOwner(nil, options: nil)
            var cell = cells[0] as! HMAHorizontalTableViewCell
            cell.frame = CGRectMake(offset, 0, cell.frame.size.width, self.scrollView.frame.size.height)
            cell.data = data
            cell.delegate = self
            self.scrollView.addSubview(cell)
            offset += cell.frame.size.width
        }

        self.scrollView.contentSize = CGSizeMake(offset, self.scrollView.frame.size.height)
    }

}


/// MARK: - UIScrollViewDelegate
extension HMAHorizontalTableView: UIScrollViewDelegate {
}


/// MARK: - HMAHorizontalTableViewCellDelegate
extension HMAHorizontalTableView: HMAHorizontalTableViewCellDelegate {

    func horizontalTableViewCell(horizontalTableViewCell: HMAHorizontalTableViewCell, wasOn: Bool) {
        var index = -1
        for var i = 0; i < self.dataSource.count; i++ {
            if self.dataSource[i] == horizontalTableViewCell.data {
                index = i
                break
            }
        }
        if index < 0 { return }

        if self.delegate != nil {
            self.delegate?.tableView(self, indexPath: NSIndexPath(index: index), wasOn: wasOn)
        }
    }

}
