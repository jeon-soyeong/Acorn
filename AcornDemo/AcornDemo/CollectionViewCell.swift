//
//  CollectionViewCell.swift
//  AcornDemo
//
//  Created by 전소영 on 2022/09/10.
//

import UIKit
import Acorn

class CollectionViewCell: UICollectionViewCell {
    private let urlString: [String] = [
        "https://user-images.githubusercontent.com/61855905/189476491-b754a686-c218-4ebd-857d-a6c39ddd1506.png",
        "https://user-images.githubusercontent.com/61855905/189476493-1bc7267a-03d1-41a0-9de1-31eeae82a1ea.png",
        "https://user-images.githubusercontent.com/61855905/189476494-d69b4b45-a9e7-458d-99db-25167d1efaaf.png",
        "https://user-images.githubusercontent.com/61855905/189476496-4d1e8e14-1512-41ee-9172-f9f1fa721b0e.png",
        "https://user-images.githubusercontent.com/61855905/189476498-d301d649-70bb-4795-af2e-9787a173e303.png",
        "https://user-images.githubusercontent.com/61855905/189476500-8821009c-b230-4911-86e7-52c93e79d3a5.png",
        "https://user-images.githubusercontent.com/61855905/189476503-77883528-2b36-4c57-90f6-286531c6644d.png",
        "https://user-images.githubusercontent.com/61855905/189476504-4acb4ae7-5de2-4fed-98b2-70c6fe6a2767.png",
        "https://user-images.githubusercontent.com/61855905/189476506-5aa34d9b-a9db-480a-8f80-4d2a3d79c418.png",
        "https://user-images.githubusercontent.com/61855905/189476507-05770197-6799-4240-b457-8e90204a26fb.png",
        "https://user-images.githubusercontent.com/61855905/189476509-f1d297bf-7def-4710-889c-7b9ad82a14f0.png",
        "https://user-images.githubusercontent.com/61855905/189476510-31240f25-da1c-4937-b23e-4ac49a6dd343.png",
        "https://user-images.githubusercontent.com/61855905/189476511-33ad0dea-6e59-4583-8bbd-98748a1b75d7.png",
        "https://user-images.githubusercontent.com/61855905/189476512-72d90739-f988-4334-a6b5-791abcf74d49.png",
        "https://user-images.githubusercontent.com/61855905/189476514-8d35c6eb-fd15-4fb5-ba68-3c59f5a5779f.png",
        "https://user-images.githubusercontent.com/61855905/189476516-b0d731d9-03a7-4ee3-b34e-b34f587d83b7.png",
        "https://user-images.githubusercontent.com/61855905/189476517-14bad31c-a98b-4dba-8b81-0875e36119c4.png",
        "https://user-images.githubusercontent.com/61855905/189476518-a65422f1-9bf9-438b-9756-8da0d2d72b88.png",
        "https://user-images.githubusercontent.com/61855905/189476520-5a01aa7c-feca-4c7b-b693-7d0091fe2e05.png",
        "https://user-images.githubusercontent.com/61855905/189476521-09ad4e63-3093-4781-8f37-9cccf4732004.png"
    ]
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let button: UIButton = {
       let button = UIButton()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(imageView)
        self.addSubview(button)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 120).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 20).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
        
    func setupUI(index: Int) {
        imageView.setImage(with: urlString[index])
        button.setImage(with: urlString[index])
    }
}
