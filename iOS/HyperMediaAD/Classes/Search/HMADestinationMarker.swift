/// MARK: - HMADestinationMarker
class HMADestinationMarker: GMSMarker {

    /// MARK: - initilization

    convenience init(position: CLLocationCoordinate2D, index: Int) {
        self.init()

        // icon
        let iconColors = [
            UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0),
            UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1.0),
            UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0),
            UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0),
            UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0),
            UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0),
            UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0),
        ]
        let markerImageView = UIImageView(image: HMADestinationMarker.markerImageWithColor(iconColors[index % iconColors.count]))
        let label = UILabel()
        label.text = "\(index+1)"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        label.backgroundColor = iconColors[index % iconColors.count].colorWithAlphaComponent(0.75)
        label.sizeToFit()
        label.layer.cornerRadius = label.frame.size.width / 2.0
        label.layer.masksToBounds = true
        markerImageView.addSubview(label)
        label.center = CGPointMake(markerImageView.center.x, markerImageView.center.y - 6)
        self.icon = UIImage.imageFromView(markerImageView)

        // settings
        self.position = position
        self.draggable = true
        self.zIndex = HMAGoogleMap.ZIndex.Destination
    }

}
