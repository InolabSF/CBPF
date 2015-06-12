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
    var cells: [HMAHorizontalTableViewCell]! = []
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
        let visualizationTypes = [
            HMAGoogleMap.Visualization.CrimePoint,
            HMAGoogleMap.Visualization.CrimeHeatmap,
            HMAGoogleMap.Visualization.CrimeCluster,
            HMAGoogleMap.Visualization.NoisePoint,
            HMAGoogleMap.Visualization.NoiseHeatmap,
            HMAGoogleMap.Visualization.HeatIndexPoint,
            HMAGoogleMap.Visualization.HeatIndexHeatmap,
            HMAGoogleMap.Visualization.Pm25Point,
            HMAGoogleMap.Visualization.Pm25Heatmap,
        ]
        let titles = [
            "Crime Point",
            "Crime Heatmap",
            "Crime Cluster",
            "Noise Point",
            "Noise Heatmap",
            "Heat Index Point",
            "Heat Index Heatmap",
            "PM2.5 Point",
            "PM2.5 Heatmap",
        ]

        for var i = 0; i < visualizationTypes.count; i++ {
            var data = HMAHorizontalTableViewData()
            data.isOn = false
            data.visualizationType = visualizationTypes[i]

            self.dataSource.append(data)
            let nib = UINib(nibName: HMANSStringFromClass(HMAHorizontalTableViewCell), bundle:nil)
            let views = nib.instantiateWithOwner(nil, options: nil)
            var cell = views[0] as! HMAHorizontalTableViewCell
            cell.frame = CGRectMake(offset, 0, cell.frame.size.width, self.scrollView.frame.size.height)
            cell.titleLabel.text = titles[i]
            cell.delegate = self
            self.scrollView.addSubview(cell)
            offset += cell.frame.size.width
            self.cells.append(cell)
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
        for var i = 0; i < self.cells.count; i++ {
            let cell = self.cells[i]
            if cell == horizontalTableViewCell {
                index = i
            }
            else {
                cell.setCheckBox(isOn: false)
            }
        }
        if index < 0 { return }

        if self.delegate != nil {
            self.delegate?.tableView(self, indexPath: NSIndexPath(forRow: index, inSection: 0), wasOn: wasOn)
        }
    }

}
