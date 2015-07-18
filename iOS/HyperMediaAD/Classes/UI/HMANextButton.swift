/// MARK: - HMANextButton
class HMANextButton: BFPaperButton {

    /// MARK: - property


    /// MARK: - public api

    /**
     * design
     **/
    func design() {
        self.isRaised = false

        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        self.setTitleColor(UIColor(red: 54.0/255.0, green: 158.0/255.0, blue: 186.0/255.0, alpha: 1.0), forState: .Normal)
        self.setTitleColor(UIColor(red: 54.0/255.0, green: 158.0/255.0, blue: 186.0/255.0, alpha: 1.0), forState: .Highlighted)
        self.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.8
        let shadowRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y-2, self.bounds.size.width, self.bounds.size.height)
        self.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
    }

}

