//
//  PhotoPickerController.swift
//  RTPhotoPicker
//
//  Created by yangtao on 3/1/16.
//  Copyright © 2016 yangtao. All rights reserved.
//

import UIKit
private let photoCollectionCellIdentifier = "photoCollectionCellIdentifier"
class PhotoPickerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
    
        view.addSubview(photoCollectionView)
        photoCollectionView.frame = UIScreen.mainScreen().bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    lazy var photoCollectionView:UICollectionView = {
       let  photoCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: photoCollectionViewLayout())
        
        photoCollectionView.registerClass(photoCollectionViewCell.self, forCellWithReuseIdentifier: photoCollectionCellIdentifier)
        photoCollectionView.dataSource = self
        //photoCollectionView.backgroundColor = UIColor.greenColor()
        return photoCollectionView
    }()
    
    //用于保存图片
    private lazy var pictureImages = [UIImage]()
}


private class photoCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        
        //设置photoCollectionViewLayout的布局
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        itemSize = CGSizeMake(80, 80)
        
        //设置与photoCollectionView的间距
        sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
    }
}

extension PhotoPickerController: UICollectionViewDataSource, PhotoSelectorCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureImages.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCollectionCellIdentifier, forIndexPath: indexPath) as! photoCollectionViewCell
        cell.PhotoCellDelegate = self
       
        cell.image = (pictureImages.count == indexPath.item) ? nil : pictureImages[indexPath.item] // 0  1
        return cell
    }
    
    func photoDidAddSelector(cell: photoCollectionViewCell) {
    
        if  !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            print("不能打开相册")
            return
        }
        
        //打开相册
        let vc = UIImagePickerController()
        //设置图片代理
        vc.delegate = self
        //允许用户编辑图片
        vc.editing = true
         presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //对图片进行压缩,进行内存优化
        let newImage = image.imageWithScale(UIScreen.mainScreen().bounds.width)
        print("image= \(image)");
        // 1.将当前选中的图片添加到数组中
        pictureImages.append(newImage)
        photoCollectionView.reloadData()
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func photoDidRemoveSelector(cell: photoCollectionViewCell) {
        
        let index = photoCollectionView.indexPathForCell(cell)
        pictureImages.removeAtIndex(index!.item)
        photoCollectionView.reloadData()
    }
}

@objc
protocol PhotoSelectorCellDelegate : NSObjectProtocol
{
    optional func photoDidAddSelector(cell: photoCollectionViewCell)
    optional func photoDidRemoveSelector(cell: photoCollectionViewCell)
}

class photoCollectionViewCell:UICollectionViewCell {
    
    weak var PhotoCellDelegate: PhotoSelectorCellDelegate?
    //开放接口提供数据
    var image: UIImage?
        {
        didSet{
            if image != nil{
                removeButton.hidden = false
                addButton.setBackgroundImage(image!, forState: UIControlState.Normal)
                addButton.userInteractionEnabled = false
            }else
            {
                removeButton.hidden = true
                addButton.userInteractionEnabled = true
                addButton.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    private func setupUI() {
        
        // 1.添加子控件
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        
        // 2.布局子控件
        addButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[addButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addButton": addButton])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[addButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addButton": addButton])
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:[removeButton]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["removeButton": removeButton])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-2-[removeButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["removeButton": removeButton])
        
        contentView.addConstraints(cons)
        
    }
    
    // MARK: - 懒加载
    private lazy var removeButton: UIButton = {
        let btn = UIButton()
        btn.hidden = true
        btn.setBackgroundImage(UIImage(named: "compose_photo_close"), forState: UIControlState.Normal)
        btn.addTarget(self, action: "removeBtnClick", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    private lazy  var addButton: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        btn.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action: "addBtnClick", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    func addBtnClick()
    {
        PhotoCellDelegate?.photoDidAddSelector!(self)
        print(__FUNCTION__)
    }
    
    func removeBtnClick()
    {
        PhotoCellDelegate?.photoDidRemoveSelector!(self)
        print(__FUNCTION__)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
