/// MARK: - UIImage+HMAView
extension UIImage {

    /// MARK: - class method

    /**
     * create UIImage from UIView
     * @param view UIView
     * @return UIImage
     **/
    class func imageFromView(view: UIView) -> UIImage {
        let scale = UIScreen.mainScreen().scale

        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return image
    }

    /**
     * create circle shaped UIImage
     * @param size CGSize
     * @param color UIColor
     * @return UIImage
     **/
    class func circleImage(#size: CGSize, color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)

        UIGraphicsBeginImageContext(rect.size)
        var context = UIGraphicsGetCurrentContext()

        CGContextSetLineWidth(context, 2);
        //CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextAddEllipseInRect(context, rect)
        CGContextClip(context)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        CGContextAddEllipseInRect(context, rect)
        CGContextStrokePath(context)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
