//
//  ViewController.swift
//
// Copyright (c) 2020 Hunjong Bong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    private var disposedBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationController?.navigationBar.isHidden = true

        let btn1 = UIButton()
        view.addSubview(btn1)
        btn1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.width.equalTo(200)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        btn1.setTitle("tableView", for: .normal)
        btn1.setTitleColor(.black, for: .normal)
        btn1.backgroundColor = .green
        btn1.rx.tap
            .bind(onNext: { [weak self] in
                guard let strongSelf = self else { return }

                let viewController = TableDemoViewController()
                strongSelf.navigationController?.pushViewController(viewController, animated: true)

            })
        .disposed(by: disposedBag)

        let btn2 = UIButton()
        view.addSubview(btn2)
        btn2.snp.makeConstraints { make in
            make.top.equalTo(btn1.snp.bottom).offset(100)
            make.width.equalTo(200)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }
        btn2.setTitle("collectionView", for: .normal)
        btn2.setTitleColor(.black, for: .normal)
        btn2.backgroundColor = .red
        btn2.rx.tap
        .bind(onNext: { [weak self] in
            guard let strongSelf = self else { return }

            let viewController = CollectionDemoViewController()
            strongSelf.navigationController?.pushViewController(viewController, animated: true)

        })
        .disposed(by: disposedBag)
    }

    static var safeAreaTop: CGFloat = {
        if let root = UIApplication.shared.keyWindow?.rootViewController {
            if #available(iOS 11.0, *) {
                return root.view.safeAreaInsets.top
            } else {
                return root.topLayoutGuide.length
            }
        }
        return 0.0
    }()
}

