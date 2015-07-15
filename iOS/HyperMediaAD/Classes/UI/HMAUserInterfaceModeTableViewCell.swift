import UIKit


/// MARK: - HMAUserInterfaceModeTableViewCell
class HMAUserInterfaceModeTableViewCell: UITableViewCell {

    /// MARK: - property

    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!


    /// MARK: - class method

    class func hma_height() -> CGFloat {
        return 54.0
    }

    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * design
     * @param mode HMAUserInterface.Mode
     * @param selected BOOL
     **/
    func design(#mode: Int, selected: Bool) {
        let color = (selected) ?
            UIColor(red: 54.0/255.0, green: 158.0/255.0, blue: 186.0/255.0, alpha: 1.0) :
            UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
            //UIColor.darkGrayColor()

        // icon
        let imageNames = [
            HMAUserInterface.Mode.SetDestinations : ion_ios_location,
            HMAUserInterface.Mode.SetRoute : ion_pinpoint,
        ]
        self.iconImageView.image = IonIcons.imageWithIcon(
            imageNames[mode],
            size: 36.0,
            color: color
        )

        // label
        let titles = [
            HMAUserInterface.Mode.SetDestinations : "Reset Destinations",
            HMAUserInterface.Mode.SetRoute : "Reroute",
        ]
        self.titleLabel.text = titles[mode]
        self.titleLabel.textColor = color

        if selected {
            self.backgroundColor = UIColor(red: 54.0/255.0, green: 158.0/255.0, blue: 186.0/255.0, alpha: 0.1)
        }
    }

}

