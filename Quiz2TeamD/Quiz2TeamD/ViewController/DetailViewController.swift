//
//  DetailViewController.swift
//  Quiz2TeamD
//
//  Created by 劉仲軒 on 2017/4/7.
//  Copyright © 2017年 劉仲軒. All rights reserved.
//

import UIKit
import DKImagePickerController

class DetailViewController: UIViewController {

    enum Component {

        case image, title, content

    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!

    var component: [Component] = [.image, .title, .content]
    var image: UIImage = #imageLiteral(resourceName: "icon_photo")
    var height: CGFloat = 56
    var isImageSelected = false
    var isAddAction = false
    var content = ""
    var articleTitle = ""
    var article = Article(title: "", content: "", image: #imageLiteral(resourceName: "icon_photo"))
    var indexPath: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpBackButton()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.saveButton.layer.masksToBounds = false
        self.saveButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.saveButton.layer.shadowOpacity = 0.2
        self.saveButton.layer.shadowRadius = 5
        self.saveButton.layer.cornerRadius = self.saveButton.layer.frame.height / 2

        self.tableView.register(UINib(nibName: "DetailImageTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailImageTableViewCell")
        self.tableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCell")
        self.tableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextTableViewCell")
        self.tableView.estimatedRowHeight = 150
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.statusBarStyle = .lightContent
    }

    func setUpBackButton() {

        let backButton = UIButton(frame: CGRect(x: 20, y: 30, width: 44, height: 44))
        backButton.setImage(#imageLiteral(resourceName: "button_close"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        self.view.addSubview(backButton)
    }

    func backAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func saveAction(_ sender: Any) {

        if self.isAddAction == false {
            ArticleManager.shared.update(self.indexPath, article: self.article)
        } else {
            ArticleManager.shared.save(article: self.article)
        }

        self.navigationController?.popToRootViewController(animated: true)
    }

    func showImagePickerAlertSheet() {
        let alertController = UIAlertController(title: "Choose Image From?", message: nil, preferredStyle: .actionSheet)

        let libraryAction = UIAlertAction(title: "Choose from photo library", style: .default) { (_) in

            let pickerController = DKImagePickerController()
            pickerController.assetType = .allPhotos
            pickerController.maxSelectableCount = 1
            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                print("didSelectAssets")

                let asset = assets.first
                asset?.fetchOriginalImage(true, completeBlock: { (imageData, _) in
                    guard let image = imageData else { return }
                    self.image = image
                    self.article.image = image
                    self.isImageSelected = true
                    self.tableView.reloadData()
                })
            }
            self.present(pickerController, animated: true, completion: nil)
        }

        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (_) in

            let pickerController = DKImagePickerController()
            pickerController.sourceType = .camera

            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                print("didSelectAssets")

                let asset = assets.first
                asset?.fetchOriginalImage(true, completeBlock: { (imageData, _) in
                    guard let image = imageData else { return }
                    self.image = image
                    self.article.image = image
                    self.isImageSelected = true
                    self.tableView.reloadData()
                })
            }
            self.present(pickerController, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func showAlert() {
        let alertController = UIAlertController(title: "Save Success!", message: nil, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(doneAction)

        self.present(alertController, animated: true, completion: nil)
    }

}

extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch self.component[indexPath.row] {
        case .image:
            // swiftlint:disable force_cast
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "DetailImageTableViewCell", for: indexPath) as! DetailImageTableViewCell

            cell.selectionStyle = .none
            cell.articleImageView.image = self.article.image
            cell.articleImageView.contentMode = .scaleAspectFill
            cell.articleImageView.clipsToBounds = true

            if self.isImageSelected == true {
                let leading = NSLayoutConstraint(item: cell.articleImageView, attribute: .leading, relatedBy: .equal, toItem: cell.articleImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
                let trailing = NSLayoutConstraint(item: cell.articleImageView, attribute: .trailing, relatedBy: .equal, toItem: cell.articleImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
                let top = NSLayoutConstraint(item: cell.articleImageView, attribute: .top, relatedBy: .equal, toItem: cell.articleImageView.superview, attribute: .top, multiplier: 1, constant: 0)
                let bottom = NSLayoutConstraint(item: cell.articleImageView, attribute: .bottom, relatedBy: .equal, toItem: cell.articleImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)

                leading.isActive = true
                trailing.isActive = true
                top.isActive = true
                bottom.isActive = true
            }

            return cell

        case .title:

            let cell = self.tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell", for: indexPath) as! TitleTableViewCell

            cell.selectionStyle = .none
            cell.titleTextField.delegate = self
            cell.titleTextField.text = self.article.title

            return cell

        case .content:

            let cell = self.tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell

            cell.selectionStyle = .none

            cell.textField.delegate = self
            cell.textField.text = self.article.content

            return cell
        }

    }

}

extension DetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch self.component[indexPath.row] {
        case .image:
            return self.tableView.frame.width

        case .title:
            return 56

        case .content:
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.component[indexPath.row] == .image {
            self.showImagePickerAlertSheet()
        }
    }

}

extension DetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = self.tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.tableView.setContentOffset(currentOffset, animated: false)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text != nil {
            self.article.content = textView.text
        }
    }
}

extension DetailViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            self.article.title = text
        }
    }
}
